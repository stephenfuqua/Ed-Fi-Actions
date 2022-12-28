# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

function CheckIfActionsApproved {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $approvedPath = "/src/approved.json",
        $outputs
    )

    Write-Host "Checking if used actions are approved"

    $approved = (Get-Content $approvedPath | convertfrom-Json -depth 10 | select  actionLink, actionVersion)

    $outputs = $outputs | select  actionLink, actionVersion

    $numApproved = 0
    $numDenied = 0

    $unapprovedOutputs = @()
    $approvedOutputs = @()

    foreach($output in $outputs){
        Write-Verbose "Processing $($output.actionLink) version $($output.actionVersion)"

        $approvedOutputActionVersions = ($approved | where actionLink -eq $output.actionLink)
        if ($approvedOutputActionVersions) {
            Write-Verbose "Approved Versions for $($output.actionLink) : "
            Write-Verbose "$($approvedOutputActionVersions.actionVersion)"
        }else{
            Write-Verbose "No Approved versions for $($output.actionLink) were found. "

        }

        $approvedOutput = $approvedOutputActionVersions | where actionVersion -eq $output.actionVersion | Where {$_.actionVersion -eq $output.actionVersion}

        if ($approvedOutput) {
            Write-Verbose "Output versions approved: $approvedOutput"
            $approvedOutputs += $approvedOutput
            $numApproved++
        }else {
            Write-Verbose "Output versions unapproved: $($output.actionLink) version $($output.actionVersion)"
            $unapprovedOutputs += $output
            $numDenied++
        }
    }

    if ($unapprovedOutputs.Count -gt 0) {
        Write-Host "The following $numDenied actions/versions were denied!"
        Write-Host $unapprovedOutputs
        return $unapprovedOutputs
    }else{
        Write-Host "All $numApproved actions/versions were approved!"
    }

}
