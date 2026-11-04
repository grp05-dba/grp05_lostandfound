<?php

class ClaimService {
    private PDO $connection;
    private ClaimRepository $claimRepository;
    private ItemRepository $itemRepository;
    private SMSService $smsService;
    private EmailService $emailService;
    private ImageService $imageService;

    public function __construct(PDO $connection) {
        $this->connection = $connection;
        $this->claimRepository = new ClaimRepository($connection);
        $this->itemRepository = new ItemRepository($connection);
        $this->smsService = new SMSService();
        $this->emailService = new EmailService();
        $this->imageService = new ImageService($connection);
    }

    public function getAllClaims(): array {
        $claims = $this->claimRepository->getAll();
        return $this->imageService->attachImageUrls('claims', $claims, 'claim_id');
    }

    public function getClaimById(int $id): array {
        $success = $this->claimRepository->getById($id);
        $failure = RequestUtils::handleFindFailure($success);

        if ($failure) return $failure;

        return $this->imageService->attachImageUrls('claims', [$success], 'claim_id')[0];
    }

    public function updateClaim(int $claimId, array $data): array {
        $claim = $this->claimRepository->getById($claimId);
        if (!$claim) {
            http_response_code(404);
            return ['message' => 'Claim not found.'];
        }

        $data = RequestUtils::normalizeContactFields($data);

        $validationError = RequestUtils::validatePatchFields($data, Claim::class);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateGeneralFields($data);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateContactPreference($data, $claim);
        if ($validationError) return $validationError;

        if (isset($data['item_id'])) {
            $item = $this->itemRepository->getById((int) $data['item_id']);

            if (!$item) {
                http_response_code(400);
                return ['message' => 'Invalid item_id provided.'];
            }
        }

        if (array_key_exists('status', $data)) {
            $allowedStatuses = ['pending', 'approved', 'rejected'];
            if (!is_string($data['status']) || !in_array($data['status'], $allowedStatuses, true)) {
                http_response_code(400);
                return ['message' => 'Invalid status provided. Allowed values: pending, approved, rejected.'];
            }
        }

        $success = $this->claimRepository->update($claimId, $data);

        if ($success && array_key_exists('status', $data) && $data['status'] !== $claim['status']) {
            $updatedClaim = $this->claimRepository->getById($claimId);

            if (
                $updatedClaim &&
                $updatedClaim['contact_preference'] === 'sms' &&
                !empty($updatedClaim['phone_number'])
            ) {
                if ($updatedClaim['status'] === 'approved') {
                    $smsResult = $this->smsService->sendSMSClaimApproval($updatedClaim);
                    error_log('TextBee claim approval response: ' . json_encode($smsResult));
                } elseif ($updatedClaim['status'] === 'rejected') {
                    $smsResult = $this->smsService->sendSMSClaimRejection($updatedClaim);
                    error_log('TextBee claim rejection response: ' . json_encode($smsResult));
                }
            }

            if (
                $updatedClaim &&
                $updatedClaim['contact_preference'] === 'email' &&
                !empty($updatedClaim['email'])
            ) {
                if ($updatedClaim['status'] === 'approved') {
                    $emailResult = $this->emailService->sendEmailClaimApproval($updatedClaim);
                    error_log('EmailJS claim approval response: ' . json_encode($emailResult));
                } elseif ($updatedClaim['status'] === 'rejected') {
                    $emailResult = $this->emailService->sendEmailClaimRejection($updatedClaim);
                    error_log('EmailJS claim rejection response: ' . json_encode($emailResult));
                }
            }
        }

        return RequestUtils::handleUpdateFailure($success);
    }

    public function createClaim(array $data, array $uploads = []): array {
        $data = RequestUtils::normalizeContactFields($data);

        $validationError = RequestUtils::validateRequiredFields($data, Claim::class, ['email', 'phone_number', 'contact_preference', 'claim_code']);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateGeneralFields($data);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateContactPreference($data);
        if ($validationError) return $validationError;

        try {
            $validatedUploads = $this->imageService->validateUploads($uploads);
        } catch (InvalidArgumentException $error) {
            http_response_code(400);
            return ['message' => $error->getMessage()];
        }

        $item = $this->itemRepository->getById($data['item_id']);
        if (!$item || $item['status'] !== 'unclaimed') {
            http_response_code(400);
            return ['message' => 'Item does not exist or is not eligible to be claimed.'];
        }

        $claim = new Claim(
            claim_code: $this->generateClaimCode(),
            item_id: $data['item_id'],
            full_name: $data['full_name'],
            student_number: $data['student_number'],
            email: $data['email'] ?? null,
            phone_number: $data['phone_number'] ?? null,
            contact_preference: $data['contact_preference'] ?? 'email'
        );

        $savedStorageKeys = [];
        $createdClaim = false;

        try {
            $this->connection->beginTransaction();
            $success = $this->claimRepository->create($claim);

            if (!$success) {
                $this->connection->rollBack();
                return RequestUtils::handleCreateFailure(false);
            }

            $createdClaim = $this->claimRepository->getByCode($claim->getClaimCode());
            if (!$createdClaim) {
                throw new RuntimeException('Unable to retrieve the created claim.');
            }

            $savedStorageKeys = $this->imageService->saveUploads('claims', (int) $createdClaim['claim_id'], $validatedUploads);
            $this->connection->commit();
        } catch (Throwable $error) {
            if ($this->connection->inTransaction()) {
                $this->connection->rollBack();
            }

            $this->imageService->deleteStoredFiles($savedStorageKeys);
            error_log($error->getMessage());
            http_response_code(500);
            return ['message' => 'Failed to create claim and save its images.'];
        }

        if ($claim->getContactPreference() === 'sms' && !empty($claim->getPhoneNumber())) {
            $smsResult = $this->smsService->sendSMSClaimCreation($createdClaim);
            error_log('TextBee claim creation response: ' . json_encode($smsResult));
        } elseif ($claim->getContactPreference() === 'email' && !empty($claim->getEmail())) {
            $emailResult = $this->emailService->sendEmailClaimCreation($createdClaim);
            error_log('EmailJS claim creation response: ' . json_encode($emailResult));
        }

        return RequestUtils::handleCreateFailure(true);
    }

    public function getClaimByCode(string $code): array {
        $success = $this->claimRepository->getByCode($code);
        return RequestUtils::handleFindFailure($success) ?? $success;
    }

    
    // Private helper methods --------------------------------
    private function generateClaimCode(): string {
        do {
            $code = 'CLM-' . date('Y') . '-' . random_int(100000, 999999);
        } while ($this->claimRepository->codeExists($code));
        return $code;
    }

    
}
