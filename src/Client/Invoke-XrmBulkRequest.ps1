<#
    .SYNOPSIS
    Execute Multiple Organization Request.
#>
function Invoke-XrmBulkRequest {
    [CmdletBinding()]
    [OutputType([Microsoft.Xrm.Sdk.OrganizationResponse])]
    param
    (        
        [Parameter(Mandatory = $false, ValueFromPipeline)]
        [Microsoft.Xrm.Tooling.Connector.CrmServiceClient]
        $XrmClient = $Global:XrmClient,

        [Parameter(Mandatory = $true)]
        [Microsoft.Xrm.Sdk.OrganizationRequest[]]
        $Requests,

        [Parameter(Mandatory = $false)]
        [bool]
        $ContinueOnError = $false,

        [Parameter(Mandatory = $false)]
        [bool]
        $ReturnResponses = $false
    )
    begin {   
        $StopWatch = [System.Diagnostics.Stopwatch]::StartNew(); 
        Trace-XrmFunction -Name $MyInvocation.MyCommand.Name -Stage Start -Parameters ($MyInvocation.MyCommand.Parameters); 
    }    
    process {

        $multipleRequest = New-Object "Microsoft.Xrm.Sdk.Messages.ExecuteMultipleRequest";
        $multipleRequest.Settings = New-Object "Microsoft.Xrm.Sdk.ExecuteMultipleSettings";
        $multipleRequest.Settings.ContinueOnError = $ContinueOnError;
        $multipleRequest.Settings.ReturnResponses = $ReturnResponses;

        $multipleRequest.Requests = New-Object "Microsoft.Xrm.Sdk.OrganizationRequestCollection";
        foreach ($request in $requests) {
            $multipleRequest.Requests.Add($request);
        }
        $response = Invoke-XrmRequest -XrmClient $XrmClient -Request $multipleRequest;
        return $response;
    }
    end {
        $StopWatch.Stop();
        Trace-XrmFunction -Name $MyInvocation.MyCommand.Name -Stage Stop -StopWatch $StopWatch;
    }    
}

Export-ModuleMember -Function Invoke-XrmBulkRequest -Alias *;