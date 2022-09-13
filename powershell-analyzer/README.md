# powershell-analyzer

Lint PowerShell scripts and modules using [PSScriptAnalyzer](https://docs.microsoft.com/en-us/powershell/module/psscriptanalyzer). This can be run locally or executed in GitHub Actions.

## Run Locally

```bash
.\analyze.ps1 -Directory /folder-or-file
```

### Options

| Parameter          | Description                                    |
| ------------- | ---------------------------------------------- |
| Directory    | Folder or Path to run analysis against. Required.    |
| SaveToFile | Save to file, or print to console. Default: Save to file |
| ResultsPath | Path to save the results. Default "./results.sarif" |
| IncludedRules | [List of rules](https://docs.microsoft.com/en-us/powershell/utility-modules/psscriptanalyzer/rules/readme?view=ps-modules) that should be included to analysis. |
| ExcludedRules | [List of rules](https://docs.microsoft.com/en-us/powershell/utility-modules/psscriptanalyzer/rules/readme?view=ps-modules) that should be excluded from analysis. |

### Result Formats

- [SARIF](https://sarifweb.azurewebsites.net/) reports
- Print to console

## Run in Action

## Example usage

Minimal uses expression to use this action:

``` yaml
- uses: ./powershell-analyzer
  name: Lint PowerShell Scripts
  id: powershell-analyzer
```

Example for calling this action from a different repository:

```yml
- uses: Ed-Fi-Alliance-OSS/Ed-Fi-Actions/powershell-analyzer@latest
  name: Lint PowerShell Scripts
  id: powershell-analyzer
```

❗ In this one case, it is appropriate to use a tag ("latest") instead of a
commit hash. Otherwise we have a chicken-and-egg problem: the approved list of
actions would need to know the has for the commit that saves the update to the
action.

## Full example

This example shows how to use the action to get a json file with all the used
actions in an organization. The json file is uploaded as an artefact in the
third step.

``` yaml
jobs:
  load-all-used-actions:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
      - uses: Ed-Fi-Alliance-OSS/Ed-Fi-Actions/powershell-analyzer@latest
        name: Lint PowerShell Scripts
        id: powershell-analyzer
```

## Outputs

TBD
