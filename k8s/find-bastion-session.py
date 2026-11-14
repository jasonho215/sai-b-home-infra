#!/usr/bin/env python3
"""Print the OCID of an active port-forward session that uses this public key."""

import json
import subprocess
import sys


def main() -> None:
    ip = sys.argv[1]
    port = int(sys.argv[2])
    public_key = open(sys.argv[3]).read().strip()
    sessions = json.load(sys.stdin).get("data") or []
    for session in sessions:
        if session.get("lifecycle-state") != "ACTIVE":
            continue
        details = session.get("target-resource-details") or {}
        if details.get("target-resource-private-ip-address") != ip:
            continue
        if int(details.get("target-resource-port") or 0) != port:
            continue
        registered = subprocess.check_output(
            [
                "oci",
                "bastion",
                "session",
                "get",
                "--session-id",
                session["id"],
                "--query",
                'data."key-details"."public-key-content"',
                "--raw-output",
            ],
            text=True,
        ).strip()
        if registered == public_key:
            print(session["id"])
            return


if __name__ == "__main__":
    main()
