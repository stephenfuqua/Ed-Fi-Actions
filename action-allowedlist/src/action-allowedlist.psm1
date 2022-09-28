# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

# pull in central calls script
. $PSScriptRoot\dependencies.ps1

# Parse yaml file and return a hashtable with actionLink, actionVersion, and workFlowFileName
function GetActionsFromFile {
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
        Write-Output "  Job found: [$($job.Key)] in $workflowFileName"
        $steps = $job.Value.Item("steps")
        foreach ($step in $steps) {
            $uses = $step.Item("uses")
            if ($null -ne $uses) {
                Write-Output "   Found action used: [$uses]"
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


function GetAllUsedActions {
    param (
        [string] $RepoPath = "/github/workspace"
    )

    # get all the actions from the repo
    if (Test-Path -Path "$($RepoPath)/.github/workflows") {
        $workflowFiles = Get-ChildItem "$($RepoPath)/.github/workflows" | Where-Object { $_.Name.EndsWith(".yml") }
    }
    else {
        # Depending on how the workflow is called, /github/workspace may not always be the working directory, when calling from a job chain
        # (i.e. allowed actions and bidirectional scanner, we provide a different path since multiple repos are checked out. This should
        # eventually be passed from the calling workflow
        $workflowFiles = Get-ChildItem "$($RepoPath)/testing-repo/.github/workflows" | Where-Object { $_.Name.EndsWith(".yml") }
    }

    if ($workflowFiles.Count -lt 1) {
        Write-Output "Could not find workflow files in the current directory"
    }

    # create a hastable to store the list of files in
    $actionsInRepo = @()

    Write-Output "Found [$($workflowFiles.Count)] files in the workflows directory"
    foreach ($workflowFile in $workflowFiles) {
        try {
            if ($workflowFile.FullName.EndsWith(".yml")) {
                $workflow = Get-Content $workflowFile.FullName -Raw
                $actions = GetActionsFromFile -workflow $workflow -workflowFileName $workflowFile.FullName

                $actionsInRepo += $actions
            }
        }
        catch {
            Write-Warning "Error handling this workflow file:"
            Write-Output (Get-Content $workflowFiles[0].FullName -raw) | ConvertFrom-Json -Depth 10
        }
    }

    return $actionsInRepo
}

function LoadAllUsedActions {
    param (
        [string] $RepoPath = "/github/workspace"
    )
    # create hastable
    $actions = @()

    Write-Output "Loading actions..."
    $actionsUsed = GetAllUsedActions -RepoPath $RepoPath
    $actions += $actionsUsed

    return $actions
}

function CheckIfActionsApproved {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $approvedPath = "/src/approved.json",
        $outputs
    )

    $approved = (Get-Content $approvedPath | Convertfrom-Json -depth 10 | Select-Object  actionLink, actionVersion)

    $outputs = $outputs | Select-Object  actionLink, actionVersion

    $numApproved = 0
    $numDenied = 0

    $unapprovedOutputs = @()
    $approvedOutputs = @()

    foreach ($output in $outputs) {
        Write-Verbose "Processing $($output.actionLink) version $($output.actionVersion)"

        $approvedOutputActionVersions = ($approved | Where-Object actionLink -eq $output.actionLink)
        if ($approvedOutputActionVersions) {
            Write-Verbose "Approved Versions for $($output.actionLink) : "
            Write-Verbose "$($approvedOutputActionVersions.actionVersion)"
        }
        else {
            Write-Verbose "No Approved versions for $($output.actionLink) were found. "

        }


        $approvedOutput = $approvedOutputActionVersions | Where-Object actionVersion -eq $output.actionVersion | Where-Object { $_.actionVersion -eq $output.actionVersion }

        if ($approvedOutput) {
            Write-Verbose "Output versions approved: $approvedOutput"
            $approvedOutputs += $approvedOutput
            $numApproved++
        }
        else {
            Write-Verbose "Output versions unapproved: $($output.actionLink) version $($output.actionVersion)"
            $unapprovedOutputs += $output
            $numDenied++
        }

    }

    if ($unapprovedOutputs.Count -gt 0) {
        Write-Output "The following $numDenied actions/versions were denied!"
        Write-Output $unapprovedOutputs
        return $unapprovedOutputs

    }
    else {
        Write-Output "All $numApproved actions/versions were approved!"
    }

}
