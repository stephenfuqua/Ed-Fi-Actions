# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

Import-Module /src/action-loader.psm1 -DisableNameChecking
Import-Module /src/allowed-action-analyzer.psm1 -DisableNameChecking
Import-Module /src/deprecated-action-analyzer.psm1 -DisableNameChecking

$actionsFound = LoadAllUsedActions -RepoPath $pwd
$unapproved = CheckIfActionsApproved -outputs $actionsFound
$jsonUnapprovedResults = ($unapproved | ConvertTo-Json)
$jsonUnapprovedResults | out-file ./unapproved-actions.json

Write-Output "name=unapproved-actions::<<EOF" >> $GITHUB_OUTPUT
Write-Output "$jsonUnapprovedResults" >> $GITHUB_OUTPUT
Write-Output "EOF" >> $GITHUB_OUTPUT

$deprecated = CheckIfActionsDeprecated -outputs $actionsFound
$jsonDeprecatedResults = ($deprecated | ConvertTo-Json)
$jsonDeprecatedResults | out-file ./deprecated-actions.json

Write-Output "name=deprecated-actions::<<EOF" >> $GITHUB_OUTPUT
Write-Output "$jsonDeprecatedResults" >> $GITHUB_OUTPUT
Write-Output "EOF" >> $GITHUB_OUTPUT


if ($unapproved.Count -gt 0) {
    Write-Error "Repo contains unapproved actions!"
    exit 1
}else{
    exit 0
}
