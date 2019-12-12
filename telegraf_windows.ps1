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
               #Test if the TCP Port on the server is open before applying the settings
               If ((Test-NetConnection -ComputerName $server -Port $port).TcpTestSucceeded) {
                Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyServer -Value "$($server):$($port)"
                Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyEnable -Value 1
                Get-Proxy #Show the configuration 
               }
               Else {
                    Write-Error -Message "The proxy address is not valid:  $($server):$($port)"
                    }    
                }
    Set-Proxy 10.157.240.254 8678
