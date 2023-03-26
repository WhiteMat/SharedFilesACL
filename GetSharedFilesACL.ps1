Param(
  [Parameter(Mandatory=$false)]
  [boolean]$CSVExport,
    
  [Parameter(Mandatory=$false)]
  [boolean]$HTMLExport,

  [Parameter(Mandatory=$false)]
  [boolean]$AllChilds
)

$shared_files = Get-WmiObject -Class Win32_Share | Where-Object Type -eq 0
$allHTMLElement = ""

$result = foreach ($shared_file in $shared_files) {
  Get-ChildItem -Path $shared_file.Path –Recurse | Foreach-Object {
    if ($_.Parent.FullName) {
      if ( $AllChilds -or (Get-Acl $_.FullName).Owner -ne (Get-Acl $_.Parent.FullName).Owner -or ((Get-Acl $_.FullName).Access | Format-List -Property FileSystemRights, AccessControlType, IdentityReference | Out-String) -ne ((Get-Acl $_.Parent.FullName).Access | Format-List -Property FileSystemRights, AccessControlType, IdentityReference | Out-String) ) {
        $newHTMLElement = '</br><button class="leaflet" id="'+$_.FullName+'">+</button> <b>'+$_.FullName+'</b><div hidden id="_'+$_.FullName+'"><table><thead><tr><th>FileSystemRights</th><th>AccessControlType</th><th>IdentityReference</th><th>IsInherited</th><th>InheritanceFlags</th><th>PropagationFlags</th></tr></thead><tbody>'
        foreach ($acl in (Get-Acl $_.FullName).Access) {
          $newHTMLElement = $newHTMLElement + '
            <tr>
              <td>'+$acl.FileSystemRights+'</td>
              <td>'+$acl.AccessControlType+'</td>
              <td>'+$acl.IdentityReference+'</td>
              <td>'+$acl.IsInherited+'</td>
              <td>'+$acl.InheritanceFlags+'</td>
              <td>'+$acl.PropagationFlags+'</td>
            </tr>
          '
          [PSCustomObject]@{
            File = $_.FullName
            Owner = (Get-Acl $_.FullName).Owner
            FileSystemRights     = $acl.FileSystemRights
            AccessControlType = + $acl.AccessControlType
            IdentityReference    = $acl.IdentityReference
            IsInherited     = $acl.IsInherited
            InheritanceFlags = $acl.InheritanceFlags
            PropagationFlags    = $acl.PropagationFlags
          }
        } 
        $newHTMLElement = $newHTMLElement + '</tbody></table>'
      }
      $allHTMLElement = $allHTMLElement + $newHTMLElement + '<b>Owner : '+(Get-Acl $_.FullName).Owner+'</b></div>'
    }
    if ($_.Directory.FullName) {
      if ( $AllChilds -or (Get-Acl $_.FullName).Owner -ne (Get-Acl $_.Directory.FullName).Owner -or ((Get-Acl $_.FullName).Access | Format-List -Property FileSystemRights, AccessControlType, IdentityReference | Out-String) -ne ((Get-Acl $_.Directory.FullName).Access | Format-List -Property FileSystemRights, AccessControlType, IdentityReference | Out-String) ) {
        $newHTMLElement = '</br><button class="leaflet" id="'+$_.FullName+'">+</button> <b>'+$_.FullName+'</b><div hidden id="_'+$_.FullName+'"><table><thead><tr><th>FileSystemRights</th><th>AccessControlType</th><th>IdentityReference</th><th>IsInherited</th><th>InheritanceFlags</th><th>PropagationFlags</th></tr></thead><tbody>'
        foreach ($acl in (Get-Acl $_.FullName).Access) {
          $newHTMLElement = $newHTMLElement + '
            <tr>
              <td>'+$acl.FileSystemRights+'</td>
              <td>'+$acl.AccessControlType+'</td>
              <td>'+$acl.IdentityReference+'</td>
              <td>'+$acl.IsInherited+'</td>
              <td>'+$acl.InheritanceFlags+'</td>
              <td>'+$acl.PropagationFlags+'</td>
            </tr>
          '
          [PSCustomObject]@{
            File = $_.FullName
            Owner = (Get-Acl $_.FullName).Owner
            FileSystemRights     = $acl.FileSystemRights
            AccessControlType = + $acl.AccessControlType
            IdentityReference    = $acl.IdentityReference
            IsInherited     = $acl.IsInherited
            InheritanceFlags = $acl.InheritanceFlags
            PropagationFlags    = $acl.PropagationFlags
          }
        } 
        $newHTMLElement = $newHTMLElement + '</tbody></table>'
      }
      $allHTMLElement = $allHTMLElement + $newHTMLElement + '<b>Owner : '+(Get-Acl $_.FullName).Owner+'</b></div>'
    }
  }
}

if ($CSVExport -or $HTMLExport) {
  $time = Get-Date -Format "MMddyyyyHHmm"
  $file = (Get-Location).tostring() + '\' + $time
  $temp = New-item -Path $file -ItemType Directory
}


if ($HTMLExport) {
    $html = (Get-Location).tostring() + '\' + $time +'\index.html'
    '
    <style>
      table, td, th {
        border: 1px solid;
      }

      table {
        width: 100%;
        border-collapse: collapse;
      }
    </style>
    <h1>File Shared ACL HTML Export</h1>
    '+ $allHTMLElement +'
    <script>
        const buttons = document.getElementsByClassName("leaflet");
        for (var i = 0 ; i < buttons.length; i++) {
            buttons[i].addEventListener("click", (event) => {
                var toChange = document.getElementById("_" + event.explicitOriginalTarget.id);
                if (toChange.hidden) {
                    toChange.hidden = false;
                } else {
                    toChange.hidden = true;
                }
            });
        }
    </script>
    ' | Out-File -FilePath $html
}

if ($CSVExport) {
    $csv = (Get-Location).tostring() + '\' + $time +'\export.csv'
    $result | Export-Csv -Path $csv
}

$result | Format-Table