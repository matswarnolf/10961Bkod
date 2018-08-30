<#
        AXIANSAXIANSAXIANSAXIANSAXIANSAXIANSAXIANSAXIANSAXIANSAXIANSAXIANSAXIANSAXIANS
        +----------------------------------------------------------------------------+
        | File    : my-tools.psm1  
        | Author  : Mats.Warnolf@axians.se                                                                 
        | Version : 2.00                                                              
        | Purpose : collect scrips turned into functions                                                                  
        | KeyWords:                                                                   
        | Synopsis:                                                                   
        | Usage   : Internal Axians                                              
        +----------------------------------------------------------------------------+
        | Maintenance History                                                         
        | -------------------                                                         
        | Name             Date            Version  Description                        
        | ---------------------------------------------------------------------------+
        | mafr02    11/28/2016 12:36:31     1.0     First version with three functions                                           
        | mafr02    12/22/2016 12:41:00     2.0     Added functions and Comment based help                                                                            
        |                                                                             
        +----------------------------------------------------------------------------+
        AXIANSAXIANSAXIANSAXIANSAXIANSAXIANSAXIANSAXIANSAXIANSAXIANSAXIANSAXIANSAXIANS
#>

function New-SgMigrationJob 
{
    <#   
            .NAME
            New-SgMigrationJob
    
            .SYNOPSIS
            This function copies a home diretory to a OneDrive for Business document 
            libraryusing Sharegate powershell module

    
            .DESCRIPTION
            This function copies a home diretory to a OneDrive for Business document
            library using Sharegate powershell module. It requires a licensed 
            Sharegate installation, SharePoint Admin Credentials, 
            a users PRIMARY email address and a path to the users home directory.

            .PARAMETER CustomerDomain
            Specifies the domain name of the customer.


            .PARAMETER Cred
            A credential object

            .EXAMPLE
            Get-TenantLicenseReport -CustomerDomain axians.se -cred $login
            Gets a license report from the Customer axians.se with a credential 
            stored in the variable $login

            .NOTES
            You need to have a credential captured with "$login = get-credential"

            .OUTPUTS
            a CSV file in C:\temp that lists the users and their respective 
            license assignments
    #>
   
    [cmdletbinding()]

    param (
        [Parameter (position = 0,HelpMessage = 'The users email address', Mandatory = $TRUE)]
        [String]$email,
        [Parameter (position = 1,HelpMessage = 'The users home directory', Mandatory = $TRUE)]
        [String]$homedir,
        [Parameter (position = 2,HelpMessage = 'The customers sharepoint admin site',Mandatory = $TRUE)]
        [String]$adminsite,
        [Parameter (position = 3,HelpMessage = 'The full path to the logfile',Mandatory = $TRUE)]
        [String]$logfile,
        [parameter (Position = 4,HelpMessage = 'The credential object',Mandatory = $TRUE)]
        [Object]$cred,
        [Parameter (position = 5,Mandatory = $FALSE)]
        [String]$migfolder

    ) 
        

       
        
    Import-Module -Name Sharegate
    $copysettings = New-CopySettings -OnContentItemExists IncrementalUpdate

    $User = Get-OneDriveUrl -Email $email -tenant $adminsite -ProvisionIfRequired 
    $rownumber++
    Write-Verbose -Message "Processing $email $homedir $User" 
    Add-Content $logfile -Value "Processing row $rownumber, getting the OFB-url for $email $homedir $User" 
    
    #connect to the destination OneDrive URL
    $dstSite = Connect-Site -Url $User -Credential $cred
 
    #select destination document library, named Documents by default in OneDrive
    $dstList = Get-List -Name Documents -Site $dstSite

 
    #Copy the content from your source directory to the Documents document library in OneDrive
    If ($migfolder)
    {
        Import-Document -SourceFolder $migfolder -InsaneMode -DestinationList $dstList -CopySettings $copysettings -WaitForImportCompletion
        #$result = Import-Document -SourceFolder $row.HomeDirectory -DestinationList $dstList -InsaneMode -DestinationFolder 'Migrerat' -CopySettings $copysettings
        Import-Document -SourceFolder $PSitem.HomeDirectory -InsaneMode -DestinationList $dstList -DestinationFolder 'Mig' -CopySettings $copysettings
        #Export-Report $result -Path C:\MyReports\CopyContentReports.xlsx -DefaultColumns
    }
    Else 
    {
        Import-Document -SourceFolder $PSitem.HomeDirectory -InsaneMode -DestinationList $dstList -CopySettings $copysettings
    }
}



function Get-TenantLicenseReport 
{
    <#   
            .SYNOPSIS
            Get a license report for a customer tenant

            .DESCRIPTION
            This function uses the Delegated Admin functionality of Office 365 to produce 
            comma separated value (CSV) licensing report for a specified customer. 

            .PARAMETER  CustomerDomain
            The Office 365 domain name of the customer where we have delegated 
            admin rights

            .PARAMETER  Cred
            a credential object of a user that is a delegated admin
            You get this with the command:
            $cred = Get-credential
            where you enter the username and password

            .PARAMETER LogPath
            The path to where the logfile should be produced. 
            Don't forget a trailing \

            .EXAMPLE
            Get-TenantLicenseReport -CustomerDomain domain.com -Cred $cred -LogPath c:\temp\
            This will produce the report file c:\temp\domain.com-Office_365_Licenses.csv



    #>
    [cmdletbinding()]

    param (
        [Parameter (position = 0,HelpMessage = 'The customers domain name', ValueFromPipeline = $TRUE,Mandatory = $TRUE)]
        [String]$CustomerDomain,
        [Parameter (position = 1,HelpMessage = 'a credential object',Mandatory = $TRUE)]
        [Object]$Cred,
        [Parameter (Position = 2,HelpMessage = 'the path to the logfile with a trailing \',Mandatory = $TRUE)]
        [String]$LogPath
        

    ) 
    # Connect to Microsoft Online 
    Write-Verbose -Message 'loading msonline module'
    Import-Module -Name MSOnline 
    Write-Verbose -Message 'Connecting to MSOLservice...' 
    Connect-MsolService -Credential $Cred 

    # Define Hashtables for lookup 
    Write-Verbose -Message 'defining lookuptables'
    $Sku = @{
        'DESKLESSPACK'               = 'Office 365 (Plan K1)'
        'DESKLESSPACK_YAMMER'        = 'Office 365 (Plan K1)with Yammer'
        'DESKLESSWOFFPACK'           = 'Office 365 (Plan K2)'
        'LITEPACK'                   = 'Office 365 (Plan P1)'
        'EXCHANGEDESKLESS'           = 'Exchange Online Kiosk'
        'EXCHANGESTANDARD'           = 'Exchange Online (Plan 1)'
        'EXCHANGEENTERPRISE'         = 'Exchange Online (Plan 2)'
        'EOP_ENTERPRISE'             = 'Exchange Online Protection'
        'EXCHANGEARCHIVE_ADDON'      = 'Exchange Online Archiving for Exchange Online'
        'ATP_ENTERPRISE'             = 'Exchange Online Advanced Threat Protection'
        'STANDARDPACK'               = 'Office 365 (Plan E1)'
        'STANDARDWOFFPACK'           = 'Office 365 (Plan E2)'
        'ENTERPRISEPACK'             = 'Office 365 (Plan E3)'
        'ENTERPRISEPACKLRG'          = 'Office 365 (Plan E3)'
        'ENTERPRISEWITHSCAL'         = 'Office 365 (Plan E4)'
        'ENTERPRISEPACKWSCAL'        = 'Office 365 (Plan E4)'
        'ENTERPRISEPREMIUM_NOPSTNCONF' = 'Office 365 (Plan E5 no PSTN Conf'
        'ENTERPRISEPREMIUM'          = 'Office 365 (Plan E5)'
        'STANDARDPACK_STUDENT'       = 'Office 365 (Plan A1) for Students'
        'STANDARDWOFFPACKPACK_STUDENT' = 'Office 365 (Plan A2) for Students'
        'ENTERPRISEPACK_STUDENT'     = 'Office 365 (Plan A3) for Students'
        'ENTERPRISEWITHSCAL_STUDENT' = 'Office 365 (Plan A4) for Students'
        'STANDARDPACK_FACULTY'       = 'Office 365 (Plan A1) for Faculty'
        'STANDARDWOFFPACKPACK_FACULTY' = 'Office 365 (Plan A2) for Faculty'
        'ENTERPRISEPACK_FACULTY'     = 'Office 365 (Plan A3) for Faculty'
        'ENTERPRISEWITHSCAL_FACULTY' = 'Office 365 (Plan A4) for Faculty'
        'STANDARDWOFFPACK_IW_STUDENT' = 'Office 365 Education for Students'
        'STANDARDWOFFPACK_IW_FACULTY' = 'Office 365 Education for Faculty'
        'EOP_ENTERPRISE_FACULTY'     = 'Exchange Online Protection for Faculty'
        'ENTERPRISEPACK_B_PILOT'     = 'Office 365 (Enterprise Preview)'
        'STANDARD_B_PILOT'           = 'Office 365 (Small Business Preview)'
        'LITEPACK_P2'                = 'Office 365 Small Business Premium'
        'MIDSIZEPACK'                = 'Office 365 Midsize Business'
        'O365_BUSINESS'              = 'Office 365 Business'
        'O365_BUSINESS_ESSENTIALS'   = 'Office 365 Business Essentials'
        'O365_BUSINESS_PREMIUM'      = 'Office 365 Business Premium'
        'POWER_BI_STANDARD'          = 'Power BI Free'
        'POWER_BI_PRO'               = 'Power BI Pro'
        'PROJECTESSENTIALS'          = 'Project Lite'
        'PROJECTONLINE_PLAN_1'       = 'Project Online'
        'PROJECTONLINE_PLAN_2'       = 'Project Online with Project Pro for Office 365'
        'PROJECTCLIENT'              = 'Project Pro for Office 365'
        'INTUNE_A'                   = 'Intune'
        'INTUNE_STORAGE'             = 'Intune Extra Storage'
        'RMS_S_PREMIUM'              = 'Azure RMS Premium'
        'RMS_S_ADHOC'                = 'Azure RMS'
        'MFA_PREMIUM'                = 'Multi Factor Authentication Premium'
        'AAD_BASIC'                  = 'Azure Active Directory Basic'
        'AAD_PREMIUM'                = 'Azure Active Directory Premium'
        'EMS'                        = 'Enterprise Mobility Suite'
        'OFFICESUBSCRIPTION'         = 'Office 365 ProPlus'
        'WACONEDRIVESTANDARD'        = 'OneDrive for Business (Plan 1)'
        'WACONEDRIVEENTERPRISE'      = 'OneDrive for Business (Plan 2)'
        'YAMMER_ENTERPRISE_STANDALONE' = 'Yammer Enterprise'
        'SHAREPOINTSTANDARD'         = 'SharePoint Online (Plan 1)'
        'SHAREPOINTENTERPRISE'       = 'SharePoint Online (Plan 2)'
        'SHAREPOINTSTORAGE'          = 'SharePoint Extra File Storage'
        'MCOIMP'                     = 'Skype for Business Online (Plan 1)'
        'MCOSTANDARD'                = 'Skype for Business Online (Plan 2)'
        'MS-AZR-0145P'               = 'Azure'
        'BI_AZURE_P0'                = 'Power BI'
        'SHAREPOINT_PROJECT'         = 'Project Online'
    } 
         
    # The Output will be written to this file in the current working directory 
    $logfile = $logpath + $CustomerDomain + '-Office_365_Licenses.csv' 
    Write-Verbose -Message "clearing the logfile $logfile if it exists"
    Remove-Item -Path $logfile -ErrorAction SilentlyContinue
 
    # Get a list of all licences that exist within the tenant 
    Write-Verbose -Message "getting the tenant GUID for $customerdomain"
    $tenID = Get-CustomerGUID -domain $customerdomain -cred $cred
    if ($tenID)  
    {
        Write-Information -MessageData "Getting license information for users in $customerdomain" -InformationAction Continue
    } Else 
    {
        Write-Information -MessageData "No GUID returned for $customerdomain. Are we trusted for delegated Administration?" -InformationAction Stop
    }
    
    $licensetype = Get-MsolAccountSku  -TenantId $tenID| Where-Object -FilterScript {
        $_.ConsumedUnits -ge 1
    } 
    # $licensetype = Get-MsolAccountSku -TenantId $tenID 
    # Loop through all licence types found in the tenant 
    foreach ($license in $licensetype)  
    {     
        # Build and write the Header for the CSV file 
        $headerstring = 'DisplayName,UserPrincipalName,AccountSku' 
     
        foreach ($row in $($license.ServiceStatus))  
        {
            # Build header string 
            switch -wildcard ($($row.ServicePlan.servicename)) 
            { 
                'EXCHANGE_L_STANDARD' 
                {
                    $thisLicence = 'Exchange Online Plan 1' 
                } 
                'EXCHANGE_S_STANDARD_MIDMARKET' 
                {
                    $thisLicence = 'Exchange Online Plan 1' 
                } 
                'EXCHANGE_S_STANDARD' 
                {
                    $thisLicence = 'Exchange Online Plan 1' 
                } 
                'EXCHANGE_S_ENTERPRISE' 
                {
                    $thisLicence = 'Exchange Online Plan 2' 
                } 
                'EXCHANGE_S_DESKLESS' 
                {
                    $thisLicence = 'Exchange Online Kiosk' 
                }
                'EXCHANGE_S_DESKLESS_GOV' 
                {
                    $thisLicence = 'Exchange Online Kiosk Gov' 
                }
                'EXCHANGESTANDARD_GOV' 
                {
                    $thisLicence = 'Exchange Online Plan 1 Gov' 
                }
                'EXCHANGEENTERPRISE_GOV' 
                {
                    $thisLicence = 'Exchange Online Plan 2 Gov' 
                }
                'EXCHANGE_S ARCHIVE_ADDON' 
                {
                    $thisLicence = 'Exchange Online Archive'
                }
                'EXCHANGE_S_ENTERPRISE_GOV' 
                {
                    $thisLicence = 'Exchange Online Plan 2 Gov' 
                }
                'EXCHANGE_S ARCHIVE_ADDON_GOV' 
                {
                    $thisLicence = 'Exchange Online Archive Gov'
                }
                'EXCHANGESTANDARD_STUDENT' 
                {
                    $thisLicence = 'Exchange Online Plan 1 Student' 
                }
                'EOP_ENTERPRISE*' 
                {
                    $thisLicence = 'Exchange Online Protection' 
                } 
                'MCOLITE' 
                {
                    $thisLicence = 'Skype for Business Online Plan 1' 
                } 
                'MCOSTANDARD_MIDMARKET' 
                {
                    $thisLicence = 'Skype for Business Online Plan 1' 
                } 
                'MCOSTANDARD' 
                {
                    $thisLicence = 'Skype for Business Online Plan 2' 
                }
                'MCOIMP' 
                {
                    $thisLicence = 'Skype for Business Online Plan 1' 
                }
                'MCOEV' 
                {
                    $thisLicence = 'Skype for Business Cloud PBX' 
                }
                'MCOPLUSCAL' 
                {
                    $thisLicence = 'Skype for Business Plus CAL' 
                }
                'MCOSTANDARD_GOV' 
                {
                    $thisLicence = 'Skype for Business Online Plan 2 Gov' 
                }
                'MCVOICECONF' 
                {
                    $thisLicence = 'Skype for Business Online Plan 3' 
                }		
                'OFFICESUBSCRIPTION_STUDENT' 
                {
                    $thisLicence = 'Office ProPlus Student Benefit'
                }
                'OFFICESUBSCRIPTION' 
                {
                    $thisLicence = 'Office ProPlus'
                }
                'SHAREPOINTWAC' 
                {
                    $thisLicence = 'Office Online'
                }
                'SHAREPOINTLITE' 
                {
                    $thisLicence = 'SharePoint Online (Plan 1)'
                }
                'SHAREPOINTDESKLESS' 
                {
                    $thisLicence = 'SharePoint Online Kiosk'
                }
                'SHAREPOINTENTERPRISE' 
                {
                    $thisLicence = 'SharePoint Online (Plan 2)'
                }
                'SHAREPOINTLITE' 
                {
                    $thisLicence = 'SharePoint Online (Plan 1)'
                }
                'SHAREPOINTSTANDARD' 
                {
                    $thisLicence = 'SharePoint Online (Plan 1)'
                }
                'INTUNE_O365' 
                {
                    $thisLicence = 'Intune' 
                } 
                'INTUNE_A' 
                {
                    $thisLicence = 'Intune' 
                } 
                'YAMMER_ENTERPRISE' 
                {
                    $thisLicence = 'Yammer Enterprise' 
                }
                'RMS_S_ENTERPRISE' 
                {
                    $thisLicence = 'Azure AD Rights Management' 
                }
                'RMS_S_ADHOC' 
                {
                    $thisLicence = 'Rights Management for individuals' 
                }
                'RIGHTSMANAGEMENT_ADHOC' 
                {
                    $thisLicence = 'Rights Management for individuals' 
                }
                'PROJECT_ESSENTIALS' 
                {
                    $thisLicence = 'Project Lite' 
                }
                'RMS_S_PREMIUM' 
                {
                    $thisLicence = 'Rights Managegment Service Premium' 
                }
                'PROJECTESSENTIALS' 
                {
                    $thisLicence = 'Project Lite'
                }
                'AAD_PREMIUM' 
                {
                    $thisLicence = 'Azure Active Directory Premium'
                }
                'MFA_PREMIUM' 
                {
                    $thisLicence = 'Multi Factor Authentication Premium'
                }
                'SHAREPOINT_PROJECT' 
                {
                    $thisLicence = 'Project Online'
                }
                'BI_AZURE_P0' 
                {
                    $thisLicence = 'Power BI Free'
                }
                default 
                {
                    $thisLicence = $row.ServicePlan.servicename 
                } 
            } 
         
            $headerstring = ($headerstring + ',' + $thisLicence) 
        } 
     
        Out-File -FilePath $logfile -InputObject $headerstring -Encoding UTF8 -Append 
     
        Write-Verbose -Message ('Gathering users with the following subscription: ' + $license.accountskuid) 
 
        # Gather users for this particular AccountSku 
        $users = Get-MsolUser -all -TenantId $tenID | Where-Object -FilterScript {
            $_.isLicensed -eq 'True' -and $_.licenses[0].accountskuid.tostring() -eq $license.accountskuid
        } 
   
 
        # Loop through all users and write them to the CSV file 
        foreach ($User in $users) 
        {
            Write-Information -MessageData ('Processing ' + $User.displayname) -InformationAction Continue
 
            $datastring = ($User.displayname + ',' + $User.userprincipalname + ',' + $Sku.Item($User.licenses[0].AccountSku.SkuPartNumber)) 
         
            foreach ($row in $($User.licenses[0].servicestatus)) 
            {
                # Build data string 
                $datastring = ($datastring + ',' + $($row.provisioningstatus)) 
            } 
         
            Out-File -FilePath $logfile -InputObject $datastring -Encoding UTF8 -Append
        } 
    }             
 
    Write-Information -MessageData ('Script Completed.  Results available in ' + $logfile) -InformationAction Continue
}

function Get-CustomerGUID 
{
    <#   
            .SYNOPSIS
            This function gets the GUID from a Office 365 tenant domain name

            .DESCRIPTION
            Using a domain name, this function can fetch the Azure AD GUID for the customer. 

            .PARAMETER  Domain
            The domain name to get the GUID from

            .PARAMETER Cred
            A credential object
            you can get this by running the command: 
            $cred = Get-Credential
            and entering a username and password
        


            .EXAMPLE
            Get-CustomerGuid -Domain 'domain.com' -Cred $cred
            7abed0d5-4b76-45bf-a756-fdea2645509c

            .EXAMPLE
            $CustomerGUID = Get-CustomerGUID Get-CustomerGuid -Domain 'domain.com' -Cred $cred
            This will populate the variable $CustomerGUID with the GUID of the customer
            
    #>
    [cmdletbinding()]

    param (
        [Parameter (position = 0,HelpMessage = 'The domain name', ValueFromPipeline = $TRUE,Mandatory = $TRUE)]
        [String]$Domain,
        [Parameter (position = 1,HelpMessage = 'a credential object',Mandatory = $TRUE)]
        [Object]$Cred

    )
    begin {}
    process{
    Write-Verbose -Message 'Connecting to MSOLSERVICE'
    $username = ($cred | Select-Object -ExpandProperty username)
    Write-Debug -Message "Connecting to MSOLSERVICE using $username" 
    Connect-MsolService -Credential $cred
    
    Write-Verbose -Message 'Getting tenant GUID'
    Write-Debug -Message "Getting tenant GUID for $domain"
   
    $tenID = (Get-MsolPartnerContract -domain $domain).tenantId.guid 
    
    Write-Debug -Message "Returning $tenID"
    return $tenID
    }
    end{}
}
function Get-LogEntries 
{
 <#   
    .SYNOPSIS
        Gets events from an eventlog

    .DESCRIPTION
        This function will get the <number> latest entries of a specified event in a specified eventlog.
        Security log access requires elevated privileges so you need to run powershell as admin to query 
        the security log. You should be able to query any other log as any user. 

    .PARAMETER  logname
        Specifies the log you wish to query
        Default value is Security

    .PARAMETER  Computer
        Specifies the computer to get events from
        Default values is you local computer

    .PARAMETER  Event
        Specifies EventID you want to search for
        Default value is 4624

    .PARAMETER  NumberOfEvents
        Specifies the number of events you want to include
        Default Value is 30

    .EXAMPLE
        Get-LogEntries
        This will output to screen the latest 30 events with the eventID 4624 from the security log
        Or produce an error if you forgot that security log access requires elevated privileges ;-)  

    .EXAMPLE
        Get-LogEntries -Logname System -Event 1500 -NumberOfEvents 30 | Export-Csv h:\events.txt -NoTypeInformation
        This command will produce a CSV with the latest 30 events with eventID 1500 from the system log



    #>

    [cmdletbinding()]

    param (
        [Parameter (position = 0, ValueFromPipeline = $TRUE)]
        [String]$Logname = 'Security',

        [Parameter (position = 1)]
        [String]$Computer = $env:COMPUTERNAME,

        [Parameter (Position = 2)]
        [string]$Event = '4624',

        [Parameter (Position = 3)]
        [string]$NumberOfEvents = '30'
    )

    #Add Verbose output
    Write-Verbose -Message "Using $logname" 
    Write-Verbose -Message "Asking the computer named $computer"
    Write-Verbose -Message "Getting the first $numberofevents events with the EventId $event"
    Write-Debug -Message "Using $logname" 
    Write-Debug -Message "Asking the computer named $computer"
    Write-Debug -Message "Getting the first $numberofevents events with the EventId $event"

    #The actual script
    Get-EventLog -LogName $logname -ComputerName $computer |
    Where-Object -Property EventID -EQ -Value $event |
    Select-Object -First $numberofevents
}

function add-secondaryadmin 
{
    <#   

            .SYNOPSIS
            adds a secondary admin on all users onedrive for business
        
            .DESCRIPTION
            This function adds a secondary admin to all users onedrive for business. 

            .PARAMETER AdminURI
            Specifies the uri for the sharepoint admin portal.
         

            .PARAMETER AdminAccount
            ASpeciefies the user name of the Global Admin
           

            .PARAMETER AdminPass
            Specifies the password for the Global Admin.
           

            .PARAMETER Secondaryadmin
            Specifies the user name of the secondary admin.
           

            .PARAMETER siteURI
            Specifies the Sitecollection for the OneDrive.
            

    
            .EXAMPLE
            Get-TenantLicenseReport -CustomerDomain axians.se -cred $login
            Gets a license report from the Customer axians.se with a credential stored in the variable $login
            

    #>
    [cmdletbinding()]

    param (
        [Parameter (position = 0,HelpMessage = 'The customers domain name',Mandatory = $TRUE)]
        [String]$AdminURI,
        [Parameter (position = 1,HelpMessage = 'a credential object',Mandatory = $TRUE)]
        [String]$AdminAccount,
        [Parameter (position = 2,HelpMessage = 'The customers domain name',Mandatory = $TRUE)]
        [String]$AdminPass,
        [Parameter (position = 3,HelpMessage = 'The customers domain name',Mandatory = $TRUE)]
        [String]$secondaryadmin,
        [Parameter (position = 4,HelpMessage = 'The url for the onedrive site collection',Mandatory = $TRUE)]
        [String]$siteURI
        

    ) 


    $loadInfo1 = Add-Type -AssemblyName 'Microsoft.SharePoint.Client, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c'
    $loadInfo2 = Add-Type -AssemblyName 'Microsoft.SharePoint.Client.Runtime, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c'
    $loadInfo3 = Add-Type -AssemblyName 'Microsoft.SharePoint.Client.UserProfiles, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c'


    $sstr = ConvertTo-SecureString -string $AdminPass -AsPlainText -Force
    $AdminPass = ''
    $creds = New-Object -TypeName Microsoft.SharePoint.Client.SharePointOnlineCredentials -ArgumentList ($AdminAccount, $sstr)
    $UserCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AdminAccount, $sstr

    # Add the path of the User Profile Service to the SPO admin URL, then create a new webservice proxy to access it
    $proxyaddr = "$AdminURI/_vti_bin/UserProfileService.asmx?wsdl"
    $UserProfileService = New-WebServiceProxy -Uri $proxyaddr -UseDefaultCredential -Class False
    $UserProfileService.Credentials = $creds

    # Set variables for authentication cookies
    $strAuthCookie = $creds.GetAuthenticationCookie($AdminURI)
    $uri = New-Object -TypeName System.Uri -ArgumentList ($AdminURI)
    $container = New-Object -TypeName System.Net.CookieContainer
    $container.SetCookies($uri, $strAuthCookie)
    $UserProfileService.CookieContainer = $container

    # Sets the first User profile, at index -1
    $UserProfileResult = $UserProfileService.GetUserProfileByIndex(-1)
    Write-Verbose -Message 'Starting- This could take a while.'
    $NumProfiles = $UserProfileService.GetUserProfileCount()
    $i = 1

    Connect-SPOService -Url $AdminURI -Credential $UserCredential

    # As long as the next User profile is NOT the one we started with (at -1)...
    While ($UserProfileResult.NextValue -ne -1) 
    {
        Write-Verbose -Message "Examining profile $i of $NumProfiles"
        # Look for the Personal Space object in the User Profile and retrieve it 
        # (PersonalSpace is the name of the path to a user's OneDrive for Business site. Users who have not yet created a  
        # OneDrive for Business site might not have this property set.)
        $Prop = $UserProfileResult.UserProfile | Where-Object -FilterScript {
            $_.Name -eq 'PersonalSpace' 
        } 
        $Url = $Prop.Values[0].Value

        # If OneDrive is activated for the user, then set the secondary admin
        if ($Url) 
        {
            $sitename = $siteURI + $Url
            $temp = Set-SPOUser -Site $sitename -LoginName $secondaryadmin -IsSiteCollectionAdmin $TRUE -ErrorAction SilentlyContinue
            Write-Verbose -Message "removed secondary admin to the site $($sitename)" 
        }

        # And now we check the next profile the same way...
        $UserProfileResult = $UserProfileService.GetUserProfileByIndex($UserProfileResult.NextValue)
        $i++
    }
}

function Remove-SecondaryAdmin 
{
    <#   

            .SYNOPSIS
                removes a user account from being a secondary admin  on users onedrive for business
        
            .DESCRIPTION
                This function removes a named user from being a secondary admin on all OneDrives that are provisioned in
                a tenant. Unfortunately it will also remove the user from being a admin on his own OneDrive if the user has one. 
                You will need to add that user back as an admin on his own OneDrive.

            .PARAMETER AdminURI
                Specifies the uri for the sharepoint admin portal.


            .PARAMETER AdminAccount
                Specifies the user name of the Global Admin


            .PARAMETER AdminPass
                Specifies the password for the Global Admin.


            .PARAMETER Secondaryadmin
                Specifies the user name of the secondary admin.


            .PARAMETER siteURI
                Specifies the Sitecollection for the OneDrive.

   
            .EXAMPLE
            Get-TenantLicenseReport -CustomerDomain axians.se -cred $login
            Gets a license report from the Customer axians.se with a credential stored in the variable $login
            

            .NOTES
            You need to have a credential captured with "$login = get-credential"


    #>
    [cmdletbinding()]

    param (
        [Parameter (position = 0,HelpMessage = 'The customers domain name',Mandatory = $TRUE)]
        [String]$AdminURI,
        [Parameter (position = 1,HelpMessage = 'a credential object',Mandatory = $TRUE)]
        [String]$AdminAccount,
        [Parameter (position = 2,HelpMessage = 'The customers domain name',Mandatory = $TRUE)]
        [String]$AdminPass,
        [Parameter (position = 3,HelpMessage = 'The customers domain name',Mandatory = $TRUE)]
        [String]$secondaryadmin,
        [Parameter (position = 4,HelpMessage = 'The url for the onedrive site collection',Mandatory = $TRUE)]
        [String]$siteURI
        

    ) 


    $loadInfo1 = Add-Type -AssemblyName 'Microsoft.SharePoint.Client, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c'
    $loadInfo2 = Add-Type -AssemblyName 'Microsoft.SharePoint.Client.Runtime, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c'
    $loadInfo3 = Add-Type -AssemblyName 'Microsoft.SharePoint.Client.UserProfiles, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c'


    $sstr = ConvertTo-SecureString -string $AdminPass -AsPlainText -Force
    $AdminPass = ''
    $creds = New-Object -TypeName Microsoft.SharePoint.Client.SharePointOnlineCredentials -ArgumentList ($AdminAccount, $sstr)
    $UserCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AdminAccount, $sstr

    # Add the path of the User Profile Service to the SPO admin URL, then create a new webservice proxy to access it
    $proxyaddr = "$AdminURI/_vti_bin/UserProfileService.asmx?wsdl"
    $UserProfileService = New-WebServiceProxy -Uri $proxyaddr -UseDefaultCredential -Class False
    $UserProfileService.Credentials = $creds

    # Set variables for authentication cookies
    $strAuthCookie = $creds.GetAuthenticationCookie($AdminURI)
    $uri = New-Object -TypeName System.Uri -ArgumentList ($AdminURI)
    $container = New-Object -TypeName System.Net.CookieContainer
    $container.SetCookies($uri, $strAuthCookie)
    $UserProfileService.CookieContainer = $container

    # Sets the first User profile, at index -1
    $UserProfileResult = $UserProfileService.GetUserProfileByIndex(-1)
    Write-Verbose -Message 'Starting- This could take a while.'
    $NumProfiles = $UserProfileService.GetUserProfileCount()
    $i = 1

    Connect-SPOService -Url $AdminURI -Credential $UserCredential

    # As long as the next User profile is NOT the one we started with (at -1)...
    While ($UserProfileResult.NextValue -ne -1) 
    {
        Write-Verbose -Message "Examining profile $i of $NumProfiles"
        # Look for the Personal Space object in the User Profile and retrieve it 
        # (PersonalSpace is the name of the path to a user's OneDrive for Business site. Users who have not yet created a  
        # OneDrive for Business site might not have this property set.)
        $Prop = $UserProfileResult.UserProfile | Where-Object -FilterScript {
            $_.Name -eq 'PersonalSpace' 
        } 
        $Url = $Prop.Values[0].Value

        # If OneDrive is activated for the user, then set the secondary admin
        if ($Url) 
        {
            $sitename = $siteURI + $Url
            $temp = Set-SPOUser -Site $sitename -LoginName $secondaryadmin -IsSiteCollectionAdmin $FALSE -ErrorAction SilentlyContinue
            Write-Verbose -Message "removed secondary admin to the site $($sitename)" 
        }

        # And now we check the next profile the same way...
        $UserProfileResult = $UserProfileService.GetUserProfileByIndex($UserProfileResult.NextValue)
        $i++
    }
}

function Get-OneDriveProvisioning 
{
    <#   

            .SYNOPSIS
            Checks the status of OneDrive Provisioning on a tenant
    
            .DESCRIPTION
            This function checks which users have a OneDrive provisioned in a Office 365 tenant.

            .PARAMETER AdminURI
            Specifies the uri for the sharepoint admin portal.


            .PARAMETER AdminAccount
            ASpeciefies the user name of the Global Admin


            .PARAMETER AdminPass
            Specifies the password for the Global Admin.


            .PARAMETER Logfile
            Specifies the Sitecollection for the OneDrive. 
            c:\temp\ListOfMysites.txt is default

                          
            .EXAMPLE
            Get-OneDriveProvisioning -AdminURI https://qbranch365-admin.sharepoint.com -AdminAccount psadmin@qbranch365.onmicrosoft.com -AdminPass hemlig
            Lists all OneDrives that are provisioned

            .NOTES
            You need to have a credential captured with "$login = get-credential"

            .OUTPUTS
            a CSV file in C:\temp that lists the users and their respective license assignments
    #>
    [cmdletbinding()]

    param (
        [Parameter (position = 0,HelpMessage = 'the uri to the admin service',Mandatory = $TRUE)]
        [String]$AdminURI,
        [Parameter (position = 1,HelpMessage = 'the username of a global admin',Mandatory = $TRUE)]
        [String]$AdminAccount,
        [Parameter (position = 2,HelpMessage = 'the password of the global admin',Mandatory = $TRUE)]
        [String]$AdminPass,
        [Parameter (position = 3)]
        [String]$logfile = 'C:\temp\ListOfMysites.txt'
        

    ) 


    # Begin the process

    $loadInfo1 = Add-Type -AssemblyName 'Microsoft.SharePoint.Client, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c'
    $loadInfo2 = Add-Type -AssemblyName 'Microsoft.SharePoint.Client.Runtime, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c'
    $loadInfo3 = Add-Type -AssemblyName 'Microsoft.SharePoint.Client.UserProfiles, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c'


    # Convert the Password to a secure string, then zero out the cleartext version ;)
    $sstr = ConvertTo-SecureString -string $AdminPass -AsPlainText -Force
    $AdminPass = ''

    # Take the AdminAccount and the AdminAccount password, and create a credential

    $creds = New-Object -TypeName Microsoft.SharePoint.Client.SharePointOnlineCredentials -ArgumentList ($AdminAccount, $sstr)


    # Add the path of the User Profile Service to the SPO admin URL, then create a new webservice proxy to access it
    $proxyaddr = "$AdminURI/_vti_bin/UserProfileService.asmx?wsdl"
    $UserProfileService = New-WebServiceProxy -Uri $proxyaddr -UseDefaultCredential -Class False
    $UserProfileService.Credentials = $creds

    # Set variables for authentication cookies
    $strAuthCookie = $creds.GetAuthenticationCookie($AdminURI)
    $uri = New-Object -TypeName System.Uri -ArgumentList ($AdminURI)
    $container = New-Object -TypeName System.Net.CookieContainer
    $container.SetCookies($uri, $strAuthCookie)
    $UserProfileService.CookieContainer = $container

    # Sets the first User profile, at index -1
    $UserProfileResult = $UserProfileService.GetUserProfileByIndex(-1)

    Write-Verbose -Message 'Starting- This could take a while.' 

    $NumProfiles = $UserProfileService.GetUserProfileCount()
    $i = 1

    # As long as the next User profile is NOT the one we started with (at -1)...
    While ($UserProfileResult.NextValue -ne -1) 
    {
        Write-Verbose -Message "Examining profile $i of $NumProfiles"

        # Look for the Personal Space object in the User Profile and retrieve it
        # (PersonalSpace is the name of the path to a user's OneDrive for Business site. Users who have not yet created a 
        # OneDrive for Business site might not have this property set.)
        $Prop = $UserProfileResult.UserProfile | Where-Object -FilterScript {
            $_.Name -eq 'PersonalSpace' 
        } 
        $Url = $Prop.Values[0].Value

        # If "PersonalSpace" (which we've copied to $Url) exists, log it to our file...
        if ($Url) 
        {
            $Url | Out-File $logfile -Append -Force
        }

        # And now we check the next profile the same way...
        $UserProfileResult = $UserProfileService.GetUserProfileByIndex($UserProfileResult.NextValue)
        $i++
    }

    Write-Verbose -Message 'Done!'
}
