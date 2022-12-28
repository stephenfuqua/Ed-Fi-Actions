# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.


function CheckIfActionsDeprecated {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $approvedPath = "/src/approved.json",
        $deprecatedPath = "/src/deprecated.json",
        $outputs
    )

    Write-Host "Checking if used actions are deprecated"

    $approved = (Get-Content $approvedPath | convertfrom-Json -depth 10 | select  actionLink, actionVersion)
    $deprecated = (Get-Content $deprecatedPath | convertfrom-Json -depth 10 | select  actionLink, actionVersion)

    $outputs = $outputs | select  actionLink, actionVersion

    $numDeprecated = 0

    $deprecatedOutputs = @()

    foreach($output in $outputs){
        Write-Verbose "Processing $($output.actionLink) version $($output.actionVersion)"

        $actionVersions = ($deprecated | where actionLink -eq $output.actionLink)
        if ($actionVersions) {
            Write-Host "Version: $($actionVersions.actionVersion) of action $($output.actionLink) is deprecated."
            Write-Host "Use one of the following versions:"
            $options = $approved | where actionLink -eq $actionVersions.actionLink
            Write-Host $options.actionVersion
            $deprecatedOutputs += $actionVersions
            $numDeprecated++
        }
    }

    if ($deprecatedOutputs.Count -gt 0) {
        Write-Host "There are $numDeprecated actions deprecated. Use suggested versions instead."
        return $deprecatedOutputs | select -Unique
    } else {
        Write-Host "No deprecated actions found."
    }

}
