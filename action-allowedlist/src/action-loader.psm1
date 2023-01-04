# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

# pull in central calls script
Import-Module $PSScriptRoot\dependencies.psm1 -Force -DisableNameChecking

# Parse yaml file and return a hashtable with actionLink, actionVersion, and workFlowFileName
function Get-ActionsFromFile {
    param (
        [string] $workflow,
        [string] $workflowFileName
    )

    # Parse the file and extract the actions used in it
    # NOTE: This needs module powershell-yaml
    $parsedYaml = ConvertFrom-Yaml $workflow

    # create a hastable
    $actions = @()

    # go through the parsed yaml
    foreach ($job in $parsedYaml["jobs"].GetEnumerator()) {
        Write-InfoLog "  Job found: [$($job.Key)] in $workflowFileName"
        $steps = $job.Value.Item("steps")
        foreach ($step in $steps) {
            $uses = $step.Item("uses")
            if ($null -ne $uses) {
                Write-InfoLog "   Found action used: [$uses]"
                $actionLink = $uses.Split("@")[0]
                $actionVersion = $uses.Split("@")[1]

                $data = [PSCustomObject]@{
                    actionLink       = $actionLink
                    actionVersion    = $actionVersion
                    workflowFileName = $workflowFileName
                }

                $actions += $data
            }
        }
    }

    return $actions
}


function Get-AllUsedActions {
    param (
        [string] $RepoPath = "/github/workspace"
    )

    Write-InfoLog "Loading Actions YAML files"

    # get all the actions from the repo
    if (Test-Path -Path "$($RepoPath)/.github/workflows") {
        $workflowFiles = Get-ChildItem "$($RepoPath)/.github/workflows" | Where-Object { $_.Name.EndsWith(".yml") }
    }
    else {
        # Depending on how the workflow is called, /github/workspace may not
        # always be the working directory, when calling from a job chain (i.e.
        # allowed actions and bidirectional scanner, we provide a different path
        # since multiple repos are checked out. This should eventually be passed
        # from the calling workflow
        $workflowFiles = Get-ChildItem "$($RepoPath)/testing-repo/.github/workflows" | Where-Object { $_.Name.EndsWith(".yml") }
    }

    if ($workflowFiles.Count -lt 1) {
        Write-InfoLog "Could not find workflow files in the current directory"
    }

    # create a hastable to store the list of files in
    $actionsInRepo = @()

    Write-InfoLog "Found [$($workflowFiles.Count)] files in the workflows directory"
    foreach ($workflowFile in $workflowFiles) {
        try {
            if ($workflowFile.FullName.EndsWith(".yml")) {
                $workflow = Get-Content $workflowFile.FullName -Raw
                $actions = Get-ActionsFromFile -workflow $workflow -workflowFileName $workflowFile.FullName

                $actionsInRepo += $actions
            }
        }
        catch {
            Write-WarnLog "Error occurred while reading $workflowFile"
            Write-DebugLog $_
            Write-DebugLog (Get-Content $workflowFiles[0].FullName -raw) | ConvertFrom-Json -Depth 10
        }
    }

    return $actionsInRepo
}
