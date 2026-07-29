# Locate MSBuild through the Visual Studio Installer.
$vswherePath = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
if (-not (Test-Path -LiteralPath $vswherePath)) {
    throw "Visual Studio Installer was not found: $vswherePath"
}

$msbuildPath = & $vswherePath -latest -requires Microsoft.Component.MSBuild -find 'MSBuild\**\Bin\MSBuild.exe'
if (-not $msbuildPath) {
    throw 'MSBuild was not found. Install Visual Studio with MSBuild.'
}

# Build the x64 Debug executable used by the UI tests.
$solutionPath = Join-Path $PSScriptRoot '..\..\InazumaSearch.sln'
& $msbuildPath $solutionPath /t:Build /p:Configuration=Debug /p:Platform=x64 /m /nologo /v:minimal
exit $LASTEXITCODE
