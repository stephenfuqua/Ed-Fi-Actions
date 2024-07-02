# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

from actions_parser import get_all_used_actions, invoke_validate_actions
from pathlib import Path
import sys
import os

def main():
    repo_path = Path(os.getcwd())
    print(repo_path)
    approved_path = Path("/app/approved.json")

    actions_found = get_all_used_actions(repo_path)

    found = invoke_validate_actions(approved_path, actions_found)

    if found:
        sys.exit(1)
    else:
        sys.exit(0)

if __name__ == "__main__":
    main()
