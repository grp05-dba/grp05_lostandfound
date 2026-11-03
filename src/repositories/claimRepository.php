<?php

class ClaimRepository {
    private PDO $connection;

    public function __construct(PDO $connection) {
        $this->connection = $connection;
    }

    public function getAll(): array {
        $stmt = $this->connection->prepare('SELECT * FROM claims');
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getById(int $id): array|false {
        $stmt = $this->connection->prepare('SELECT * FROM claims WHERE claim_id = :id');
        $stmt->execute(['id' => $id]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function codeExists(string $code): bool {
        $stmt = $this->connection->prepare('SELECT 1 FROM claims WHERE claim_code = :code');
        $stmt->execute(['code' => $code]);
        return $stmt->fetchColumn() !== false;
    }

    public function create(Claim $claim): bool {
        $stmt = $this->connection->prepare(
            'INSERT INTO claims (claim_code, item_id, full_name, student_number, email, phone_number) 
            SELECT :claimCode, item_id, :fullName, :studentNumber, :email, :phoneNumber
            FROM items WHERE item_id = :itemId AND status = :status');
        $success = $stmt->execute([
            'claimCode' => $claim->getClaimCode(),
            'itemId' => $claim->getItemId(),
            'fullName' => $claim->getFullName(),
            'studentNumber' => $claim->getStudentNumber(),
            'email' => $claim->getEmail(),
            'phoneNumber' => $claim->getPhoneNumber(),
            'status' => 'unclaimed'
        ]);
        return $success && $stmt->rowCount() === 1;
    }

    public function update(int $claimId, array $data): bool {
        $allowedFields = [
            'claim_code',
            'item_id',
            'full_name',
            'student_number',
            'email',
            'phone_number',
            'status'
        ];

        $updates = [];
        $parameters = ['claimId' => $claimId];

        foreach ($data as $field => $value) {
            if (!in_array($field, $allowedFields, true)) {
                return false;
            }

            $updates[] = $field . ' = :' . $field;
            $parameters[$field] = $value;
        }

        if ($updates === []) {
            return false;
        }

        $sql = 'UPDATE claims SET ' . implode(', ', $updates) . ' WHERE claim_id = :claimId';
        $stmt = $this->connection->prepare($sql);

        return $stmt->execute($parameters);
    }
}
