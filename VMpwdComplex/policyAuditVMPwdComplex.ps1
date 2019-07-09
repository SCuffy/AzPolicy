<#
 .DESCRIPTION
    Applies an Azure Policy to audit that a Windows VM enforces password complexity requirements, across multiple resource groups.

    .NOTES
    Authors: Sonia Cuff, Neil Peterson
    Intent: Sample to demonstrate Azure Policy for in-guest VM config via PowerShell
 #>

 param (
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupNameFilter
)

# Get resource groups
$ResourceGroupObjects = Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -like "*$ResourceGroupNameFilter*"}

# Get policy definitions
$PolicyDefinition1 = Get-AzPolicyDefinition | Where-Object { $_.Properties.DisplayName -eq '[Preview]: Deploy VM extension to audit Windows VM enforces password complexity requirements' }
$PolicyDefinition2 = Get-AzPolicyDefinition | Where-Object { $_.Properties.DisplayName -eq '[Preview]: Audit Windows VM enforces password complexity requirements' }

# Register resource provider for guest config support
Register-AzResourceProvider -ProviderNamespace 'Microsoft.GuestConfiguration'

# Assign policy and use the $policyDefinition to get to the roleDefinitionIds array
foreach ($ResourceGroup in $ResourceGroupObjects) {

    New-AzPolicyAssignment -Name 'audit-vm-pwdcomplex' -DisplayName '[Preview]: Audit Windows VM enforces password complexity requirements' -Scope $ResourceGroup.ResourceID -PolicyDefinition $PolicyDefinition2
    $assignment1 = New-AzPolicyAssignment -Name 'deployext-vm-pwdcomplex' -DisplayName '[Preview]: Deploy VM extension to audit Windows VM enforces password complexity requirements' -Scope $ResourceGroup.ResourceID -PolicyDefinition $PolicyDefinition1 -Location 'eastus' -AssignIdentity

    # Workaround for managed identity replication delay
    write-output "Start Sleep"
    start-sleep -Seconds 60
    write-output "End Sleep"

    $roleDefinitionIds = $PolicyDefinition1.Properties.policyRule.then.details.roleDefinitionIds

    if ($roleDefinitionIds.Count -gt 0)
    {
        $roleDefinitionIds | ForEach-Object {
            $roleDefId = $_.Split("/") | Select-Object -Last 1
            New-AzRoleAssignment -Scope $resourceGroup.ResourceId -ObjectId $assignment1.Identity.PrincipalId -RoleDefinitionId $roleDefId
        }
    }
}