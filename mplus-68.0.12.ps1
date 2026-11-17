# STN InstallTools - MplusKASSA 68.0.12
# Start Windows PowerShell 5.1 (or PowerShell 7) as administrator.
# Installer is downloaded from the MplusKASSA supplier. BackgroundWorker is skipped.
& {
    $ErrorActionPreference = 'Stop'
    $ProgressPreference = 'SilentlyContinue'
    $url = 'https://kms.kassacloud.nl/upload/attachments/4ec9a68442164390ab784bc0d95fc67c/MplusKASSA-68.0.12-Setup.msi'
    $folder = Join-Path $env:TEMP 'STN-InstallTools'
    $msi = Join-Path $folder 'MplusKASSA-68.0.12-Setup.msi'
    $log = Join-Path $folder ('MplusKASSA-68.0.12-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')
    try {
        Write-Host '[1/5] Administratorrechten controleren...' -ForegroundColor Cyan
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($identity)
        if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            throw 'Start PowerShell als administrator en probeer opnieuw.'
        }

        if (-not (Test-Path -LiteralPath $folder)) {
            New-Item -Path $folder -ItemType Directory -Force | Out-Null
        }

        Write-Host '[2/5] MplusKASSA 68.0.12 downloaden...' -ForegroundColor Cyan
        if ([Net.ServicePointManager]::SecurityProtocol -band [Net.SecurityProtocolType]::Tls12 -eq 0) {
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        }

        try {
            Invoke-WebRequest -Uri $url -OutFile $msi -UseBasicParsing -ErrorAction Stop
        }
        catch {
            Write-Warning 'Standaarddownload mislukt. Alternatieve downloadmethode proberen.'
            Remove-Item -LiteralPath $msi -Force -ErrorAction SilentlyContinue
            $client = New-Object System.Net.WebClient
            try { $client.DownloadFile($url, $msi) }
            finally { $client.Dispose() }
        }

        if (-not (Test-Path -LiteralPath $msi) -or (Get-Item -LiteralPath $msi).Length -lt 1MB) {
            throw 'De download is leeg of onverwacht klein.'
        }

        Write-Host '[3/5] MSI-handtekening controleren...' -ForegroundColor Cyan
        $signature = Get-AuthenticodeSignature -LiteralPath $msi
        if ($signature.Status -ne 'Valid') {
            throw "MSI-handtekening is niet geldig: $($signature.Status). Installatie afgebroken."
        }

        Write-Host '[4/5] MplusKASSA installeren (BackgroundWorker uit)...' -ForegroundColor Cyan
        $args = '/i "{0}" INSTALL_BW_ACTION=0 /qn /norestart /L*v "{1}"' -f $msi, $log
        $process = Start-Process -FilePath 'msiexec.exe' -ArgumentList $args -Wait -PassThru
        if ($process.ExitCode -notin @(0, 3010)) {
            throw "MSI-installatie mislukt (exitcode $($process.ExitCode)). Log: $log"
        }

        Write-Host '[5/5] Downloadbestand opruimen...' -ForegroundColor Cyan
        Remove-Item -LiteralPath $msi -Force -ErrorAction SilentlyContinue

        Write-Host 'MplusKASSA 68.0.12: installatie geslaagd.' -ForegroundColor Green
        Write-Host "Installatielog: $log"
        if ($process.ExitCode -eq 3010) {
            Write-Warning 'Herstart Windows voordat je MplusKASSA gebruikt.'
        }
        else {
            Write-Host 'Start MplusKASSA en voer de lokale schema-upgrade handmatig uit.' -ForegroundColor Green
        }
    }
    catch {
        Write-Host ("INSTALLATIE MISLUKT: " + $_.Exception.Message) -ForegroundColor Red
        Write-Host "Log (indien aangemaakt): $log" -ForegroundColor Yellow
        throw
    }
}
