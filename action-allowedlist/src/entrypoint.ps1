# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

Import-Module /src/action-loader.psm1 -DisableNameChecking
Import-Module /src/allowed-action-analyzer.psm1 -DisableNameChecking
Import-Module /src/logging.psm1

$actionsFound = Get-AllUsedActions -RepoPath $pwd

Invoke-ValidateActions -ActionsConfiguration $actionsFound -approvedPath "$($PSScriptRoot)/../approved.json"

Get-DebugLog | ForEach-Object {
    Write-Debug $_
}
Get-InfoLog | ForEach-Object {
    Write-Output $_
}
Get-WarnLog | ForEach-Object {
    Write-Warning $_
}
$errFound = $False
Get-ErrLog | ForEach-Object {
    Write-Error $_
    $errFound = $True
}

if ($errFound) {
    exit 1
}

exit 0
