param([Parameter(Mandatory=$true)][string]$Repositorio)
$ErrorActionPreference = 'Stop'
if ($Repositorio -notmatch '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$') { throw 'Use dono/repositorio.' }
$body = @{
  required_status_checks = @{
    strict = $true
    contexts = @('Build e testes', 'Gitleaks', 'SonarCloud Quality Gate', 'Trivy dependencias', 'Docker Trivy e SBOM', 'Seguranca obrigatoria')
  }
  enforce_admins = $true
  required_pull_request_reviews = @{ required_approving_review_count = 0 }
  restrictions = $null
  allow_force_pushes = $false
  allow_deletions = $false
}
$body | ConvertTo-Json -Depth 5 | gh api --method PUT "repos/$Repositorio/branches/main/protection" --input -
if ($LASTEXITCODE -ne 0) { throw 'Protecao nao aplicada. Confira permissao de administrador e disponibilidade no plano.' }
Write-Host 'main protegida: PR e todos os checks obrigatorios, inclusive para administradores.'
