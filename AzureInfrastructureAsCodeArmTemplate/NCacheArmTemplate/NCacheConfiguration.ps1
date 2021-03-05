Param(
    [Parameter(Mandatory = $true)]
    [string]$clusterName,
    [Parameter(Mandatory = $true)]
    [string]$topology,
    [Parameter(Mandatory = $true)]
    [string]$currentIP,
    [Parameter(Mandatory = $true)]
    [string]$serverIP,
    [Parameter(Mandatory = $true)]
    [string]$replicationStrategy,
    [Parameter(Mandatory = $true)]
    [string]$evictionPolicy,
    [Parameter(Mandatory = $true)]
    [string]$maxSize,
    [Parameter(Mandatory = $true)]
    [Int32]$evictionPercentage,
    [Parameter(Mandatory = $true)]
    [AllowEmptyString()]
    [string]$licenseKey,
    [Parameter(Mandatory = $true)]
    [string]$firstName,
    [Parameter(Mandatory = $true)]
    [string]$lastName,
    [Parameter(Mandatory = $true)]
    [string]$emailAddress,
    [Parameter(Mandatory = $true)]
    [string]$company,
    [Parameter(Mandatory = $true)]
    [string]$environment,
    [Parameter(Mandatory = $true)]
    [string]$numberOfClients,
    [Parameter(Mandatory = $true)]
    [Int32]$vmCount
)
    #Clear-Host
    #$Error.Clear()

function SetFirewallRules 
{
    $status = Invoke-Expression -Command 'New-NetFirewallRule -DisplayName nc-management-port -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8250'

    if ($status -ne $null) {
        (Get-Date).ToString() + '    nc-management-port Inbound rule defined successfully' >> C:\NCache-Init-Status.txt    
    }

    $status = Invoke-Expression -Command 'New-NetFirewallRule -DisplayName nc-management-port -Direction Outbound -Action Allow -Protocol TCP -LocalPort 8250'

    if ($status -ne $null) {
        (Get-Date).ToString() + '    nc-management-port outbound rule defined successfully' >> C:\NCache-Init-Status.txt    
    }

    $status = Invoke-Expression -Command 'New-NetFirewallRule -DisplayName nc-server-port -Direction Inbound -Action Allow -Protocol TCP -LocalPort 9800'

    if ($status -ne $null) {
        (Get-Date).ToString() + '    nc-server-port Inbound rule defined successfully' >> C:\NCache-Init-Status.txt    
    }

    $status = Invoke-Expression -Command 'New-NetFirewallRule -DisplayName nc-server-port -Direction Outbound -Action Allow -Protocol TCP -LocalPort 9800'

    if ($status -ne $null) {
        (Get-Date).ToString() + '    nc-server-port outbound rule defined successfully' >> C:\NCache-Init-Status.txt    
    }

    $status = Invoke-Expression -Command 'New-NetFirewallRule -DisplayName nc-cluster-management-port -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8300-8399'

    if ($status -ne $null) {
        (Get-Date).ToString() + '    nc-cluster-management-port Inbound rule defined successfully' >> C:\NCache-Init-Status.txt    
    }

    $status = Invoke-Expression -Command 'New-NetFirewallRule -DisplayName nc-cluster-management-port -Direction Outbound -Action Allow -Protocol TCP -LocalPort 8300-8399'

    if ($status -ne $null) {
        (Get-Date).ToString() + '    nc-cluster-management-port outbound rule defined successfully' >> C:\NCache-Init-Status.txt    
    }

	$status = Invoke-Expression -Command 'New-NetFirewallRule -DisplayName nc-web-management-port -Direction Outbound -Action Allow -Protocol TCP -LocalPort 8251'

    if ($status -ne $null) {
        (Get-Date).ToString() + '    nc-web-management-port outbound rule defined successfully' >> C:\NCache-Init-Status.txt    
    }

	$status = Invoke-Expression -Command 'New-NetFirewallRule -DisplayName nc-web-management-port -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8251'

    if ($status -ne $null) {
        (Get-Date).ToString() + '    nc-web-management-port Inbound rule defined successfully' >> C:\NCache-Init-Status.txt    
    }

	$status = Invoke-Expression -Command 'New-NetFirewallRule -DisplayName nc-bridge-port -Direction Outbound -Action Allow -Protocol TCP -LocalPort 9900'

    if ($status -ne $null) {
        (Get-Date).ToString() + '    nc-bridge-port outbound rule defined successfully' >> C:\NCache-Init-Status.txt    
    }

	$status = Invoke-Expression -Command 'New-NetFirewallRule -DisplayName nc-bridge-port -Direction Inbound -Action Allow -Protocol TCP -LocalPort 9900'

    if ($status -ne $null) {
        (Get-Date).ToString() + '    nc-bridge-port Inbound rule defined successfully' >> C:\NCache-Init-Status.txt    
    }

	$status = Invoke-Expression -Command 'New-NetFirewallRule -DisplayName nc-bridge-management-port -Direction Outbound -Action Allow -Protocol TCP -LocalPort 8260'

    if ($status -ne $null) {
        (Get-Date).ToString() + '    nc-bridge-management-port outbound rule defined successfully' >> C:\NCache-Init-Status.txt    
    }

	$status = Invoke-Expression -Command 'New-NetFirewallRule -DisplayName nc-bridge-management-port -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8260'

    if ($status -ne $null) {
        (Get-Date).ToString() + '    nc-bridge-management-port Inbound rule defined successfully' >> C:\NCache-Init-Status.txt    
    }

	$status = Invoke-Expression -Command 'New-NetFirewallRule -DisplayName nc-bridge-cluster-port -Direction Outbound -Action Allow -Protocol TCP -LocalPort 10000-10100'

    if ($status -ne $null) {
        (Get-Date).ToString() + '    nc-bridge-cluster-port outbound rule defined successfully' >> C:\NCache-Init-Status.txt    
    }

	$status = Invoke-Expression -Command 'New-NetFirewallRule -DisplayName nc-bridge-cluster-port -Direction Inbound -Action Allow -Protocol TCP -LocalPort 10000-10100'

    if ($status -ne $null) {
        (Get-Date).ToString() + '    nc-bridge-cluster-port Inbound rule defined successfully' >> C:\NCache-Init-Status.txt    
    }
}

function RestartNCacheService
{
    $ncserviceState = Get-Service -Name NCacheSvc
    Invoke-Expression -Command 'Restart-Service NCacheSvc' | Out-Null
    $ncserviceState = Get-Service -Name NCacheSvc
    $ncserviceState.Status >> C:\NCache-Init-Status.txt
}

function HandleClusterAndCache
{
		"Handling Cluster Creation">>C:\NCache-Init-Status.txt
		$clusterName>>C:\NCache-Init-Status.txt
		$topology>>C:\NCache-Init-Status.txt
		$maxSize>>C:\NCache-Init-Status.txt
        # to support parameter differences in powershell and CLI

        Import-Module 'C:\Program Files\NCache\bin\tools\ncacheps\ncacheps.dll'
		$clusterArray = $clusterName.Split(",")
		$topologyArray = $topology.Split(",")
		$defaultTopologies = "PartitionedOfReplica"
		if($topologyArray.Length -lt $clusterArray.Length)
		{
			For ($k=1; $k -lt ($clusterArray.Length - $topologyArray.Length); $k++)
			{
				$defaultTopologies += (",PartitionedOfReplica")
			}
			$topologyArray += $defaultTopologies.Split(",")
		}

		$maxSizeArray = $maxSize.Split(",")
		if($topologyArray.Length -lt $clusterArray.Length)
		{
			For ($k=1; $k -lt ($clusterArray.Length - $maxSizeArray.Length); $k++)
			{
				$maxSizeArray += 1024
			}
				
		}
		
		For ($i=0; $i -lt $clusterArray.Length; $i++)
		{
			if ($serverIP -eq $currentIP)  
			{	
			$clusterArray[$i] >> C:\NCache-Init-Status.txt
			$topologyArray[$i] >> C:\NCache-Init-Status.txt
			$maxSizeArray[$i] >> C:\NCache-Init-Status.txt
				$Expression = "New-Cache -Name " + $clusterArray[$i] + " -Server " + $currentIP + " -Topology " + $topologyArray[$i] + " -Size " + $maxSizeArray[$i] + " -ReplicationStrategy " + $replicationStrategy + " -EvictionPolicy " + $evictionPolicy + " -EvictionRatio " + $evictionPercentage + " -NoLogo"
			}
			else 
			{
				Start-Sleep -s 10
				$Expression = "Add-Node -CacheName " + $clusterArray[$i] + " -ExistingServer " + $serverIP + " -NewServer " + $currentIP + " -NoLogo"
			}
		

        try {
            Invoke-Expression -Command $Expression -OutVariable output -ErrorVariable errors
        
            $ouput >> C:\NCache-Init-Status.txt

            $errors >> C:\NCache-Init-Status.txt
        }
        catch {
            #"Error in creating cluster" >> C:\createCluster.txt
            $_ >> C:\NCache-Init-Status.txt
        }

        $Expression = "Export-CacheConfiguration -Name " + $clusterArray[$i] + " -Server " + $currentIP + " -Path C:\ -NoLogo"
        Invoke-Expression -Command $Expression >> C:\NCache-Init-Status.txt
    
        $configPath = 'C:\' + $clusterArray[$i] + '.ncconf'
    
        $line = Get-Content $configPath | where-Object {$_ -like '*cluster-port="*"*'}
        $clusterport = [regex]::match($line, '(cluster-port="\d{4,5}")').Groups[1].Value
        $port = [regex]::match($clusterport, '(\d{4,5})').Groups[1].Value
        $port
        $portInInt = [convert]::ToInt32($port)
    
        $portrange = [regex]::match($line, '(port-range="\d{1,3}")').Groups[1].Value
        $range = [regex]::match($portrange, '(\d{1,3})').Groups[1].Value
        $range
    
        $rangeInInt = [convert]::ToInt32($range)
        for ($j = 0; $j -lt $rangeInInt; $j++) {
            $currentPort = $portInInt + $j

            $clusterRule = 'New-NetFirewallRule -DisplayName nc-cluster-port-' + $j + ' -Direction Inbound -Action Allow -Protocol TCP -LocalPort ' + ($currentPort).ToString()
    
            $status = Invoke-Expression -Command $clusterRule

            (Get-Date).ToString() + 'status of nc-cluster-port inbound rule ' + $status  >> C:\NCache-Init-Status.txt 

            if ($status -ne $null) {
                (Get-Date).ToString() + 'New-NetFirewallRule -DisplayName nc-cluster-port-' + $j + ' -Direction Inbound -Action Allow -Protocol TCP -LocalPort ' + ($currentPort).ToString() >> C:\NCache-Init-Status.txt 

                (Get-Date).ToString() + '    nc-cluster-port-' + $j + 'inbound rule defined successfully' >> C:\NCache-Init-Status.txt    
            }
        
            $clusterRule = 'New-NetFirewallRule -DisplayName nc-cluster-port-' + $j + ' -Direction Outbound -Action Allow -Protocol TCP -LocalPort ' + ($currentPort).ToString()
        
            $status = Invoke-Expression -Command $clusterRule

             (Get-Date).ToString() + 'status of nc-cluster-port inbound rule ' + $status  >> C:\NCache-Init-Status.txt 
        
            if ($status -ne $null) {

                (Get-Date).ToString() + 'New-NetFirewallRule -DisplayName nc-cluster-port-' + $j + ' -Direction Outbound -Action Allow -Protocol TCP -LocalPort ' + ($currentPort).ToString() >> C:\NCache-Init-Status.txt    
                (Get-Date).ToString() + '    nc-cluster-port-' + $j + ' outbound rule defined successfully' >> C:\NCache-Init-Status.txt    
            }
        }

        Remove-Item -Path $configPath
        
        if (Test-Path $configPath)
        {
            $configPath + " removed successfully" >> C:\NCache-Init-Status.txt            
        }

        Start-Sleep -s 2

        $Expression = "Start-Cache -Name " + $clusterArray[$i] + " -Server " + $currentIP + " -NoLogo"

        try {
            Invoke-Expression -Command $Expression -OutVariable output -ErrorVariable errors

            $output >> C:\NCache-Init-Status.txt

            $errors >> C:\NCache-Init-Status.txt
        }
        catch {
            #"Error in starting cluster" >> C:\startCluster.txt
            $_ >> C:\NCache-Init-Status.txt
        }
		}
    }


function GetNCacheAcivation
{
    if ($licenseKey.Equals("NotSpecified")) {
        $licenseKey = ""
    }

    if ($licenseKey -ne "") {
        $NActivateExpression = "Register-NCache -Key " + $licenseKey + " -FirstName " + $firstName + " -LastName " + $lastName + " -Email " + $emailAddress + " -Company " + $company + " -Server " + $currentIP + " -Environment " + $environment + " -Clients " + $numberOfClients 
    
        try {
            Invoke-Expression -Command $NActivateExpression >> C:\NCache-Init-Status.txt
        }
        catch {
            $_.Exception.Message >> C:\NCache-Init-Status.txt
        }
    }
}

if (!(Test-Path C:\NCache-Init-Status.txt)) {
    SetFirewallRules
    GetNCacheAcivation
    RestartNCacheService
    HandleClusterAndCache
}

