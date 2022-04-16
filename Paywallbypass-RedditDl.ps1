<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍   𝔪𝔶 𝔭𝔯𝔦𝔳𝔞𝔱𝔢 𝔭𝔬𝔴𝔢𝔯𝔰𝔥𝔢𝔩𝔩 𝔭𝔯𝔬𝔣𝔦𝔩𝔢
#̷𝓍   
#̷𝓍   Get-RedditVideo.ps1 - All functions that need to be sorted
#̷𝓍   
#>

<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍   𝔪𝔶 𝔭𝔯𝔦𝔳𝔞𝔱𝔢 𝔭𝔬𝔴𝔢𝔯𝔰𝔥𝔢𝔩𝔩 𝔭𝔯𝔬𝔣𝔦𝔩𝔢
#̷𝓍   
#̷𝓍   FourresTout.ps1 - All functions that need to be sorted
#̷𝓍   
#>


function Invoke-BypassPaywall{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="url", Position=0)]
        [string]$Url,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="option")]
        [switch]$Option        
    )

    $WgetExe = (Getcmd wget.exe).Source
    $fn = New-RandomFilename -Extension 'html'
  
    Write-Host -n -f DarkRed "[BypassPaywall] " ; Write-Host -f DarkYellow "wget $WgetExe url $Url"

    $Content = Invoke-WebRequest -Uri "$Url"
    $sc = $Content.StatusCode    
    if($sc -eq 200){
        $cnt = $Content.Content
        Write-Host -n -f DarkRed "[BypassPaywall] " ; Write-Host -f DarkGreen "StatusCode $sc OK"
        Set-Content -Path "$fn" -Value "$cnt"
        Write-Host -n -f DarkRed "[BypassPaywall] " ; Write-Host -f DarkGreen "start-process $fn"
        start-process "$fn"
    }else{
        Write-Host -n -f DarkRed "[BypassPaywall] " ; Write-Host -f DarkYellow "ERROR StatusCode $sc"
    }
}


function Get-RedditAudio{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="url", Position=0)]
        [string]$Url,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="option")]
        [switch]$Option        
    )

    try{
        $Null =  Add-Type -AssemblyName System.webURL -ErrorAction Stop | Out-Null    
    }catch{}
    
    $urlToEncode = $Url
    $encodedURL = [System.Web.HttpUtility]::UrlEncode($urlToEncode) 

    Write-Host -n -f DarkRed "[RedditAudio] " ; Write-Host -f DarkYellow "The encoded url is: $encodedURL"

    #Encode URL code ends here

    $RequestUrl = "https://www.redditsave.com/info?url=$encodedURL"
    $Content = Invoke-RestMethod -Uri $RequestUrl -Method 'GET'

    $i = $Content.IndexOf('<a onclick="gtag')
    $j = $Content.IndexOf('"/d/',$i+1)
    $k = $Content.IndexOf('"',$j+1)
    $l = $k-$j
    $NewRequest = $Content.substring($j+1,$l-1)
    $RequestUrl = "https://www.redditsave.com$NewRequest"

    Write-Host -n -f DarkRed "[RedditAudio] " ; Write-Host -f DarkYellow "The encoded url is: $encodedURL"
    $WgetExe = (Getcmd wget.exe).Source

    Write-Host -n -f DarkRed "[RedditAudio] " ; Write-Host -f DarkYellow "wget $WgetExe url $Url"

    $fn = New-RandomFilename -Extension 'mp4'
    $a = @("$RequestUrl","-O","$fn")
    $p = Invoke-Process -ExePath "$WgetExe" -ArgumentList $a 
    $ec = $p.ExitCode    
    if($ec -eq 0){
        $timeStr = "$($p.ElapsedSeconds) : $($p.ElapsedMs)"
        Write-Host -n -f DarkRed "[RedditAudio] " ; Write-Host -f DarkGreen "Downloaded in $timeStr s"
        Write-Host -n -f DarkRed "[RedditAudio] " ; Write-Host -f DarkGreen "start-process $fn"
        start-process "$fn"
    }else{
        Write-Host -n -f DarkRed "[RedditAudio] " ; Write-Host -f DarkYellow "ERROR ExitCode $ec"
    }
}




function Get-RedditVideo{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="url", Position=0)]
        [string]$Url,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="option")]
        [switch]$Option        
    )

    try{
        $Null =  Add-Type -AssemblyName System.webURL -ErrorAction Stop | Out-Null    
    }catch{}
    
    $urlToEncode = $Url
    $encodedURL = [System.Web.HttpUtility]::UrlEncode($urlToEncode) 

    Write-Host -n -f DarkRed "[RedditVideo] " ; Write-Host -f DarkYellow "The encoded url is: $encodedURL"

    #Encode URL code ends here

    $RequestUrl = "https://www.redditsave.com/info?url=$encodedURL"
    $Content = Invoke-RestMethod -Uri $RequestUrl -Method 'GET'

    $i = $Content.IndexOf('"https://sd.redditsave.com/download.php')
    $j = $Content.IndexOf('"',$i+1)
    $l = $j-$i
    $RequestUrl = $Content.Substring($i+1, $l-1)
    
    $WgetExe = (Getcmd wget.exe).Source
    Write-Host -n -f DarkRed "[RedditVideo] " ; Write-Host -f DarkYellow "Please wait...."

    $fn = New-RandomFilename -Extension 'mp4'
    $a = @("$RequestUrl","-O","$fn")
    $p = Invoke-Process -ExePath "$WgetExe" -ArgumentList $a 
    $ec = $p.ExitCode    
    if($ec -eq 0){
        $timeStr = "$($p.ElapsedSeconds) : $($p.ElapsedMs)"
        Write-Host -n -f DarkRed "[RedditVideo] " ; Write-Host -f DarkGreen "Downloaded in $timeStr s"
        Write-Host -n -f DarkRed "[RedditVideo] " ; Write-Host -f DarkGreen "start-process $fn"
        start-process "$fn"
    }else{
        Write-Host -n -f DarkRed "[RedditVideo] " ; Write-Host -f DarkYellow "ERROR ExitCode $ec"
    }
}

