#########################################################################
# Author:  Kevin RAHETILAHY                                             #
# Blog: dev4sys.com                                                     #
#########################################################################


#########################################################################
#                        ASSEMBLY                                       #
#########################################################################

<<<<<<< HEAD
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.Forms")  | Out-Null
=======
>>>>>>> develop
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
[System.Reflection.Assembly]::LoadWithPartialName("System.Web")            | Out-Null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')       | out-null  
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') | out-null


#########################################################################
#                        Load Main Panel                                #
#########################################################################

$Global:pathPanel= split-path -parent $MyInvocation.MyCommand.Definition

function LoadXaml ($filename){
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}


$XamlMainWindow=LoadXaml($pathPanel+"\form.xaml")
$reader = (New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form = [Windows.Markup.XamlReader]::Load($reader)


$MissinglistView  = $Form.FindName("MissinglistView")
$DisabledlistView = $Form.FindName("DisabledlistView")
$OthersListView   = $Form.FindName("OthersListView")

$msinfo32   = $Form.FindName("msinfo32")
$dxDiag     = $Form.FindName("dxDiag")
$devmgmt    = $Form.FindName("devmgmt")

$MissingBadge   = $Form.FindName("MissingBadge")
$DisabledBadge  = $Form.FindName("DisabledBadge")
$OthersdBadge   = $Form.FindName("OthersdBadge")

$FolderLocation   = $Form.FindName("FolderLocation")
$BrowseFolder     = $Form.FindName("BrowseFolder")
$ExportFile       = $Form.FindName("ExportFile")

$SearchArea     = $Form.FindName("SearchArea")
$SearchButton   = $Form.FindName("SearchButton")

$SearchArea.Visibility = "Collapsed"
#########################################################################
#                         Initialize List                               #
#########################################################################
   
try {
           
    if($MissinglistView.Items.Count -ne 0){ $MissinglistView.Items.Clear()}


    $DeviceList = Get-WmiObject Win32_PNPEntity | Where-Object {$_.ConfigManagerErrorCode -gt 0 }
            
    $MissingDriver =  $DeviceList | Where-Object {$_.ConfigManagerErrorCode -eq 28 }
    $DisableDevice =  $DeviceList | Where-Object {$_.ConfigManagerErrorCode -eq 22 -or $_.ConfigManagerErrorCode -eq 29 } 
    $othersDevice  =  $DeviceList | Where-Object {$_.ConfigManagerErrorCode -ne 22 -and $_.ConfigManagerErrorCode -ne 29 -and $_.ConfigManagerErrorCode -ne 28 }           
                      
        
        $nbrOfMisingIssues   = ($MissingDriver | Measure-Object).Count
        $nbrOfDisabledIssues = ($DisableDevice | Measure-Object).Count
        $nbrOfRestIssues     = ($othersDevice | Measure-Object).Count

        $MissingBadge.Badge  = $nbrOfMisingIssues
        $DisabledBadge.Badge = $nbrOfDisabledIssues
        $OthersdBadge.Badge  = $nbrOfRestIssues   

        # ======== Missing Driver ============
        $Script:ContentObject = @()   
        Foreach($device in $MissingDriver) {
            
            $objArray = New-Object PSObject
            $objArray | Add-Member -type NoteProperty -name Caption -value $device.Caption
            $objArray | Add-Member -type NoteProperty -name PNPDeviceID -value $device.PNPDeviceID
            $objArray | Add-Member -type NoteProperty -name ErrorCode -value $device.ConfigManagerErrorCode
            If ($device.Manufacturer -ne $null){$objArray | Add-Member -type NoteProperty -name Manufacturer -value $device.Manufacturer}
            Else{$objArray | Add-Member -type NoteProperty -name Manufacturer -value "Unknown"}
            $ContentObject += $objArray 
            $MissinglistView.Items.Add($objArray) | Out-Null   
        }          
        
        # ======== Missing Driver ============
        $Script:ContentObject1 = @()   
        Foreach($device in $DisableDevice) {

            $objArray = New-Object PSObject
            $objArray | Add-Member -type NoteProperty -name Caption -value $device.Caption
            $objArray | Add-Member -type NoteProperty -name PNPDeviceID -value $device.PNPDeviceID
            $objArray | Add-Member -type NoteProperty -name ErrorCode -value $device.ConfigManagerErrorCode
            If ($device.Manufacturer -ne $null){$objArray | Add-Member -type NoteProperty -name Manufacturer -value $device.Manufacturer}
            Else{$objArray | Add-Member -type NoteProperty -name Manufacturer -value "Unknown"}
            $ContentObject1 += $objArray 

            $DisabledlistView.Items.Add($objArray) | Out-Null   
        } 
        
        # ======== Missing Driver ============
        $Script:ContentObject2 = @()   
        Foreach($device in $othersDevice) {

            $objArray = New-Object PSObject
            $objArray | Add-Member -type NoteProperty -name Caption -value $device.Caption
            $objArray | Add-Member -type NoteProperty -name PNPDeviceID -value $device.PNPDeviceID
            $objArray | Add-Member -type NoteProperty -name ErrorCode -value $device.ConfigManagerErrorCode
            If ($device.Manufacturer -ne $null){$objArray | Add-Member -type NoteProperty -name Manufacturer -value $device.Manufacturer}
            Else{$objArray | Add-Member -type NoteProperty -name Manufacturer -value "Unknown"}
            $ContentObject2 += $objArray 

            $OthersListView.Items.Add($objArray) | Out-Null   
        }       
           
}
catch {
     Write-Host $_.Exception.Message
}



$Form.add_MouseLeftButtonDown({
   $_.handled=$true
   $this.DragMove()
})
     


#########################################################################
#                         Event Manager                                 #
#########################################################################

#Region "Quick Links"

$msinfo32.add_Click({
    #System Information Summary
    msinfo32
})
$dxDiag.add_Click({
    # Load DXdiag 
    dxdiag
})
$devmgmt.add_Click({
    # start device manager
    devmgmt.msc
})

#End region 

#Region "Export"

function BrowseInIE () {
    Param($PNDdevice)
    # encode the chain with ASCII value to pass as a web request search.
    $query = [System.Web.HttpUtility]::UrlEncode($PNDdevice)
    # create an instane of IE and launc search
    $ie = New-Object -ComObject InternetExplorer.Application
    $stringURL = "http://www.google.com/search?q="+$query
    Write-Host $stringURL
    $ie.Navigate($stringURL)
    $ie.Visible = $true

}

$MissinglistView.Add_SelectionChanged({
    $SearchArea.Visibility = "Visible"
    # update the selected device
    $script:CurrentDevice = $MissinglistView.SelectedItem
})

$SearchButton.add_Click({

    if($script:CurrentDevice -ne "" -or $script:CurrentDevice -ne $null){
        Write-Host $CurrentDevice.PNPDeviceID
        # borwse in IE
        BrowseInIE -PNDdevice $CurrentDevice.PNPDeviceID
    }
})

$BrowseFolder.add_Click({
    
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.rootfolder = "Desktop"

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder = $foldername.SelectedPath
    }

    $FolderLocation.Text = $folder   
}) 
    
$ExportFile.add_Click({
    
    $FileNameExport = $FolderLocation.Text + "\MissingDriver.csv"
    $retVal = 0
    try{
        $ContentObject | export-csv -Path $FileNameExport -Delimiter ";" -NoTypeInformation
        $ContentObject1 | export-csv -Path $FileNameExport -Delimiter ";" -Append -NoTypeInformation 
        $ContentObject2 | export-csv -Path $FileNameExport -Delimiter ";" -Append -NoTypeInformation
    }
    Catch{
        Write-Host $_.Exception.Message
        $retVal = 1
    }
    
    If ($retVal -eq 0){ [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Export File", "File has been successfully created.") }
    else{[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Export File", "An error occured when exporting the file. :( ")}

})

#End region 


#########################################################################
#                        Show Dialog                                    #
#########################################################################
$Form.ShowDialog() | Out-Null
  