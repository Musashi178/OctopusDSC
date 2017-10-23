Function Test-IsOffline
{
    return Test-Path c:\Temp\Tests\Offline.config
}

Function Find-V4Installer
{
    return (gci C:\temp\Tests | ? {$_.Name -like "Octopus.4s.*.msi"} | select -first 1 | select -expand Name)
}

Function Find-V3Installer
{
    return (gci C:\temp\Tests | ? {$_.Name -like "Octopus.3.*.msi"} | select -first 1 | select -expand Name)
}

if(Test-IsOffline)
{
    $downloadUrl = Find-V3Installer
}
else
{
    $downloadUrl = "https://octopus.com/downloads/latest/WindowsX64/OctopusServer"   # when 4.0 drops, this should change!
}

Configuration Server_Scenario_06_Upgrade
{
    Import-DscResource -ModuleName OctopusDSC

    $pass = ConvertTo-SecureString "SuperS3cretPassw0rd!" -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ("OctoAdmin", $pass)

    Node "localhost"
    {
        LocalConfigurationManager
        {
            DebugMode = "ForceModuleImport"
        }

        cOctopusServer OctopusServer
        {
            Ensure = "Present"
            State = "Started"

            # Server instance name. Leave it as 'OctopusServer' unless you have more
            # than one instance
            Name = "OctopusServer"

            # The url that Octopus will listen on
            WebListenPrefix = "http://localhost:81"

            # use a new database, as old one is not removed
            SqlDbConnectionString = "Server=(local)\SQLEXPRESS;Database=OctopusDeploy;Trusted_Connection=True;"

            # The admin user to create
            OctopusAdminCredential = $cred

            DownloadUrl = $downloadUrl

            # dont mess with stats
            AllowCollectionOfAnonymousUsageStatistics = $false
        }
    }
}
