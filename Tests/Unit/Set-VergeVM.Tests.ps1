#Requires -Modules Pester

<#
.SYNOPSIS
    Unit tests for PSVergeOS Set-VergeVM cmdlet.

.DESCRIPTION
    Tests for Set-VergeVM cmdlet.
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

Describe 'Set-VergeVM' {
    BeforeAll {
        Mock -ModuleName PSVergeOS Invoke-VergeAPI -ParameterFilter { $Method -eq 'GET' } {
            @(
                [PSCustomObject]@{
                    '$key'       = 1
		    name         = 'TestVM'
		    status       = 'running'
		    allow_export = $true
		    is_snapshot  = $False
		}
#                [PSCustomObject]@{
#		    '$key'       = 2
#		    name         = 'TestVM2'
#		    status       = 'stopped'
#		    allow_export = $False
#		    is_snapshot  = $False
#                }
            )
        }
	
	Mock -ModuleName PSVergeOS Invoke-VergeAPI -ParameterFilter { $Method -eq 'PUT' } { }
    }

#    Context 'Parameter Validation' {
#	It 'Should require AllowExport to be a boolean' {
#	    { Set-VergeVM -key 1 -AllowExport 'true' } | Should throw
#	}
#    }

    Context 'Output' {
        It 'Includes the allow_export = <value> field in the API call' -ForEach @(
	    @{ Value = $True }
	    @{ Value = $False }
	) {
            Set-VergeVM -key 1 -AllowExport $Value
            
	    Should -Invoke -ModuleName PSVergeOS Invoke-VergeAPI -ParameterFilter {
		$Method -eq 'PUT' -and
		$Endpoint -eq 'vms/1' -and 
		$Body.ContainsKey('allow_export') -and 
		$Body.allow_export -eq $Value
	    }

	}

	It 'Does not include the allow_export field if it is not being set' {
	    Set-VergeVM -Key 1 -Description 'New description'

	    Should -Invoke -ModuleName PSVergeOS Invoke-VergeAPI -ParameterFilter {
		$Method -eq 'PUT' -and
		$Endpoint -eq 'vms/1' -and
		-not $Body.ContainsKey('allow_export')
	    }
	}
    }
}
