# Create Browser shortcut and push to desktop
# https://www.ghacks.net/2013/10/06/list-useful-google-Browser-command-line-switches/
function Add-BrowserShortcut {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $BrowserShortCutsPath,

        [Parameter(Mandatory = $true)]
        [string]
        $BrowserAppPath,

        [Parameter(Mandatory = $true)]
        [string]
        $ProfileName
    )    

    Write-HostAndLog "Add browser shortcut to '$BrowserShortCutsPath'... " -NoNewline -ForegroundColor Gray;
    
    $name = $ProfileName.Replace("Profile ", "");    
    $shortcutPath = "$($BrowserShortCutsPath)\$($name).lnk";
    # TODO : Check if shortcut exists before
    $arguments = " --profile-directory=`"$($ProfileName)`" ";

    $shell = New-Object -ComObject WScript.Shell;
    $shortcut = $shell.CreateShortcut($shortcutPath);
    $shortcut.TargetPath = $BrowserAppPath;
    $shortcut.Arguments = $arguments;
    $shortcut.Save();
    Write-HostAndLog "[OK]" -ForegroundColor Green -NoTimeStamp;
}

function Set-BrowserFavoriteBarEnabled {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ProfilePath,

        [Parameter(Mandatory = $true)]
        [string]
        $ProfileName
    )    

    Write-HostAndLog "Configure browser favorite bar... " -NoNewline -ForegroundColor Gray;
    $preferencesFilePath = "$ProfilePath\Preferences";
    $preferencesFileContent = [IO.File]::ReadAllText($preferencesFilePath);
    $preferencesJson = $preferencesFileContent | ConvertFrom-Json;
    
    $bookmark_bar = ConvertFrom-Json '{ "show_on_all_tabs": true }';

    $preferencesJson.profile.name = $ProfileName;
    
    $preferencesJson | Add-Member -MemberType NoteProperty -Name bookmark_bar -Value $bookmark_bar -ErrorAction Ignore;     
    $preferencesJson | ConvertTo-Json -Depth 32 | Out-File -FilePath $preferencesFilePath -Encoding utf8 -Force;
    Write-HostAndLog "[OK]" -ForegroundColor Green -NoTimeStamp;
}

function Start-Browser {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $BrowserAppPath,

        [Parameter(Mandatory = $true)]
        [string]
        $ProfileName
    )    

    Write-HostAndLog "Starting browser... " -NoNewline -ForegroundColor Gray;
    $arguments = " --profile-directory=`"$($ProfileName)`" ";
    $proc = Start-Process -FilePath $BrowserAppPath -ArgumentList $arguments -PassThru;
    Write-HostAndLog "[OK]" -ForegroundColor Green -NoTimeStamp;
}

function Add-ChromeExtension {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ExtensionName
    )  
    
    Write-HostAndLog "Add Chrome extension '$ExtensionName' ... " -NoNewline -ForegroundColor Gray;
    New-Item -Path "HKCU:\Software\Google\Chrome\Extensions" -Name $ExtensionName -Force | Out-Null;
    New-ItemProperty -Path "HKCU:\Software\Google\Chrome\Extensions\$ExtensionName" -Name "update_url" -Value "https://clients2.google.com/service/update2/crx" -PropertyType String -Force | Out-Null;
    Write-HostAndLog "[OK]" -ForegroundColor Green -NoTimeStamp;
}

function Add-EdgeExtension {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ExtensionName
    )  
    
    Write-HostAndLog "Add Chrome extension '$ExtensionName' ... " -NoNewline -ForegroundColor Gray;
    New-Item -Path "HKCU:\SOFTWARE\Microsoft\Edge\Extensions" -Name $ExtensionName -Force | Out-Null;
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Edge\Extensions\$ExtensionName" -Name "update_url" -Value "https://clients2.google.com/service/update2/crx" -PropertyType String -Force | Out-Null;
    Write-HostAndLog "[OK]" -ForegroundColor Green -NoTimeStamp;
}

class BookMark {
    [String]$date_added = "13244290348204144";
    #[String]$date_modified = "13244290348204144";
    [String]$guid = [guid]::NewGuid();
    [String]$id = [Random]::new().Next(1, 999).ToString();
    [String]$name;
    [String]$type;

    BookMark () {
    }

    [void] AddChild([BookMark] $bookmark) {
        $this.children += $bookmark;    
    }

    [BookMark] AddChild([String]$Name) {
        $bookmark = [FolderBookMark]::New($Name)
        $this.children += $bookmark;  
        return $bookmark;  
    }

    [void] AddChild([String]$Name, [String]$Url) {
        $bookmark = [UrlBookMark]::New($Name, $Url)
        $this.children += $bookmark;    
    }

    [BookMark] GetChild([String]$Name) {
        $bookmark = $this.children | Where-Object -Property name -EQ $Name;
        return $bookmark;  
    }
}

class UrlBookMark :  BookMark {
    [String]$url;
    
    UrlBookMark ([String]$Name, [String]$Url) {
        $this.name = $Name;
        $this.url = $Url;
        $this.type = "url";
    }
}

class FolderBookMark :  BookMark {
    [BookMark[]]$children = @();
    
    FolderBookMark ([String]$Name) {
        $this.name = $Name;
        $this.type = "folder";
    }
}

function Get-DefaultBookmark {    
    Write-HostAndLog "Get default favorites... " -NoNewline -ForegroundColor Gray;
    $mainFolder = [FolderBookMark]::New("!NEW FAVORITES!");

    $o365Folder = $mainFolder.AddChild("O365");
    $o365Folder.AddChild("Admin", "https://admin.microsoft.com/AdminPortal/Home#/homepage");
    $o365Folder.AddChild("O365", "https://www.office.com");
    $o365Folder.AddChild("OWA", "https://outlook.office365.com/mail/inbox");
    $o365Folder.AddChild("Teams", "https://teams.microsoft.com");

    $powerPlatformFolder = $mainFolder.AddChild("Power Platform");
    $powerPlatformFolder.AddChild("Power Platform Admin", "https://admin.powerplatform.microsoft.com");
    $powerPlatformFolder.AddChild("PowerApps Maker", "https://make.powerapps.com");
    $powerPlatformFolder.AddChild("Power Automate (Flow)", "https://flow.microsoft.com/");
    $powerPlatformFolder.AddChild("Power BI", "https://app.powerbi.com");
    
    $cdsFolder = $mainFolder.AddChild("Dataverse");
    $cdsFolder.AddChild("Power Platform Admin", "https://admin.powerplatform.microsoft.com");
    $cdsFolder.AddChild("PowerApps Maker", "https://make.powerapps.com");
    
    $azureFolder = $mainFolder.AddChild("Azure");
    $azureFolder.AddChild("Azure", "https://portal.azure.com");
    $azureFolder.AddChild("Azure DevOps", "https://dev.azure.com");

    Write-HostAndLog "[OK]" -ForegroundColor Green -NoTimeStamp;
    return $mainFolder;
}

function Save-BookMark {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ProfilePath,

        [Parameter(Mandatory = $true)]
        [FolderBookMark]
        $RootBookmark
    )  
    
    $bookmarksFilePath = "$ProfilePath\Bookmarks";
    Write-HostAndLog "Saving favorites to '$bookmarksFilePath'... " -NoNewline -ForegroundColor Gray;

    if (-not (Test-Path -Path $bookmarksFilePath)) {
        $bookmarkDefaultContent = '{
            "checksum": "4ff448b8f4bc5ef36f5e05aab3218bca",
            "roots": {
                "bookmark_bar": {
                    "children": [  ],
                    "date_added": "13231958894390217",
                    "date_modified": "13231960751123696",
                    "guid": "00000000-0000-4000-A000-000000000002",
                    "id": "1",
                    "name": "Barre de favoris",
                    "type": "folder"
                },
                "other": {
                    "children": [  ],
                    "date_added": "13231958894390228",
                    "date_modified": "0",
                    "guid": "00000000-0000-4000-A000-000000000003",
                    "id": "2",
                    "name": "Autres favoris",
                    "type": "folder"
                },
                "synced": {
                    "children": [  ],
                    "date_added": "13231958894390231",
                    "date_modified": "0",
                    "guid": "00000000-0000-4000-A000-000000000004",
                    "id": "3",
                    "name": "Favoris sur mobile",
                    "type": "folder"
                }
            },
            "version": 1
            }';
        $bookmarkDefaultContent | Out-File -FilePath $bookmarksFilePath -Encoding utf8 -Force;
    }

    $bookmarkContent = [IO.File]::ReadAllText($bookmarksFilePath);
    $bookmark = $bookmarkContent | ConvertFrom-Json;

    # Configure chrome : Add favorites
    $bookmark.roots.bookmark_bar.children += $RootBookmark;
    $bookmarkContent = $bookmark | ConvertTo-Json -Depth 32;
    $bookmarkContent | Out-File -FilePath $bookmarksFilePath -Encoding utf8 -Force;
    Write-HostAndLog "[OK]" -ForegroundColor Green -NoTimeStamp;
}

function Get-XrmFavorites {
    param (
        [Parameter(Mandatory = $true)]
        [FolderBookMark]
        $RootBookmark,

        [Parameter(Mandatory = $false)]
        [String]
        $OverrideConnectionStringFormat = "",

        [Parameter(Mandatory = $false)]
        [String[]]
        $AppIgnoredList = @()
    )      

    Write-HostAndLog "Retrieving Dataverse links... " -ForegroundColor Gray;
    $d365Folder = $RootBookmark.GetChild("Dataverse");

    $instances = Get-XrmInstances;

    $queryApps = New-Object "Microsoft.Xrm.Sdk.Query.QueryExpression" -ArgumentList "appmodule";
    $queryApps.Columnset.AddColumn("uniquename");
    $queryApps.Columnset.AddColumn("name");
    $queryApps.Criteria.AddCondition("clienttype", [Microsoft.Xrm.Sdk.Query.ConditionOperator]::Equal, 4);

    # Retrieve Dataverse apps
    foreach ($instance in $instances) {
        Write-HostAndLog "  > Connecting to " -NoNewline -NoTimeStamp -ForegroundColor Gray;
        Write-HostAndLog $instance.DisplayName -NoNewline -NoTimeStamp -ForegroundColor Yellow;
        Write-HostAndLog " instance..." -NoNewline -NoTimeStamp -ForegroundColor Gray;

        $crmConnectionString = $instance | Out-XrmConnectionString;
        
        if (-not [string]::IsNullOrWhiteSpace($OverrideConnectionStringFormat)) {
            $crmConnectionString = $OverrideConnectionStringFormat.Replace("{Url}", $instance.Url);
        }

        try {
            $xrmClient = New-XrmClient -ConnectionString $crmConnectionString;
            $url = $instance.Url;
            $instanceFolder = $d365Folder.AddChild($instance.DisplayName);
            $instanceFolder.AddChild("Admin", "$url/main.aspx?settingsonly=true");

            $apps = $xrmClient | Get-XrmMultipleRecords -Query $queryApps;
            foreach ($app in $apps) {
                $appName = $app.uniquename;
                if ($AppIgnoredList.Contains($appName)) {
                    continue;
                }
                # https://*.dynamics.com/Apps/uniquename/*uniquename*
                $appUrl = "$url/Apps/uniquename/$($appName)";
                $instanceFolder.AddChild($app.name, $appUrl);
            }
            Write-HostAndLog "[OK]" -NoTimeStamp -ForegroundColor Green;
        }
        catch {
            Write-HostAndLog "[KO] => Reason: $($_.Exception.Message))" -ForegroundColor Red;
            continue;
        }
    }
    return $RootBookmark;
}

<#
    .SYNOPSIS
    Configure browser according to Dataverse environnements.

    .DESCRIPTION
    Provision or update Chrome or Edge (based on chromium) profile with all dataverse apps and Power Platform usefull links.

    .PARAMETER ProfileName
    Name of existing or new browser profile.
    
    .PARAMETER BrowserShortCutsPath
    Folder path where to store profile shortcut (.lnk).
    
    .PARAMETER IsChrome
    Indicates if browser is Google Chrome. (Default: true)
    Use false to switch to Edge.
    
    .PARAMETER OverrideConnectionStringFormat
    Provide the ConnectionString template in order to access to instances with different credentials.

    .PARAMETER Extensions
    Define chrome extensions identifiers to install.

    .PARAMETER AppIgnoredList
    Filter app list during favorite provisionning.

    .PARAMETER ChromeDefaultProfilesPath
    Folder path where to store Chrome profile folder.

    .PARAMETER ChromeX64AppPath
    Chrome executable path for 64 bits version.

    .PARAMETER ChromeX32AppPath
    Chrome executable path for 32 bits version.

    .PARAMETER EdgeDefaultProfilesPath
    Folder path where to store Edge profile folder.

    .PARAMETER EdgeAppPath
    Edge executable path.
#>
function Export-XrmConnectionToBrowser {
    [CmdletBinding()]
    param
    (        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]   
        [String]
        $ProfileName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]   
        [String]
        $BrowserShortCutsPath,

        [Parameter(Mandatory = $false)]
        [bool]
        $IsChrome = $true,       

        [Parameter(Mandatory = $false)]
        [String]
        $OverrideConnectionStringFormat = "",

        [Parameter(Mandatory = $false)]
        [string[]]
        $Extensions = @("eadknamngiibbmjdfokmppfooolhdidc", "bjnkkhimoaclnddigpphpgkfgeggokam"),        

        [Parameter(Mandatory = $false)]
        [String[]]
        $AppIgnoredList = @(),

        [Parameter(Mandatory = $false)]
        [string]
        $ChromeDefaultProfilesPath = "$($env:LOCALAPPDATA)\Google\Chrome\User Data\",

        [Parameter(Mandatory = $false)]
        [string]
        $ChromeX64AppPath = "C:\Program Files\Google\Chrome\Application\chrome.exe",

        [Parameter(Mandatory = $false)]
        [string]
        $ChromeX32AppPath = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        
        [Parameter(Mandatory = $false)]
        [string]
        $EdgeDefaultProfilesPath = "$($env:LOCALAPPDATA)\Microsoft\Edge SxS\User Data\",

        [Parameter(Mandatory = $false)]
        [string]
        $EdgeAppPath = "$($env:LOCALAPPDATA)\Microsoft\Edge SxS\Application\msedge.exe"

    )
    begin {   
        $StopWatch = [System.Diagnostics.Stopwatch]::StartNew(); 
        Trace-XrmFunction -Name $MyInvocation.MyCommand.Name -Stage Start -Parameters ($MyInvocation.MyCommand.Parameters); 
    }    
    process {

        if ($isChrome) {
            $browserProfilesPath = $ChromeDefaultProfilesPath;
            if (Test-Path -Path $ChromeX64AppPath) {
                $browserAppPath = $ChromeX64AppPath;
            }
            elseif (Test-Path -Path $ChromeX32AppPath) {
                $browserAppPath = $ChromeX32AppPath;
            }
            else {
                throw "Chrome application path not found!";
            }
        }
        else {
            $browserProfilesPath = $EdgeDefaultProfilesPath;
            $browserAppPath = $EdgeAppPath;
        }

        # Provision profile folder
        $profilePath = [IO.Path]::Combine($browserProfilesPath, $profileName);
        if (-not(Test-Path -Path $profilePath)) {
            New-Item -ItemType Directory -Path $browserProfilesPath -Name $profileName -Force -ErrorAction Ignore | Out-Null;
        }

        # Create shrotcut
        Add-BrowserShortcut -BrowserShortCutsPath $BrowserShortCutsPath -BrowserAppPath $browserAppPath -ProfileName $profileName;

        # Start browser for folder initialization
        Start-Browser -BrowserAppPath $browserAppPath -ProfileName $profileName;
        Start-Sleep -Seconds 5;
        
        # Configure chrome : Favorite bar
        Set-BrowserFavoriteBarEnabled -ProfileName $profileName -ProfilePath $profilePath;
        
        # Configure chrome : Extensions
        $Extensions | ForEach-Object {
            if ($isChrome) {
                Add-ChromeExtension -ExtensionName $_;
            }
            else {        
                Add-EdgeExtension -ExtensionName $_;
            }
        }

        # Configure chrome : Add favorites
        $rootBookmark = Get-DefaultBookmark;
        
        # Retrieve CDS instances and add links to bookmark        
        $rootBookmark = Get-XrmFavorites -RootBookmark $rootBookmark -OverrideConnectionStringFormat $OverrideConnectionStringFormat -AppIgnoredList $AppIgnoredList;

        # Save favorites
        Save-BookMark -ProfilePath $profilePath -RootBookmark $rootBookmark;

        # Fix profile name
        $browserStateFilePath = "$browserProfilesPath\Local State";
        $localState = [IO.File]::ReadAllText($browserStateFilePath) | ConvertFrom-Json;
        $localState.profile.info_cache.$profileName.name = $profileName;
        $localState | ConvertTo-Json -Depth 32 | Out-File -FilePath $browserStateFilePath -Encoding utf8 -Force;
    }
    end {
        $StopWatch.Stop();
        Trace-XrmFunction -Name $MyInvocation.MyCommand.Name -Stage Stop -StopWatch $StopWatch;
    }    
}

Export-ModuleMember -Function Export-XrmConnectionToBrowser -Alias *;