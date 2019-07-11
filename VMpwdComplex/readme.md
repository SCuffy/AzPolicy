# Readme

## Purpose
This PowerShell script is designed to audit a setting inside Windows Server virtual machines on Microsoft Azure, namely that the password complexity setting is enabled. The script may be modified to deploy any other built-in Azure Policy for VMs.
It will also check for the required corresponding VM extension and deploy that, if missing.

## Running the script
This script includes a required resource group name filter. It must be run with a filtering parameter supplied and will then execute only on resource groups that have that parameter in their name.

e.g. .\policyAuditVMPwdComplex.ps1 -ResourceGroupNameFilter "SVM"

Special thanks to Neil Peterson for his help with this script.
