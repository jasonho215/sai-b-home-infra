#!/usr/bin/env python3
"""Point an OKE kubeconfig at the local bastion forward and set the OCI profile."""

import os
import re
import sys
from pathlib import Path


def main() -> None:
    path = Path(sys.argv[1])
    local_port = os.environ["LOCAL_API_PORT"]
    profile = os.environ["OCI_CLI_PROFILE"]
    text = path.read_text()
    text, count = re.subn(
        r"(server:\s*)https://\S+",
        rf"\1https://127.0.0.1:{local_port}",
        text,
        count=1,
    )
    if count != 1:
        raise SystemExit("kubeconfig server line was not updated")
    if "OCI_CLI_PROFILE" not in text:
        lines = text.splitlines(keepends=True)
        out = []
        replaced = False
        for line in lines:
            if not replaced and line.strip() == "env: []":
                indent = line[: len(line) - len(line.lstrip())]
                out.append(f"{indent}env:\n")
                out.append(f"{indent}- name: OCI_CLI_PROFILE\n")
                out.append(f"{indent}  value: {profile}\n")
                replaced = True
                continue
            out.append(line)
        if not replaced:
            raise SystemExit("kubeconfig exec env block was not updated")
        text = "".join(out)
    path.write_text(text)
    path.chmod(0o600)


if __name__ == "__main__":
    main()
