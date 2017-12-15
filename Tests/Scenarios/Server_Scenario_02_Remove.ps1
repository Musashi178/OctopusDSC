Configuration Server_Scenario_02_Remove
{
    Import-DscResource -ModuleName OctopusDSC

    $pass = ConvertTo-SecureString "SuperS3cretPassw0rd!" -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ("OctoAdmin", $pass)

    Node "localhost"
    {
        LocalConfigurationManager
        {
            DebugMode = "ForceModuleImport"
            ConfigurationMode = 'ApplyOnly'
        }

        cOctopusSeqLogger "Disable logging to seq"
        {
            InstanceType = 'OctopusServer'
            Ensure = 'Absent'
        }

        cOctopusServer OctopusServer
        {
            Ensure = "Absent"
            State = "Stopped"

            # Server instance name. Leave it as 'OctopusServer' unless you have more
            # than one instance
            Name = "OctopusServer"

            # The url that Octopus will listen on
            WebListenPrefix = "http://localhost:81"

            SqlDbConnectionString = "Server=(local)\SQLEXPRESS;Database=Octopus;Trusted_Connection=True;"

            # The admin user to create
            OctopusAdminCredential = $cred

            # dont mess with stats
            AllowCollectionOfAnonymousUsageStatistics = $false
        }

        cOctopusServer OctopusServerSecondNode
        {
            Ensure = "Absent"
            State = "Stopped"

            Name = "HANode"

            # The url that Octopus will listen on
            WebListenPrefix = "http://localhost:82"

            SqlDbConnectionString = "Server=(local)\SQLEXPRESS;Database=OctopusScenario1;Trusted_Connection=True;"

            # The admin user to create
            OctopusAdminCredential = $cred

            # dont mess with stats
            AllowCollectionOfAnonymousUsageStatistics = $false

            HomeDirectory = "C:\ChezOctopusSecondNode"
        }
    }
}

# I think we need to drop our database

