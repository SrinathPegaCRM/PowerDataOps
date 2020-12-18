<#
    .SYNOPSIS
    Clear active customizations for given solution components
#>
function Clear-XrmActiveCustomizations {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, ValueFromPipeline)]
        [Microsoft.Xrm.Tooling.Connector.CrmServiceClient]
        $XrmClient = $Global:XrmClient,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $SolutionUniqueName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [int[]]
        $ComponentTypes = @(26,59,60,61,62,300)
    )
    begin {   
        $StopWatch = [System.Diagnostics.Stopwatch]::StartNew(); 
        Trace-XrmFunction -Name $MyInvocation.MyCommand.Name -Stage Start -Parameters ($MyInvocation.MyCommand.Parameters); 
    }    
    process {
        $components = Get-XrmSolutionComponents -XrmClient $XrmClient -SolutionUniqueName $SolutionUniqueName -ComponentTypes $ComponentTypes;
        ForEach-ObjectWithProgress -Collection $components -OperationName "Clearing active customizations for $SolutionUniqueName solution" -ScriptBlock {
            param($component)

            $componentName = Get-XrmSolutionComponentName -SolutionComponentType $component.componenttype_Value.Value;
            Remove-XrmActiveCustomizations -XrmClient $XrmClient -SolutionComponentName $componentName -ComponentId $component.objectid;
        }
    }
    end {
        $StopWatch.Stop();
        Trace-XrmFunction -Name $MyInvocation.MyCommand.Name -Stage Stop -StopWatch $StopWatch;
    }    
}

Export-ModuleMember -Function Clear-XrmActiveCustomizations -Alias *;