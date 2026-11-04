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
}

AfterAll {
    # Clean up
    Remove-Module PSVergeOS -Force -ErrorAction SilentlyContinue
}

Describe 'Get-VergeVM' {
    BeforeAll {
        Mock -ModuleName PSVergeOS Invoke-VergeAPI {
            @(
                [PSCustomObject]@{
                    Key             = 1
                    Name            = 'TestVM'
                    Description     = 'TestVM Desc'
                    PowerState      = 'Running'
                    Status          = 'running'
                    IsRunning       = $True
                    CPUCores        = 4
                    RAM             = 8192
                    OSFamily        = 'linux'
                    GuestAgent      = $True
                    UEFI            = $False
                    SecureBoot      = $False
                    MachineType     = 'yottabyte'
                    IsQ35           = $True
                    Enabled         = $True
                    IsSnapshot      = $False
                    Cluster         = 'TEST_CLUSTER'
                    ClusterKey      = 1
                    Node            = 'node1'
                    NodeKey         = 1
                    HAGroup         = $null
                    SnapshotProfile = $null
                    MachineKey      = 1
                    AllowExport     = $True
                }
                [PSCustomObject]@{
                    Key             = 2
                    Name            = 'TestVM2'
                    Description     = 'TestVM2 Desc'
                    CPUCores        = 2
                    RAM             = 4096
                    AllowExport     = $False
                }
            }
        )
    }

    Context 'Output' {
        It 'Returns all VMs when no filter is applied' {
            Get-VergeVM.Count | Should -Be 2
        }

        It 'Maps the API fields to PSObject properties' {
            $vm = Get-VergeVM -key 1

            $vm.Key             | Should -Be 1
            $vm.Name            | Should -Be 'TestVM'
            $vm.Description     | Should -Be 'TestVM Desc'
            $vm.PowerState      | Should -Be 'Running'
            $vm.Status          | Should -Be 'running'
            $vm.IsRunning       | Should -Be $True
            $vm.CPUCores        | Should -Be 4
            $vm.RAM             | Should -Be 8192
            $vm.OSFamily        | Should -Be 'linux'
            $vm.GuestAgent      | Should -Be $True
            $vm.UEFI            | Should -Be $False
            $vm.SecureBoot      | Should -Be $False
            $vm.MachineType     | Should -Be 'yottabyte'
            $vm.IsQ35           | Should -Be $True
            $vm.Enabled         | Should -Be $True
            $vm.IsSnapshot      | Should -Be $False
            $vm.Cluster         | Should -Be 'TEST_CLUSTER'
            $vm.ClusterKey      | Should -Be 1
            $vm.Node            | Should -Be 'node1'
            $vm.NodeKey         | Should -Be 1
            $vm.HAGroup         | Should -Be $null
            $vm.SnapshotProfile | Should -Be $null
            $vm.MachineKey      | Should -Be 1
            $vm.AllowExport     | Should -Be $True
        }

        It 'Filter VMs based on the AllowExport property' {
            $vm = Get-VergeVM | Where-Object AllowExport -eq $True

            $vm.Count       | Should -Be 1
            $vm.AllowExport | Should -Be $True
        }
}
