<#Generates a dialog box to log into your Azure subscription#>
Connect-AzureRmAccount;

<#Local variables for required Managed Instance resources#>
$rgname = "yourmirg";
$vnet = "yourmivn";
$subnet = "default";
$vmsubnet = "yournvstsn";
$rtable = "yournvstrt";
$server = "yournvstsrv";
$location = "northcentralus";

<#If your resource group already exists, uncomment this line#>
#Remove-AzureRmResourceGroup -Name $rgname -Force;

<#If you need to create a resource group, uncomment this line#>
New-AzureRmResourceGroup -Name $rgname -Location $location;

<#Creates VNet with an IP range of 10.0.0.0-10.0.255.255#>
$virtualNetwork = New-AzureRmVirtualNetwork `
  -ResourceGroupName $rgname `
  -Location $location `
  -Name $vnet `
  -AddressPrefix 10.0.0.0/16;

<#Creates a subnet with an IP range of 10.0.0.0-10.0.0.255
  Used for Managed Instance#>
$subnetConfig = Add-AzureRmVirtualNetworkSubnetConfig `
  -Name $subnet `
  -AddressPrefix 10.0.0.0/24 `
  -VirtualNetwork $virtualNetwork;

<#Creates a subnet with an IP range of 10.0.1.0-10.0.1.255
  Used for VM#>
$subnetVmConfig = Add-AzureRmVirtualNetworkSubnetConfig `
  -Name $vmsubnet `
  -AddressPrefix 10.0.1.0/24 `
  -VirtualNetwork $virtualNetwork;

<#Writes VNet information to the $VirtualNetwork variable#>
$virtualNetwork | Set-AzureRmVirtualNetwork;

<#The next two commands create a route table and write the route table information to variable $RouteTable#>
$Route = New-AzureRmRouteConfig -Name $rtable -AddressPrefix 0.0.0.0/0 -NextHopType Internet;
New-AzureRmRouteTable -Name $rtable -ResourceGroupName $rgname -Location $location -Route $Route;

$RouteTable = Get-AzureRmRouteTable -Name $rtable -ResourceGroupName $rgname;

<#Configures the route table in the drfault subnet#>
Set-AzureRmVirtualNetworkSubnetConfig `
  -VirtualNetwork $virtualNetwork `
  -Name $subnet `
  -AddressPrefix 10.0.0.0/24 `
  -RouteTable $RouteTable | Set-AzureRmVirtualNetwork;

$vnetlong = Get-AzureRmVirtualNetwork -Name $vnet -ResourceGroupName $rgname;

$subnetConfig = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnetlong;

$subnetConfig[0].Id;

<#Creates an Azure VM in the yournvstsn subnet, opening ports 80 and 3389#>
New-AzureRmVm `
    -ResourceGroupName $rgname `
    -Name $server `
    -Location $location `
    -VirtualNetworkName $vnet `
    -SubnetName $vmsubnet `
    -SecurityGroupName "$server-nsg" `
    -PublicIpAddressName "$server-ip" `
    -OpenPorts 80,3389;

<#Once the VM is provisioned, RDP to it and download and install SQL Server Management Studio
  https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017#>





