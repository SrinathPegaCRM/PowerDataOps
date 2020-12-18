<#
    .SYNOPSIS
    Initialize new object that represent a Xrm Context.
#>
function New-XrmContext {
    [CmdletBinding()]
    [OutputType([PsObject])]
    param
    (
    )
    begin {  
        $StopWatch = [System.Diagnostics.Stopwatch]::StartNew(); 
        Trace-XrmFunction -Name $MyInvocation.MyCommand.Name -Stage Start -Parameters ($MyInvocation.MyCommand.Parameters); 
    }    
    process {

        $hash = @{ };
        $hash["UserId"] = [guid]::Empty;
        $hash["IsOnPremise"] = $false;
        $hash["IsOnline"] = $false;
        $hash["IsAdminConnected"] = $false;
        $hash["IsUserConnected"] = $false;
        $hash["IsDevOps"] = ($null -ne $ENV:SYSTEM_COLLECTIONID);
        $hash["CurrentConnection"] = $null;
        $hash["CurrentInstance"] = $null;

        $object = New-Object PsObject -Property $hash;
        $object;
    }
    end {
        $StopWatch.Stop();
        Trace-XrmFunction -Name $MyInvocation.MyCommand.Name -Stage Stop -StopWatch $StopWatch;
    }
}

Export-ModuleMember -Function New-XrmContext -Alias *;