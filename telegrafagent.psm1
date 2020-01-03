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
#    under the License.

$ErrorActionPreference = 'Stop'
$currentLocation = "c:\cfn"
$modulePath = "heat-powershell-utils.psm1"
$fullPath = Join-Path $currentLocation $modulePath
Import-Module -Name $fullPath -DisableNameChecking -ErrorAction SilentlyContinue

$heatTemplateName = "WindowsTelegraf"
$telegrafAgentUrl = "https://dl.influxdata.com/telegraf/releases/telegraf-1.12.1_windows_amd64.zip"
$telegrafconfigUrl = "https://raw.githubusercontent.com/n-mohan/statuscheck/master/telegraf_nonprod.conf"
$telegrafziplocation = Join-Path $Env:Programfiles "telegraf-1.12.1_windows_amd64.zip"
$telegrafpath = $Env:Programfiles
$telegrafexepath = Join-Path $Env:Programfiles "telegraf\telegraf.exe"
$telegrafconfpath = Join-Path $Env:Programfiles "telegraf\telegraf.conf"
$metadataurl = "http://169.254.169.254/openstack/latest/meta_data.json"
$metadatapath = Join-Path $Env:Programfiles "telegraf\meta_data.json"
$param = "/c --service install"
$text = "Write-Output `"longrunning,tag=1 ln=2,rcb=1,runq=2 `""

function Log {
    param(
        $message
    )
    LogTo-File -LogMessage $message -Topic $heatTemplateName
    Log-HeatMessage $message
}

function Install-TelegrafAgent {
    try {
        Log "Telegraf agent installation started"
        #Invoke-WebRequest -Uri $telegrafAgentUrl -OutFile $telegrafziplocation
        Invoke-WebRequest -Uri $telegrafAgentUrl -Proxy 'http://10.157.240.254:8678' -OutFile $telegrafziplocation
        unzip  $telegrafziplocation $telegrafpath
        Invoke-WebRequest -Uri $telegrafconfigUrl -Proxy 'http://10.157.240.254:8678' -OutFile $telegrafconfpath
        configchange $metadataurl $metadatapath $telegrafconfpath
        createfile $text
        cd C:\'Program Files'\telegraf
        .\telegraf.exe --service install
        net start telegraf
        $successMessage = "Finished Telegraf Agent installation"
        Log $successMessage
        } catch {
        $failMessage = "Installation encountered an error"
        Log $failMessage
        Log "Exception details: $_.Exception.Message"
    }
}

Export-ModuleMember -Function Install-TelegrafAgent -ErrorAction SilentlyContinue
