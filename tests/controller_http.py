"""Run with python tests/controller_http.py --php /path/to/php.

Uses real PHP controllers and request parsing over loopback HTTP. Fixture services
replace database/storage lookups and notifications; no project database is used.
"""

import argparse
import base64
import json
import os
from pathlib import Path
import socket
import subprocess
import tempfile
import time
import urllib.error
import urllib.request


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--php', default='php')
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    with socket.socket() as listener:
        listener.bind(('127.0.0.1', 0))
        port = listener.getsockname()[1]
    base = f'http://127.0.0.1:{port}'
    checked = 0
    failures = []

    def request(path, payload=None):
        req = urllib.request.Request(
            base + path, data=payload,
            headers={'Content-Type': 'application/json'},
        )
        try:
            response = urllib.request.urlopen(req, timeout=5)
        except urllib.error.HTTPError as error:
            response = error
        with response:
            return response.status, response.headers, response.read()

    with tempfile.TemporaryDirectory(prefix='pupspot-controller-') as directory:
        image = Path(directory) / 'fixture.png'
        image.write_bytes(base64.b64decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aX1sAAAAASUVORK5CYII='
        ))
        env = dict(os.environ, TEST_IMAGE_PATH=str(image))
        with (Path(directory) / 'php.log').open('w+') as log:
            process = subprocess.Popen(
                [args.php, '-d', 'display_errors=0', '-S', f'127.0.0.1:{port}',
                 str(root / 'tests/fixtures/controller_router.php')],
                cwd=root, env=env, stdout=log, stderr=log,
                creationflags=getattr(subprocess, 'CREATE_NO_WINDOW', 0),
            )
            try:
                for _ in range(50):
                    try:
                        status, _, _ = request('/ready')
                        if status != 404:
                            raise RuntimeError(f'PHP fixture startup returned HTTP {status}')
                        break
                    except urllib.error.URLError:
                        if process.poll() is not None:
                            raise RuntimeError('PHP fixture server exited before startup')
                        time.sleep(0.1)
                else:
                    raise RuntimeError('PHP fixture server did not start')

                def check(condition, label):
                    nonlocal checked
                    checked += 1
                    if not condition:
                        failures.append(label)

                endpoints = [
                    ('/api/public/lost-reports/view', 'report_code', 'report_code', 'LR-2026-123456'),
                    ('/api/public/lost-reports/cancel', 'report_code', 'cancelled_report_code', 'LR-2026-123456'),
                    ('/api/public/claims/view', 'claim_code', 'claim_code', 'CLM-2026-123456'),
                ]
                for path, field, result_field, code in endpoints:
                    for payload in [b'', b'{', b'null', b'true', b'false', b'123', b'1.5', b'"text"', b'[]', b'{}']:
                        status, _, body = request(path, payload)
                        check(status == 400 and json.loads(body).get('message') == f'A valid {field} is required.',
                              f'{path}: invalid body {payload!r} returned {status}')
                    for value in [None, '', '  ', 123, True, [], {}]:
                        status, _, body = request(path, json.dumps({field: value}).encode())
                        check(status == 400 and json.loads(body).get('message') == f'A valid {field} is required.',
                              f'{path}: invalid field {value!r} returned {status}')
                    status, _, body = request(path, json.dumps({field: code}).encode())
                    check(status == 200 and json.loads(body).get(result_field) == code, f'{path}: valid code rejected')

                for prefix in ['/api/admin', '/api/public']:
                    for query in ['', '?download=1']:
                        status, headers, body = request(prefix + '/lost-reports/images/7' + query)
                        check(status == 200 and headers.get_content_type() == 'image/png' and body == image.read_bytes(),
                              f'{prefix}: image route did not return image bytes')
                    status, _, body = request(prefix + '/lost-reports/images/8')
                    check(status == 404 and json.loads(body).get('message') == 'Image not found.', f'{prefix}: missing image')
                status, _, body = request('/api/admin/lost-reports/42?test=1')
                check(status == 200 and json.loads(body) == {'report_id': 42}, 'Admin report ID route regressed')
            finally:
                process.terminate()
                process.wait(timeout=10)
    print(f'{checked - len(failures)}/{checked} HTTP checks passed')
    for failure in failures:
        print('FAIL:', failure)
    return bool(failures)


if __name__ == '__main__':
    raise SystemExit(main())
