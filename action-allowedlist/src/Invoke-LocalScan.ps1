# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

<#
.SYNOPSIS
    Use for "localhost" execution of the approved Actions review.
#>

param(
    # The repository directory to scan
    [Parameter(Mandatory=$True)]
    [string]
    $RepoDirectory
)


Import-Module ./action-loader.psm1 -DisableNameChecking -Force
Import-Module ./action-allowedlist.psm1 -DisableNameChecking -Force
Import-Module ./action-deprecatedlist.psm1 -DisableNameChecking -Force

$actionsFound = LoadAllUsedActions -RepoPath $RepoDirectory
$unapproved = CheckIfActionsApproved -outputs $actionsFound -approvedPath "$($PSScriptRoot)/../approved.json"
$unapproved | Out-Host

$deprecated = CheckIfActionsDeprecated -outputs $actionsFound -approvedPath "$($PSScriptRoot)/../approved.json" -deprecatedPath "$($PSScriptRoot)/../deprecated.json"
$deprecated | Out-Host

