param([Parameter(Mandatory=$true)][ValidateSet('vulneravel','corrigir')][string]$Etapa)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
if (git status --porcelain) { throw 'Salve ou descarte suas alteracoes antes da demonstracao.' }
if ($Etapa -eq 'vulneravel') {
  git switch main
  if ($LASTEXITCODE -ne 0) { throw 'Nao foi possivel acessar main.' }
  git pull --ff-only
  if ($LASTEXITCODE -ne 0) { throw 'Nao foi possivel atualizar main.' }
  git switch -c demo/cve-2024-21538
  if ($LASTEXITCODE -ne 0) { throw 'A branch ja existe ou nao foi possivel cria-la.' }
  npm.cmd install --save-exact cross-spawn@7.0.3 --ignore-scripts
  if ($LASTEXITCODE -ne 0) { throw 'Falha no npm.' }
  git add package.json package-lock.json
  git commit -m 'test: demonstrar bloqueio de CVE-2024-21538'
  if ($LASTEXITCODE -ne 0) { throw 'Falha no commit.' }
  git push -u origin demo/cve-2024-21538
  if ($LASTEXITCODE -ne 0) { throw 'Falha no push.' }
  gh pr create --base main --head demo/cve-2024-21538 --title 'Demonstracao: bloquear CVE-2024-21538 e corrigir' --body 'Dependencia cross-spawn 7.0.3 com CVE-2024-21538 (HIGH). Esta branch e exclusiva de teste. Aguardar falha do Trivy, registrar bloqueio e corrigir no mesmo PR. Nao integrar a versao vulneravel.'
  if ($LASTEXITCODE -ne 0) { throw 'Nao foi possivel abrir o PR.' }
  Write-Host 'Aguarde os checks. Capture a falha e o bloqueio ANTES de executar a correcao.'
} else {
  $branch = git branch --show-current
  if ($branch -ne 'demo/cve-2024-21538') { throw 'Execute na branch demo/cve-2024-21538.' }
  npm.cmd install --save-exact cross-spawn@7.0.6 --ignore-scripts
  if ($LASTEXITCODE -ne 0) { throw 'Falha no npm.' }
  git add package.json package-lock.json
  git commit -m 'fix: atualizar cross-spawn para 7.0.6 e corrigir CVE-2024-21538'
  if ($LASTEXITCODE -ne 0) { throw 'Falha no commit.' }
  git push
  if ($LASTEXITCODE -ne 0) { throw 'Falha no push.' }
  Write-Host 'Aguarde a nova execucao no mesmo PR. Capture todos os checks aprovados e baixe o SBOM.'
}
