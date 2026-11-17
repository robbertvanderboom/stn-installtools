# STN InstallTools

Automatische installatie van **MplusKASSA 68.0.12** voor STN-support.

## Uitvoeren

Open **Windows PowerShell als administrator** en voer uit:

```powershell
irm https://raw.githubusercontent.com/robbertvanderboom/stn-installtools/main/mplus.ps1 | iex
```

Deze opdracht downloadt en voert het publiek beschikbare script uit. Gebruik hem alleen als je de repository en eventuele wijzigingen vertrouwt.

## Werking

1. Controleert administratorrechten.
2. Downloadt de MSI rechtstreeks van `kms.kassacloud.nl`, met een alternatieve downloadmethode.
3. Controleert de digitale handtekening van de MSI.
4. Installeert stil met `INSTALL_BW_ACTION=0`, dus **zonder BackgroundWorker**.
5. Verwijdert de gedownloade MSI en bewaart de MSI-log onder `%TEMP%\STN-InstallTools`.

Windows Installer exitcode `0` is geslaagd; `3010` betekent geslaagd met herstart vereist. Bij fouten wordt de loglocatie getoond.

**Na installatie:** start MplusKASSA zelf en voer de lokale schema-upgrade handmatig uit.

## Onderhoud

- De MSI-URL en versie zijn bewust vastgezet op **68.0.12**. Nieuwe versies eerst testen en pas daarna aanpassen.
- Het uitschakelen van BackgroundWorker is getest in de oorspronkelijke installatietest; de gehoste variant moet nog op een testmachine worden gecontroleerd.
- Publiceer geen secrets of klantgegevens.
- Controleer GitHub-wijzigingen voordat je een script op klantmachines met administratorrechten uitvoert.
