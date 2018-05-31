Connect-AzureRmAccount;

$rgname = "fbgmipresrg";
$vnet = "fbgmipresvn";
$subnet = "default";
$vmsubnet = "fbgmipressn";
$rtable = "fbgmipresrt";
$server = "fbgmipressrv";
$location = "eastus";
$miname = "fbgmipresmi";

Remove-AzureRmResourceGroup -Name $rgname -Force;

New-AzureRmResourceGroup -Name $rgname -Location EastUS;

$virtualNetwork = New-AzureRmVirtualNetwork `
  -ResourceGroupName $rgname `
  -Location $location `
  -Name $vnet `
  -AddressPrefix 10.0.0.0/16;

$subnetConfig = Add-AzureRmVirtualNetworkSubnetConfig `
  -Name $subnet `
  -AddressPrefix 10.0.0.0/24 `
  -VirtualNetwork $virtualNetwork;

$subnetVmConfig = Add-AzureRmVirtualNetworkSubnetConfig `
  -Name $vmsubnet `
  -AddressPrefix 10.0.1.0/24 `
  -VirtualNetwork $virtualNetwork;

$virtualNetwork | Set-AzureRmVirtualNetwork;

$Route = New-AzureRmRouteConfig -Name "fbgmipresroute" -AddressPrefix 0.0.0.0/0 -NextHopType Internet;
New-AzureRmRouteTable -Name "fbgmipresrt" -ResourceGroupName $rgname -Location $location -Route $Route;

$RouteTable = Get-AzureRmRouteTable -Name $rtable -ResourceGroupName $rgname;

Set-AzureRmVirtualNetworkSubnetConfig `
  -VirtualNetwork $virtualNetwork `
  -Name $subnet `
  -AddressPrefix 10.0.0.0/24 `
  -RouteTable $routeTable |
Set-AzureRmVirtualNetwork;

New-AzureRmSqlManagedInstance `
-Name $miname `
-ResourceGroupName $rgname `
-Location $location `
-AdministratorCredential (Get-Credential) `
-SubnetId $subnetConfig.Id `
-StorageSizeInGB 1024 `
-VCore 16 `
-Edition "GeneralPurpose" `
-ComputeGeneration Gen4;

New-AzureRmVm `
    -ResourceGroupName $rgname `
    -Name $server `
    -Location $location `
    -VirtualNetworkName $vnet `
    -SubnetName $vmsubnet `
    -SecurityGroupName "$server-nsg" `
    -PublicIpAddressName "$server-ip" `
    -OpenPorts 80,3389;

$ipaddress = Get-AzureRmPublicIpAddress -ResourceGroupName $rgname | Select "IpAddress";

$ip = $ipaddress.IpAddress;

$mstsc = [scriptblock]::Create("mstsc /v:$ip`:3389");

Invoke-Command -ScriptBlock $mstsc;




