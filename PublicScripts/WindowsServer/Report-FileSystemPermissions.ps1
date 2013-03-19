param([switch]$OutPutToGreadView, [parameter(Mandatory=$true)][String]$Path)

$Metadata = @{
	Title = "Report Filesystem Permissions"
	Filename = "Report-FileSystemPermissions.ps1"
	Description = ""
	Tags = "powershell, function, report"
	Project = ""
	Author = "Janik von Rotz"
	AuthorEMail = "contact@janikvonrotz.ch"
	CreateDate = "2013-03-14"
	LastEditDate = "2013-03-14"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

<#
#--------------------------------------------------#
# Example
#--------------------------------------------------#
 
.\Report-FileSystemPermissions -OutPutToGreadView -Path "D:\Dat"

$Report = .\Report-FileSystemPermissions.ps1 -Path "D:\Dat"

#>

#--------------------------------------------------#
# Includes
#--------------------------------------------------#

#--------------------------------------------------#
# Settings
#--------------------------------------------------#

#--------------------------------------------------#
# Main
#--------------------------------------------------#

$FileSystemPermissionReport = @()

function New-SPReportItem {
    param(
        $Name,
        $Url,
        $Member,
        $PermissionMask,
        $Type
    )
    New-Object PSObject -Property @{
        Name = $Name
        Url = $Url
        Member = $Member
        PermissionMask =$PermissionMask
        Type =$Type
    }
}

$FSfolders = Get-ChildItem -path $Path -force -recurse | Where {$_.PSIsContainer}

foreach ($FSfolder in $FSfolders)
{
   $PSPath = Convert-Path $FSfolder.PsPath
   $PSPath
   $Acls = Get-Acl -Path $PSPath
   foreach($Acl in $Acls.Access){
       if($Acl.IsInherited -eq $false){
            $FileSystemPermissionReport += New-SPReportItem -Name $FSfolder.Name -Url $FSfolder.FullName -Member $Acl.IdentityReference -PermissionMask $Acl.FileSystemRights   -Type "Folder"
       }else{break}
   }
}

Write-Host “`nFinished`n” -BackgroundColor Green -ForegroundColor Black

$FileSystemPermissionReport | Out-GridView
Read-Host

if($OutPutToGreadView -eq $true){
    $FileSystemPermissionReport | Out-GridView
}else{
    return $FileSystemPermissionReport
}