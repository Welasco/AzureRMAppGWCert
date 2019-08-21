<# 
 .Synopsis
  This Module list all certificates associated with an Azure Application Gateway.

 .Description
  This Module list all certificates associated with an Azure Application Gateway.
  After you have deployed an Azure Application Gateway is not possible to list the certificate properties associated with a Listener, Rule or Http setting.
  This Module will list all certificates and an output like this:

 PS C:\> Get-AzAppGWCert -RG OfficeClient -AppGWName AppGateway

    AppGWName    : AppGateway
    ListnerName  : appGatewayHttpListener
    Subject      : CN=*.hepoca.com, O=Hepoca Armarios e Servicos Ltda - EPP, L=Taguatinga, S=Distrito Federal, C=BR
    Issuer       : CN=DigiCert SHA2 Secure Server CA, O=DigiCert Inc, C=US
    SerialNumber : 0E99D5E2EBBE329CFE2DDE29C1D7D343
    Thumbprint   : 5FD6F2A7BC4BD095198AE55D1A0A76D46365C6B9
    NotBefore    : 3/13/2017 7:00:00 PM
    NotAfter     : 5/2/2018 7:00:00 AM

    AppGWName    : AppGateway
    ListnerName  : HTTPs8080
    Subject      : CN=*.hepoca.com, O=Hepoca Armarios e Servicos Ltda - EPP, L=Taguatinga, S=Distrito Federal, C=BR
    Issuer       : CN=DigiCert SHA2 Secure Server CA, O=DigiCert Inc, C=US
    SerialNumber : 0E99D5E2EBBE329CFE2DDE29C1D7D343
    Thumbprint   : 5FD6F2A7BC4BD095198AE55D1A0A76D46365C6B9
    NotBefore    : 3/13/2017 7:00:00 PM
    NotAfter     : 5/2/2018 7:00:00 AM

    AppGWName       : AppGateway
    HTTPSetting     : appGatewayBackendHttpSettings
    RuleName        : rule1
    BackendCertName : webjson-pub
    Subject         : E=a@a.com, CN=webjson.arr.local, OU=Arr, O=ARR, L=Irving, S=TX, C=US
    Issuer          : E=a@a.com, CN=webjson.arr.local, OU=Arr, O=ARR, L=Irving, S=TX, C=US
    SerialNumber    : 00B1722AB4D0FB8CAA
    Thumbprint      : 573C70769A40CF4D01769926A212009598462436
    NotBefore       : 11/28/2017 12:45:23 PM
    NotAfter        : 11/28/2018 12:45:23 PM
 
 .Example
   # Listing all Application Gateway Certificates
   Get-AzAppGWCert
   This Example will get all Azure Application Gateways and list all certificates associated with all of them : "Get-AzAppGWCert"

 .Example
   # Listing Application Gateway Certificates in a Resource Group
   Get-AzAppGWCert -RG <Resource Group Name>
   This Example will get all Azure Application Gateways in a Resource Group and list all certificates associated with them : "Get-AzAppGWCert -RG <Resource Group Name>"

 .Example
   # Listing a specific Application Gateway Certificates
   Get-AzAppGWCert -RG <Resource Group Name> -AppGWName <Application Gateway Name>
   This Example will list all certificates associated with a specific Application Gateway : "Get-AzAppGWCert -RG <Resource Group Name> -AppGWName <Application Gateway Name>"

 .Example
   # Listing all Application Gateway Certificates and exporting all certificates file.
   Get-AzAppGWCert -Export
   This Example will list all certificates associated with all Application Gateways and export them : "Get-AzAppGWCert -Export"   

.Example
   # Listing all Application Gateway Certificates and show Details.
   Get-AzAppGWCert -Details
   This Example will list all certificates associated with all Application Gateways and show all Details about them: "Get-AzAppGWCert -Details"   

# A URL to the main website for this project.
ProjectUri = 'https://github.com/Welasco/AzAppGWCert'
#>

Function Get-AzAppGWCert{
    Param(
        [String]$RG,
        [String]$AppGWName,
        [Switch]$Details,
        [Switch]$Export
    )   

    if($AppGWName -and $RG){
        $AppGWs = Get-AzApplicationGateway -ResourceGroupName $RG -Name $AppGWName
    }
    elseif($RG){
        $AppGWs = Get-AzApplicationGateway -ResourceGroupName $RG
    }
    elseif($AppGWName){
        throw "-AppGWName requires parameter -RG (ResourceGroup)"
    }
    else{
        $AppGWs = Get-AzApplicationGateway
    }

    $TemplateObject = New-Object PSObject | Select-Object AppGWName,ResourceGroupName,ListnerName,Subject,Issuer,SerialNumber,Thumbprint,NotBefore,NotAfter
    $TemplateObjectBackEnd = New-Object PSObject | Select-Object AppGWName,ResourceGroupName,HTTPSetting,RuleName,BackendCertName,Subject,Issuer,SerialNumber,Thumbprint,NotBefore,NotAfter

    Foreach($AppGW in $AppGWs){
        
        $httpsListeners = $AppGW.HttpListeners | Where-Object{$_.Protocol -eq "HTTPS"}
        foreach($httpsListener in $httpsListeners){
            $HTTPsListenerSSLCert = ($AppGW.SslCertificatesText | ConvertFrom-Json) | Where-Object{$_.Id -eq $httpsListener.SslCertificate.id}
            $HTTPsListenerSSLCertobj = [System.Security.Cryptography.X509Certificates.X509Certificate2]([System.Convert]::FromBase64String($HTTPsListenerSSLCert.PublicCertData.Substring(60,$HTTPsListenerSSLCert.PublicCertData.Length-60)))

            $WorkingObject = $TemplateObject | Select-Object *
            $WorkingObject.AppGWName = $AppGW.Name
            $WorkingObject.ResourceGroupName = $AppGW.ResourceGroupName
            $WorkingObject.ListnerName = $httpsListener.Name
            $WorkingObject.Subject = $HTTPsListenerSSLCertobj.Subject
            $WorkingObject.Issuer = $HTTPsListenerSSLCertobj.Issuer
            $WorkingObject.SerialNumber = $HTTPsListenerSSLCertobj.SerialNumber
            $WorkingObject.Thumbprint = $HTTPsListenerSSLCertobj.Thumbprint
            $WorkingObject.NotBefore = $HTTPsListenerSSLCertobj.NotBefore
            $WorkingObject.NotAfter = $HTTPsListenerSSLCertobj.NotAfter
            $WorkingObject

            if($Details){
                $HTTPsListenerSSLCertobj | Select-Object *
            }
            if($Export){
                [System.IO.File]::WriteAllBytes((Resolve-Path .\).Path+"\"+$AppGW.Name+"-"+$appGw.ResourceGroupName+"-"+$httpsListener.Name+".cer",$HTTPsListenerSSLCertobj.RawData) 
            }
        }

        $Rules = ($AppGW.RequestRoutingRulesText | ConvertFrom-Json)

        foreach($rule in $rules){

            $RuleHttpSettingsID = $rule.BackendHttpSettings.ID

            $BackendHttpSettings = ($AppGW.BackendHttpSettingsCollectionText | ConvertFrom-Json) |Where-Object{$_.Id -eq $RuleHttpSettingsID} | Where-Object{$_.Protocol -eq "HTTPS"}
            if($BackendHttpSettings -ne $null){
                $BackendHttpSettingsCerts = $BackendHttpSettings.AuthenticationCertificates
                foreach($BackendHttpSettingsCert in $BackendHttpSettingsCerts){
                    $BackendCerts = ($AppGW.AuthenticationCertificatesText | ConvertFrom-Json) | Where-Object{$_.id -eq $BackendHttpSettingsCert.id}
                    foreach($BackendCert in $BackendCerts){
                        $BackendCertObj = [System.Security.Cryptography.X509Certificates.X509Certificate2]([System.Convert]::FromBase64String($BackendCert.Data))
                        
                        $WorkingObjectBackEnd = $TemplateObjectBackEnd | Select-Object *
                        $WorkingObjectBackEnd.AppGWName = $AppGW.Name
                        $WorkingObjectBackEnd.ResourceGroupName = $AppGW.ResourceGroupName
                        $WorkingObjectBackEnd.RuleName = $rule.Name
                        $WorkingObjectBackEnd.HTTPSetting = $BackendHttpSettings.Name
                        $WorkingObjectBackEnd.BackendCertName = $BackendCert.Name
                        $WorkingObjectBackEnd.Subject = $BackendCertObj.Subject
                        $WorkingObjectBackEnd.Issuer = $BackendCertObj.Issuer
                        $WorkingObjectBackEnd.SerialNumber = $BackendCertObj.SerialNumber
                        $WorkingObjectBackEnd.Thumbprint = $BackendCertObj.Thumbprint
                        $WorkingObjectBackEnd.NotBefore = $BackendCertObj.NotBefore
                        $WorkingObjectBackEnd.NotAfter = $BackendCertObj.NotAfter
                        $WorkingObjectBackEnd
                        if($Details){
                            $BackendCertObj | Select-Object *
                        }
                        if($Export){
                            [System.IO.File]::WriteAllBytes((Resolve-Path .\).Path+"\"+$AppGW.Name+"-"+$appGw.ResourceGroupName+"-"+$rule.Name+"-"+$BackendHttpSettings.Name+"-"+$BackendCert.Name+".cer",$HTTPsListenerSSLCertobj.RawData) 
                        }
                    }
                }
            }
        }
    }
}

# ### Exported Module Function ###

Export-ModuleMember -Function Get-AzAppGWCert
