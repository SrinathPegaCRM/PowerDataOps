<#
    .SYNOPSIS
    Transform Entity Collection to custom object collection.

    .DESCRIPTION
    Represent Entity objects to custom objects array.

    .PARAMETER Record
    Entity record / table rows (Entity array).
#>
function ConvertTo-XrmObjects {
    [CmdletBinding()]
    [OutputType([PsCustomObject[]])]
    param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [Microsoft.Xrm.Sdk.Entity[]]
        $InputObject
    )
    begin {          
        $records = @();

        $StopWatch = [System.Diagnostics.Stopwatch]::StartNew(); 
        Trace-XrmFunction -Name $MyInvocation.MyCommand.Name -Stage Start -Parameters ($MyInvocation.MyCommand.Parameters); 
    }    
    process {
        $records += $InputObject | ConvertTo-XrmObject;
    }
    end {
        $records;

        $StopWatch.Stop();
        Trace-XrmFunction -Name $MyInvocation.MyCommand.Name -Stage Stop -StopWatch $StopWatch;
    }
}

Export-ModuleMember -Function ConvertTo-XrmObjects -Alias *;