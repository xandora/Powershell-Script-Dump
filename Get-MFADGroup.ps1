<#
.Synopsis
  Get-MFADGroup
.DESCRIPTION
   This command generates detailed reports on AD Groups. Allows for looping through nested groups.
.EXAMPLE
  Get-MFADGroup -Group AD-Sec-Group

.EXAMPLE
  Get-MFADGroup -Group AD-Sec-Group -Recurse

.EXAMPLE
  Get-MFADGroup -Group AD-Sec-Group -Recurse -Export C:\ExampleOutput

#>
functionGet-MFADGroup{
    [CmdletBinding()]
    Param(
        # Target AD Group
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Group,

        # Loop through any nested Groups
        [Switch]
        $Recurse,

        # Path to export CSV files to
        [String]
        $Export
        )

    $target = Get-ADGroupMember $Group

    if ($Export){
            Try {
                $exportName = (Get-ADGroup -Filter {DisplayName -like $Group} -Properties DisplayName -ErrorAction Inquire).DisplayName
                Write-Output "(Try) Group Name: $Group"
                Write-Output "(Try) Export name: $exportName"
            } Catch {
                $exportName = (Get-ADGroup $Group -Properties DisplayName | Select DisplayName).DisplayName
            }
            foreach($t in $target) {
            if ($t.objectClass -eq "user") {
                $users = Get-ADUser $t.name -Properties GivenName, Surname, Name, EmailAddress, Enabled | select GivenName, Surname, Name, EmailAddress, Enabled
                $users | Export-Csv $Export\$ExportName.csv -Append -NoTypeInformation
            } elseif ($t.objectClass -eq "group") {
                if ($Recurse) {
                   Get-MFADGroup $t.SamAccountName -Recurse -Export $Export
                } else {
                    Get-ADGroup $t.SamAccountName -Properties DisplayName, Description | select DisplayName, Description
                }
            }
        }

    } else {

            foreach($t in $target) {
                if ($t.objectClass -eq "user") {
                    Get-ADUser $t.name -Properties GivenName, Surname, Name, EmailAddress, Enabled | select GivenName, Surname, Name, EmailAddress, Enabled
                } elseif ($t.objectClass -eq "group") {
                    if ($Recurse) {
                       Get-MFADGroup $t.SamAccountName -Recurse
                    } else {
                        Get-ADGroup $t.SamAccountName -Properties DisplayName, Description | select DisplayName, Description
                    }
                }
            }
        }
}

#$Group = "AUK_All_Users - Consumer"
#$g = Get-ADGroup $Group -Properties *
#$g.Members | get-adgroup