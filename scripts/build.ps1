# Set path
$env:Path += ";C:\Program Files (x86)\Windows Kits\10\bin\10.0.18362.0\x64;C:\Program Files (x86)\Windows Kits\10\bin\10.0.17763.0/x64"

### download pre-build exiftool
Invoke-WebRequest https://exiftool.org/exiftool-12.16.zip -O exiftool.zip
7z e -y exiftool.zip -oconvert
Move-Item -force "convert\exiftool(-k).exe" "convert\exiftool.exe"
Remove-Item exiftool.zip

### Build project
echo "Build decart ..."
$tag = git describe --tags --abbrev=0
go build -tags gui -o decart.exe `
         -ldflags "-X 'decart/internal/cloud.credentials=$env:DECART_SERVICE_ACCOUNT' `
                   -X 'decart/internal/config.Version=$tag' `
                   -H 'windowsgui'"


### Replace tag string in files
echo "Embed version tag ..."
$v4d = "$($tag.TrimStart("v")).0"
((Get-Content -path AppxManifest.template.xml -Raw) -replace '__VERSION__',$v4d) | Set-Content -Path AppxManifest.xml

### Process & Convert Assets
cp assets\Square44x44Logo.png assets\Square44x44Logo.targetsize-48.png
cp assets\Square44x44Logo.png assets\Square44x44Logo.targetsize-48_altform-unplated.png

.\scripts\icon.ps1

### Generate Appx mapping list
echo "Generate mapping ..."
Get-ChildItem AppxManifest.xml,decart.exe,assets,convert,mosaique -recurse | ForEach-Object { "[Files]" } {
    $f = Resolve-Path $_.FullName -Relative
    $n = $f.TrimStart(".\")
    """$f""  ""$n"""
} > mapping.txt

### Pack, /v for verbose
$target = "test-win-$tag.appx"
echo "Generate AppX package ..."
MakeAppx pack /f mapping.txt /p $target
Remove-Item mapping.txt

### Sign package, /v for verbose
echo "Sign AppX package ..."
signtool sign /a /fd SHA256 /f $env:CODESIGN_CERTIFICATE /p $env:CERTIFICATE_PASSWORD $target

# # upload to artifacts repository
# if (Get-Command gsutil -errorAction SilentlyContinue) {
#     gsutil cp $target gs://build.aixmed.com/decart/
# }