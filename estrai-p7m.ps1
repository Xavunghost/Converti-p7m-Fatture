# Percorso dell'eseguibile OpenSSL, usato per decodificare le buste firmate .p7m
$openssl = "C:\Program Files\OpenSSL-Win64\bin\openssl.exe"

# Cartella da cui leggere i file .xml.p7m da convertire
$inputDir = Join-Path $PSScriptRoot "input"
# Cartella dove salvare gli XML estratti
$outputDir = Join-Path $PSScriptRoot "output"

# Crea la cartella di output se non esiste ancora
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

# Per ogni fattura firmata trovata in input, estrae l'XML e lo scrive in output
Get-ChildItem -Path $inputDir -Filter *.xml.p7m | ForEach-Object {
    $inFile = $_.FullName
    # Stesso nome del file originale, senza l'estensione .p7m
    $outFile = Join-Path $outputDir ($_.Name -replace '\.p7m$', '')

    # cms -verify decodifica la busta CMS/CAdES ed estrae il contenuto firmato (l'XML).
    # -noverify disabilita il controllo di validita' del certificato/firma:
    # serve solo a recuperare il contenuto, non a validare l'autenticita'.
    & $openssl cms -verify `
        -binary `
        -inform DER `
        -in "$inFile" `
        -noverify `
        -out "$outFile"
}
