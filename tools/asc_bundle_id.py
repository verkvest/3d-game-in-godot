#!/usr/bin/env python3
"""Register the iOS bundle id with App Store Connect when it is missing.

Uses the API key already installed by the workflow. Prints status only.
"""

import base64
import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

BUNDLE_ID = "es.verkvest.pyrewick"
NAME = "Pyrewick"
AUDIENCE = "appstoreconnect-v1"


def b64url(raw: bytes) -> str:
    return base64.urlsafe_b64encode(raw).rstrip(b"=").decode("ascii")


def der_to_raw(sig: bytes) -> bytes:
    if sig[0] != 0x30:
        raise SystemExit("openssl signature was not DER")
    index = 2
    if sig[1] & 0x80:
        index = 2 + (sig[1] & 0x7F)

    def read_int(buf, idx):
        if buf[idx] != 0x02:
            raise SystemExit("malformed ECDSA signature")
        length = buf[idx + 1]
        start = idx + 2
        value = buf[start : start + length]
        if len(value) > 32:
            value = value[-32:]
        return value.rjust(32, b"\x00"), start + length

    r_part, index = read_int(sig, index)
    s_part, _index = read_int(sig, index)
    return r_part + s_part


def token(key_path: str, key_id: str, issuer: str) -> str:
    now = int(time.time())
    header = b64url(json.dumps({"alg": "ES256", "kid": key_id, "typ": "JWT"}, separators=(",", ":")).encode())
    payload = b64url(
        json.dumps(
            {"iss": issuer, "iat": now, "exp": now + 1200, "aud": AUDIENCE},
            separators=(",", ":"),
        ).encode()
    )
    signing_input = f"{header}.{payload}".encode()
    signed = subprocess.run(
        ["openssl", "dgst", "-sha256", "-sign", key_path],
        input=signing_input,
        capture_output=True,
        check=True,
    )
    return f"{header}.{payload}.{b64url(der_to_raw(signed.stdout))}"


def request(method: str, url: str, jwt: str, body=None):
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(
        url,
        data=data,
        method=method,
        headers={
            "Authorization": f"Bearer {jwt}",
            "Content-Type": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(req) as response:
            raw = response.read().decode()
            return response.status, json.loads(raw) if raw else {}
    except urllib.error.HTTPError as error:
        raw = error.read().decode()
        try:
            parsed = json.loads(raw) if raw else {}
        except json.JSONDecodeError:
            parsed = {"raw": raw[:500]}
        return error.code, parsed


def main():
    key_path = sys.argv[1]
    key_id = os.environ["APPSTORE_API_KEY_ID"]
    issuer = os.environ["APPSTORE_API_ISSUER_ID"]
    jwt = token(key_path, key_id, issuer)
    query = urllib.parse.urlencode({"filter[identifier]": BUNDLE_ID})
    status, payload = request("GET", f"https://api.appstoreconnect.apple.com/v1/bundleIds?{query}", jwt)
    if status != 200:
        print(f"bundle id lookup failed: HTTP {status}")
        print(json.dumps(payload)[:800])
        raise SystemExit(1)
    if payload.get("data"):
        print(f"bundle id {BUNDLE_ID} already registered")
        return
    status, payload = request(
        "POST",
        "https://api.appstoreconnect.apple.com/v1/bundleIds",
        jwt,
        {
            "data": {
                "type": "bundleIds",
                "attributes": {
                    "identifier": BUNDLE_ID,
                    "name": NAME,
                    "platform": "IOS",
                },
            }
        },
    )
    if status in (201, 409):
        print(f"bundle id {BUNDLE_ID} ready (HTTP {status})")
        return
    print(f"bundle id registration failed: HTTP {status}")
    print(json.dumps(payload)[:800])
    raise SystemExit(1)


if __name__ == "__main__":
    main()
