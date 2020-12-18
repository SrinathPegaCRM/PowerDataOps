<#
    .SYNOPSIS
    Create entity record in Dataverse.
#>
function Add-XrmRecord {
    [CmdletBinding()]
    [OutputType([Guid])]
    param
    (    
        [Parameter(Mandatory=$false, ValueFromPipeline)]
        [Microsoft.Xrm.Tooling.Connector.CrmServiceClient]
        $XrmClient = $Global:XrmClient,

        [Parameter(Mandatory=$true, ValueFromPipeline)]
        [Microsoft.Xrm.Sdk.Entity]
        $Record,

        [Parameter(Mandatory=$false)]
        [switch]
        $BypassCustomPluginExecution = $false
    )
    begin {   
        $StopWatch = [System.Diagnostics.Stopwatch]::StartNew(); 
        Trace-XrmFunction -Name $MyInvocation.MyCommand.Name -Stage Start -Parameters ($MyInvocation.MyCommand.Parameters);
    }    
    process {

        $request = New-XrmRequest -Name "Create";
        $request | Add-XrmRequestParameter -Name "Target" -Value $Record | Out-Null;
        if($BypassCustomPluginExecution)
        {
            $request | Add-XrmRequestParameter -Name "BypassCustomPluginExecution" -Value $true | Out-Null;
        }

        $response = Invoke-XrmRequest -XrmClient $XrmClient -Request $request;
        $id = $response.Results["id"];
        $id;
    }
    end {
        $StopWatch.Stop();
        Trace-XrmFunction -Name $MyInvocation.MyCommand.Name -Stage Stop -StopWatch $StopWatch;
    }    
}

Export-ModuleMember -Function Add-XrmRecord -Alias *;