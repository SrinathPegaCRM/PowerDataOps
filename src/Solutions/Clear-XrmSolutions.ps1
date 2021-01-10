<#
    .SYNOPSIS
    Select solutions to uninstall
#>
function Clear-XrmSolutions {
    [CmdletBinding()]
    param
    (        
        [Parameter(Mandatory = $false, ValueFromPipeline)]
        [Microsoft.Xrm.Tooling.Connector.CrmServiceClient]
        $XrmClient = $Global:XrmClient,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Columns = @("solutionid", "uniquename","friendlyname","version","ismanaged","installedon","createdby","publisherid","modifiedon","modifiedby"),
        
        [Parameter(Mandatory = $false)]
        [int]
        $TimeOutInMinutes = 45
    )
    begin {   
        $StopWatch = [System.Diagnostics.Stopwatch]::StartNew(); 
        Trace-XrmFunction -Name $MyInvocation.MyCommand.Name -Stage Start -Parameters ($MyInvocation.MyCommand.Parameters); 
    }    
    process {
        
        $solutions = Get-XrmSolutions -XrmClient $XrmClient -Columns $Columns;
        $solutionsToRemove = $solutions | Out-GridView -OutputMode Multiple;
                
        $XrmClient | Set-XrmClientTimeout -DurationInMinutes $TimeOutInMinutes;

        ForEach-ObjectWithProgress -Collection $solutionsToRemove -OperationName "Uninstall solutions" -ScriptBlock {
            param($solution)

            Write-HostAndLog "  > Removing solution " -NoNewline -NoTimeStamp -ForegroundColor Gray;
            Write-HostAndLog $solution.friendlyname -NoNewline -NoTimeStamp -ForegroundColor Yellow;
            Write-HostAndLog " ..." -NoNewline -NoTimeStamp -ForegroundColor Gray;

            $stopWatch = [System.Diagnostics.Stopwatch]::StartNew();
            try
            {
                $solutionToDelete = New-XrmEntity -LogicalName "solution" -Id $solution.solutionid;
                $XrmClient | Remove-XrmRecord -Record $solutionToDelete;
                $stopWatch.Stop();
                
                Write-Host "[OK] (Duration = $($stopWatch.Elapsed.ToString("g")))" -ForegroundColor Green;
            }
            catch
            {
                $stopWatch.Stop();
                Write-Host "[KO : $($_.Exception.Message)] (Duration = $($stopWatch.Elapsed.ToString("g")))" -ForegroundColor Red;
            }
        }
        
        $XrmClient | Set-XrmClientTimeout -Revert;
    }
    end {
        $StopWatch.Stop();
        Trace-XrmFunction -Name $MyInvocation.MyCommand.Name -Stage Stop -StopWatch $StopWatch;
    }    
}

Export-ModuleMember -Function Clear-XrmSolutions -Alias *;