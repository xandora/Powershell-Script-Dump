$begin = get-date
$CompAudit = Import-Csv C:\Powershell\CompAudit\CompAudit.csv
#CompAudit.csv is a CSV file with IP,Computer fields
$Date = Get-Date -Format yyyyMMddhhmm
$i = 0

$output = foreach ($Comp in $CompAudit) {

    $IP = $Comp.IPAddress
    $result = Test-Connection $IP -Count 1 -Quiet -ErrorAction SilentlyContinue

    if (!$result) {
        
        $Comp.Computer = Write-Output "$IP not valid, or not online."

    } else {
        
        Try {
            $Comp.Computer = Write-Output ([System.Net.Dns]::GetHostbyAddress($IP)).HostName #| Select-Object @{Name='HostName';Expression={$_}} #| Export-Csv C:\Powershell\CompAudit\CompAudit-Output-$Date.csv -NoClobber -Append -NoTypeInformation
        } 
        Catch {
            $Comp.Computer = Write-Output "$IP is reachable, but not resolvable." #| Select-Object @{Name='HostName';Expression={$_}} #| Export-Csv C:\Powershell\CompAudit\CompAudit-Output-$Date.csv -Append -NoTypeInformation
        }
    }
    $Comp
    $i++
    Write-Progress -activity "Resolving IPs . . ." -status "Resolved: $i of $($CompAudit.Count)" -percentComplete (($i / $CompAudit.Count)  * 100)
}

$output | Out-GridView
$output | Export-Csv C:\Powershell\CompAudit\output\CompAudit-Output-$Date.csv -NoTypeInformation
$finish = get-date
($finish - $begin).ToString()


