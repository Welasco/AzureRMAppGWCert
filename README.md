# AzureRMAppGWCert
Powershell Module to list all certificates from an Azure Application Gateway

# How to Install

This Module is Published at https://www.powershellgallery.com/packages/AzureRMAppGWCert

In order to install just open the powershell as Administrator and type: 

Install-Module AzureRMAppGWCert

Import-Module AzureRMAppGWCert

# How to use this Module

  This Module list all certificates associated with an Azure Application Gateway.

  After you have deployed an Azure Application Gateway is not possible to list the certificate properties associated with a listener, rule or httpsetting.

  This Module will list all certificates and bring an out put like this:

        PS C:\> Get-AzureRMAppGWCert -RG OfficeClient -AppGWName AppGateway

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
 
 # Examples:
 
   Listing all Application Gateway Certificates

      Get-AzureRMAppGWCert

   This Example will get all Azure Application Gateways and list all certificates associated with all of them: 
   
      Get-AzureRMAppGWCert

   Listing Application Gateway Certificates in a Resource Group:

      Get-AzureRMAppGWCert -RG <Resource Group Name>
   
   This Example will list all certificates associated with a specific Application Gateway: 
   
      Get-AzureRMAppGWCert -RG <Resourge Group Name> -AppGWName <Application Gateway Name>

   Listing all Application Gateway Certificates and exporting all certificates file.

      Get-AzureRMAppGWCert -Export

   Listing all Application Gateway Certificates and show Details.

      Get-AzureRMAppGWCert -Details
   
   
