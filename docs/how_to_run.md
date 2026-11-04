# Run the API locally

From the project root, start the public API:

```sh
php -S 127.0.0.1:8000 -t public
```

Public base URL: `http://127.0.0.1:8000`

To run the admin API instead, use:

```sh
php -S 127.0.0.1:8001 -t admin
```

Admin base URL: `http://127.0.0.1:8001`

The servers need different ports if running at the same time. Keep each terminal open while using its API.
