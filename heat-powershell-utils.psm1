#ps1_sysnative

# Copyright 2014 Cloudbase Solutions Srl
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#

function LogTo-File {
    param(
        $LogMessage,
        $LogFile = "C:\cfn\userdata.log",
        $Topic = "General"
    )

    $date = Get-Date
    $fullMessage = "$date | $Topic | $LogMessage"
    Add-Content -Path $LogFile -Value $fullMessage
}

function Log-HeatMessage {
    param(
        [string]$Message
    )

    Write-Host $Message
}

function Get-Proxy (){
    Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' | Select-Object ProxyServer, ProxyEnable
}

function Set-Proxy {
    [CmdletBinding()]
    [Alias('proxy')]
    [OutputType([string])]
    Param
    (
        # server address
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        $server,
        # port number
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        $port
    )

      Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyServer -Value "$($server):$($port)"
        Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyEnable -Value 1
     Get-Proxy #Show the configuration
}

function Remove-Proxy (){
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyServer -Value ""
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyEnable -Value 0
}

<#
.Synopsis
This function will set the proxy settings provided as input to the cmdlet.
.Description
This function will set the proxy server and (optinal) Automatic configuration script.
.Parameter ProxyServer
This parameter is set as the proxy for the system.
Data from. This parameter is Mandatory
.Example
Setting proxy information
Set-InternetProxy -proxy "proxy:7890"
.Example
Setting proxy information and (optinal) Automatic Configuration Script
Set-InternetProxy -proxy "proxy:7890" -acs "http://proxy:7892"
#>


Function Set-InternetProxy
{
    [CmdletBinding()]
    Param(

        [Parameter(Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String[]]$Proxy,

        [Parameter(Mandatory=$False,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [AllowEmptyString()]
        [String[]]$acs

    )

    Begin
    {

            $regKey="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

    }

    Process
    {

        Set-ItemProperty -path $regKey ProxyEnable -value 1

        Set-ItemProperty -path $regKey ProxyServer -value $proxy

        if($acs)
        {

                 Set-ItemProperty -path $regKey AutoConfigURL -Value $acs
        }

    }

    End
    {

        Write-Output "Proxy is now enabled"

        Write-Output "Proxy Server : $proxy"

        if ($acs)
        {

            Write-Output "Automatic Configuration Script : $acs"

        }
        else
        {

            Write-Output "Automatic Configuration Script : Not Defined"

        }
    }
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
function unzip {
        param( [string]$ziparchive, [string]$extractpath )
        [System.IO.Compression.ZipFile]::ExtractToDirectory( $ziparchive, $extractpath )
}

function configchange {
        param( [string]$metadataurl, [string]$metadatapath, [string]$telegrafconfpath )
        Invoke-WebRequest -Uri $metadataurl -OutFile $metadatapath
        $values = Get-Content $metadatapath | Out-String | ConvertFrom-Json
        $Env:serverid = $values.uuid
        (Get-Content $telegrafconfpath -Raw) -replace 'windowsvmid',"$($Env:serverid)" | Set-Content $telegrafconfpath
}

Export-ModuleMember -Function *
