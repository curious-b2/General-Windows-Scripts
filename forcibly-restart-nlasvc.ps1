# Elevate permissions, if we don't currently have admin rights.
if (!(New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Start-Process -FilePath 'powershell' -ArgumentList ('-File', $MyInvocation.MyCommand.Source, $args | %{ $_ }) -Verb RunAs
    exit
}

# Handy function
function Get-ServicePidFromName($TargetName) {
    $ProcessID = $(Get-WmiObject Win32_Process -Filter 'name = "svchost.exe"' | Where-Object {$_.CommandLine -like "*$TargetName"} | Select -ExpandProperty ProcessId)
    return $ProcessID
}

# And why not make this a function to handle other services in the future?
function ForciblyRestartService($TargetName) {
    $targetPID = Get-ServicePidFromName($TargetName)
    if ($targetPID -ge 0) {
        Write-Host 'Starting NlaSvc PID: '$targetPID
    } else {
        Write-Host '$targetPID = '$targetPID
        return
    }
    Write-Host -NoNewline "Attempting to restart $TargetName nicely..."

    Restart-Service -Name NlaSvc

    $newPid = Get-ServicePidFromName($TargetName)

    if ($targetPID -ne $newPID) {
        Write-Host -ForegroundColor Green 'Success.'
        return
    }

    Write-Host -ForegroundColor Red 'System refused.'

    Write-Host -NoNewline "Attempting to restart $TargetName with -Force option..."

    Start-Sleep -s 1

    Restart-Service -Name NlaSvc -Force

    $newPid = Get-ServicePidFromName($TargetName)

    if ($targetPID -ne $newPID) {
        Write-Host -ForegroundColor Green 'Restarted NlaSvc forcefully.'
        return
    }

    Write-Host -ForegroundColor Red 'System refused.'

    Write-Host -NoNewline "Attempting to restart $TargetName by killing its PID..."

    Start-Sleep -s 1
    taskkill.exe /F /PID $targetPID 2>&1 >$null

    Start-Sleep -s 1
    $newPid = Get-ServicePidFromName($TargetName)

    if ($targetPID -ne $newPID) {
        Write-Host -ForegroundColor Green 'Success'
    } else {
        Write-Host -ForegroundColor Red 'System refused.'
    }
}

#Should probably change this to accept an arg or default
$TargetName='NlaSvc'
ForciblyRestartService($TargetName) 2>$null
Write-Host 'Sanity check: NlaSvc PID is now'$(Get-ServicePidFromName($TargetName))
read-host 'Press ENTER to continue'
