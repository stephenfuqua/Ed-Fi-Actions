# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

# This logging module writes messages intended for consumption by GitHub.
# https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions

$script:log = [System.Collections.ArrayList]::new()
$script:errorOccurred = $false

function Write-DebugLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string]
        $Message
    )

    $script:log.Add("::debug::$Message") | Out-Null

}

function Write-InfoLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string]
        $Message
    )

    $script:log.Add($Message) | Out-Null
}

function Write-WarnLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string]
        $Message
    )

    $script:log.Add("::warning::$Message") | Out-Null
}

function Write-ErrLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string]
        $Message
    )

    $script:errorOccurred = $True
    $script:log.Add("::error::$Message") | Out-Null
}

function Get-Log {
    $script:log
}

function Get-ErrorOccurred {
    $script:errorOccurred
}

Export-ModuleMember -Function Write-DebugLog, Write-InfoLog, Write-WarnLog, Write-ErrLog, Get-Log, Get-ErrorOccurred
