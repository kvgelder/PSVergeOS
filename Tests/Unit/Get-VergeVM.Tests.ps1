#Requires -Modules Pester

<#
.SYNOPSIS
    Unit tests for PSVergeOS Get-VergeVM cmdlet.

.DESCRIPTION
    Tests for Get-VergeVM cmdlet.
#>

BeforeAll {
    # Import the module
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '../../PSVergeOS.psd1'
    Import-Module $ModulePath -Force

    InModuleScope PSVergeOS {
        $script:DefaultConnection = [PSCustomObject]@{ Server = 'test.local' }
    }
}

AfterAll {
    # Clean up
    Remove-Module PSVergeOS -Force -ErrorAction SilentlyContinue
}

Describe 'Get-VergeVM' {
    BeforeAll {
        $vmFixture = Get-Content "$PSScriptRoot/Fixtures/vms.json" -Raw | ConvertFrom-Json
        Mock -ModuleName PSVergeOS Invoke-VergeAPI -ParameterFilter { $Method -eq 'GET' } { $vmFixture }
        
#        Mock -ModuleName PSVergeOS Invoke-VergeAPI {
#            @(
#                [PSCustomObject]@{
#                    '$key'          = 1
#                    name            = 'TestVM'
#                    status          = 'running'
#                    allow_export    = $True
#                }
#                [PSCustomObject]@{
#                    '$key'          = 2
#                    name            = 'TestVM2'
#                    status          = 'stopped'
#                    allow_export    = $False
#                }
#            )
#        }
    }

    Context 'Output' {
        It 'Returns all VMs when no filter is applied' {
            (Get-VergeVM).Count | Should -Be 2
        }

        It 'Maps allow_export to AllowExport' {
            $vms = Get-VergeVM

            ($vms | Where-Object Name -eq 'LAB-VM1').AllowExport    | Should -Be $True
            ($vms | Where-Object Name -eq 'LAB-VM2').AllowExport    | Should -Be $False
        }

        It 'Requests the allow_export field from the API' {
            Get-VergeVM | Out-Null

            Should -Invoke -ModuleName PSVergeOS Invoke-VergeAPI -ParameterFilter {
                ($Query.fields -split ',') -contains 'allow_export'
            }
        }
    }
}
