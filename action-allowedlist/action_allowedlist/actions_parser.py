# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

import json
import yaml

def load_json_file(filepath):
    with open(filepath, 'r') as file:
        content = file.read()
        return json.loads(content)

def load_yaml_file(filepath):
    with open(filepath, 'r') as file:
        return yaml.safe_load(file)

def get_actions_from_file(workflow, workflow_file_name):
    #print(workflow_file_name)
    parsed_yaml = yaml.safe_load(workflow)
    actions = []

    for job_name, job in parsed_yaml.get("jobs", {}).items():
        print(f"  Job found: [{job_name}] in {workflow_file_name}")
        steps = job.get("steps", [])
        for step in steps:
            uses = step.get("uses")
            if (uses != None):
                parts = uses.split("@")
                if len(parts) == 2:
                    action_link, action_version = parts
                    actions.append({
                        "actionLink": action_link,
                        "actionVersion": action_version,
                        "workflowFileName": workflow_file_name
                    })
                    print(f"   Found action used: [{uses}]")

    return actions

def get_all_used_actions(workflow_dir):
    print("Loading Actions YAML files")
    workflow_files = list(workflow_dir.glob("*.yml"))

    if not workflow_files:
        print("Could not find workflow files in the specified directory")
        return []

    print(f"Found [{len(workflow_files)}] files in the workflows directory")
    print(workflow_files)
    actions_in_repo = []
    for workflow_file in workflow_files:
        #print(workflow_file)
        try:
            workflow_content = workflow_file.read_text()
            actions = get_actions_from_file(workflow_content, workflow_file.name)
            actions_in_repo.extend(actions)
        except Exception as e:
            print(f"Error occurred while reading {workflow_file}: {e}")

    return actions_in_repo

def invoke_validate_actions(approved_path, actions_configuration):
    print("Checking if used actions are approved")

    approved = load_json_file(approved_path)
    num_approved = 0
    num_denied = 0
    num_deprecated = 0
    unapproved_outputs = []
    approved_outputs = []
    found = False


    for action in actions_configuration:
        # print(f"Processing {action['actionLink']} version {action['actionVersion']}") Use for debugging

        approved_action_versions = [a for a in approved if a['actionLink'] == action['actionLink']]
        if approved_action_versions:
            # print(f"Approved Versions for {action['actionLink']}: {[a['actionVersion'] for a in approved_action_versions]}") Use for debugging
            pass
        else:
            # print(f"No Approved versions for {action['actionLink']} were found.") Use for debugging
            pass

        approved_output = [a for a in approved_action_versions if a['actionVersion'] == action['actionVersion']]

        if approved_output:
            # print(f"Output versions approved: {approved_output}") Use for debugging
            approved_outputs.append(approved_output[0])
            num_approved += 1

            # Look for deprecation
            if approved_output[0].get('deprecated', False):
                print(f"Using a deprecated version of {action['actionLink']}")
                num_deprecated += 1
                found = True
        else:
            # print(f"Output versions not approved: {action['actionLink']} version {action['actionVersion']}") Use for debugging
            unapproved_outputs.append(f"{action['actionLink']} {action['actionVersion']}")
            num_denied += 1
            found = True

    if num_denied > 0:
        e = f"The following {num_denied} actions/versions were denied: {', '.join(unapproved_outputs)}"
        print(e)
        return found
    else:
        print(f"All {num_approved} actions/versions are approved.")
        if num_deprecated > 0:
            print(f"Deprecated actions found: {num_deprecated}")
        return found
