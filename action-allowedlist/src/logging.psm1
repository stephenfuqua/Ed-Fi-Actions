# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

$debug = [System.Collections.ArrayList]::new()
$information = [System.Collections.ArrayList]::new()
$warning = [System.Collections.ArrayList]::new()
$err = [System.Collections.ArrayList]::new()

# This logging module writes messages intended for consumption by GitHub.
# https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions

function Write-DebugLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string]
        $Message
    )

    $debug.Add($Message) | Out-Null

}

function Get-DebugLog {
    $debug
}

function Write-InfoLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string]
        $Message
    )

    $information.Add($Message) | Out-Null
}

function Get-InfoLog {
    $information
}

function Write-WarnLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string]
        $Message
    )

    $warning.Add($Message) | Out-Null
}

function Get-WarnLog {
    $warning
}

function Write-ErrLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [string]
        $Message
    )

    $err.Add($Message) | Out-Null
}

function Get-ErrLog {
    $err
}

Export-ModuleMember -Function Write-DebugLog, Get-DebugLog, Write-InfoLog, `
    Get-InfoLog, Write-WarnLog, Get-WarnLog, Write-ErrLog, Get-ErrLog
