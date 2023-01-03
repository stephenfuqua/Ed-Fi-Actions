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

    Write-Information "Checking if used actions are deprecated"

    $approved = (Get-Content $approvedPath | ConvertFrom-Json -depth 10 | Select-Object  actionLink, actionVersion)
    $deprecated = (Get-Content $deprecatedPath | Convertfrom-Json -depth 10 | Select-Object  actionLink, actionVersion)

    $outputs = $outputs | Select-Object actionLink, actionVersion

    $numDeprecated = 0

    $deprecatedOutputs = @()

    foreach($output in $outputs){
        Write-Verbose "Processing $($output.actionLink) version $($output.actionVersion)"

        $actionVersions = ($deprecated | Where-Object actionLink -eq $output.actionLink)
        if ($actionVersions) {
            Write-Information"Version: $($actionVersions.actionVersion) of action $($output.actionLink) is deprecated."
            Write-Information "Use one of the following versions:"
            $options = $approved | Where-Object actionLink -eq $actionVersions.actionLink
            Write-Information $options.actionVersion
            $deprecatedOutputs += $actionVersions
            $numDeprecated++
        }
    }

    if ($deprecatedOutputs.Count -gt 0) {
        Write-Information "There are $numDeprecated actions deprecated. Use suggested versions instead."
        return $deprecatedOutputs | Select-Object -Unique
    } else {
        Write-Information "No deprecated actions found."
    }

}
