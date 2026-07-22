param(
    [switch]$SkipAndroid
)

$ErrorActionPreference = 'Stop'

function Invoke-FlutterStep {
    param(
        [string]$Label,
        [string[]]$Arguments
    )

    Write-Host "`n[$Label] flutter $($Arguments -join ' ')" -ForegroundColor Cyan
    & flutter @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Label failed with exit code $LASTEXITCODE."
    }
}

Invoke-FlutterStep -Label 'Dependencies' -Arguments @('pub', 'get')
Invoke-FlutterStep -Label 'Dependency audit' -Arguments @(
    'pub', 'outdated', '--no-dev-dependencies'
)
Invoke-FlutterStep -Label 'Static analysis' -Arguments @('analyze')
Invoke-FlutterStep -Label 'Tests' -Arguments @('test')
Invoke-FlutterStep -Label 'Web release' -Arguments @(
    'build', 'web', '--release', '--no-wasm-dry-run'
)

if (-not $SkipAndroid) {
    Invoke-FlutterStep -Label 'Android release' -Arguments @(
        'build', 'apk', '--release'
    )
}

Write-Host "`nLinguaTomo verification passed." -ForegroundColor Green
