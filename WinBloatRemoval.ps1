# Remove Microsoft Bloatware/Crapware
# This script is designed to remove unwanted Microsoft software from a Windows 10 system.

# Custom logging function
# This function writes logs to a specific file with a timestamp.
function Write-Log {
    param (
        # A mandatory string parameter to hold the message that will be logged.
        [Parameter(Mandatory=$true)]
        [string] $Message
    )

    # Sets the log file path where the log messages will be stored. 
    # Generally C\programdata\microsoft\...
    $logFilePath = "$($env:ProgramData)\Microsoft\RemoveW10Bloatware\RemoveW10Bloatware.log"

    # Appends the message to the log file with a timestamp.
    Add-Content -Path $logFilePath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
}

# Creates a directory and tag file to indicate the script has been executed.
# This can be useful for management through systems like Intune.
if (-not (Test-Path "$($env:ProgramData)\Microsoft\RemoveW10Bloatware")) {
    New-Item -ItemType Directory -Force -Path "$($env:ProgramData)\Microsoft\RemoveW10Bloatware" > $null
}
Set-Content -Path "$($env:ProgramData)\Microsoft\RemoveW10Bloatware\RemoveW10Bloatware.ps1.tag" -Value "Installed"

# List of built-in apps (Appx Packages) to be removed.
# These are identified by their package names.
$UninstallPackages = @(
    "Microsoft.BingWeather"
    "Microsoft.Getstarted"
    "Microsoft.GetHelp"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MixedReality.Portal"
    "Microsoft.OneConnect"
    "Microsoft.SkypeApp"
    "Microsoft.windowscommunicationsapps"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameCallableUI"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.YourPhone"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
)

# List of programs to uninstall
# This list is currently empty but can be populated with program names to be removed.
$UninstallPrograms = @(
)

# Gets currently installed Appx Packages and Provisioned Packages based on the list provided.
$InstalledPackages = Get-AppxPackage -AllUsers | Where {($UninstallPackages -contains $_.Name)}
$ProvisionedPackages = Get-AppxProvisionedPackage -Online | Where {($UninstallPackages -contains $_.DisplayName)}

# Gets the installed programs that match with the list provided.
$InstalledPrograms = Get-Package | Where {$UninstallPrograms -contains $_.Name}

# Checks each app in the list to see if it is installed or provisioned.
# Logs a warning message if an app is not found.
$UninstallPackages | ForEach {
    if (($_ -notin $InstalledPackages.Name) -and ($_ -notin $ProvisionedPackages.DisplayName)) {
        Write-Log -Message "Warning: App not found: [$_]"
    }
}

# Attempts to remove provisioned packages.
# Logs the outcome of each removal attempt.
ForEach ($ProvPackage in $ProvisionedPackages) {
    Write-Log -Message "Attempting to remove provisioned package: [$($ProvPackage.DisplayName)]..."
    Try {
        Remove-AppxProvisionedPackage -PackageName $ProvPackage.PackageName -Online -ErrorAction Stop > $null
        Write-Log -Message "Successfully removed provisioned package: [$($ProvPackage.DisplayName)]"
    }
    Catch {
        Write-Log -Message "Warning: Failed to remove provisioned package: [$($ProvPackage.DisplayName)]"
    }
}

# Attempts to remove Appx Packages.
# Logs the outcome of each removal attempt.
ForEach ($AppxPackage in $InstalledPackages) {
    Write-Log -Message "Attempting to remove Appx package: [$($AppxPackage.Name)]..."
    Try {
        Remove-AppxPackage -Package $AppxPackage.PackageFullName -AllUsers -ErrorAction Stop > $null
        Write-Log -Message "Successfully removed Appx package: [$($AppxPackage.Name)]"
    }
    Catch {
        Write-Log -Message "Warning: Failed to remove Appx package: [$($AppxPackage.Name)]"
    }
}

# Attempts to remove installed programs.
# Logs the outcome of each removal attempt.
$InstalledPrograms | ForEach {
    Write-Log -Message "Attempting to uninstall: [$($_.Name)]..."
    Try {
        $_ | Uninstall-Package -AllVersions -Force -ErrorAction Stop > $null
        Write-Log -Message "Successfully uninstalled: [$($_.Name)]"
    }
    Catch {
        Write-Log -Message "Warning: Failed to uninstall: [$($_.Name)]"
    }
}
