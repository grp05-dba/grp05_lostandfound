# Notifications setup

PUP-SPOT sends potential-match notifications through TextBee (SMS) or EmailJS (email). Notification failures are logged and do not interrupt item/report creation or matching.

Add these values to the local `.env` file (never commit credentials):

```ini
TEXTBEE_API_KEY=your_textbee_api_key
TEXTBEE_BASE_URL=https://api.textbee.dev/api/v1
EMAILJS_BASE_URL=https://api.emailjs.com/api/v1.0/email
EMAILJS_SERVICE_ID=your_service_id
EMAILJS_TEMPLATE_ID=your_template_id
EMAILJS_PUBLIC_KEY=your_public_key
EMAILJS_PRIVATE_KEY=your_private_key_optional
```

The EmailJS template should accept `to_email`, `to_name`, `subject`, `message`, `lost_item`, and `found_item` template parameters. Configure the template's recipient field to use `{{to_email}}`.

TextBee sends to phone numbers in international format. Philippine numbers beginning with `09` are converted to `+639`.

Lost reports use `contact_preference` (`email` or `sms`); existing rows default to email. SMS is attempted only when a phone number is available. The TextBee account must have an enabled, online Android gateway device. A successful API response means the request was accepted, not necessarily delivered.
