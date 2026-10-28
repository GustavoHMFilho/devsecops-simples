# Registro das evidências reais

## Evidências já verificadas

- Repositório: https://github.com/GustavoHMFilho/devsecops-simples
- PR da demonstração: https://github.com/GustavoHMFilho/devsecops-simples/pull/1
- Execução reprovada por CVE: https://github.com/GustavoHMFilho/devsecops-simples/actions/runs/40610966069
- Commit vulnerável: `3b603313ae5b421b3875c87bf92691789eeb4fef`.
- Correção: commit `c0ff23d`, cross-spawn atualizado para 7.0.6 no mesmo PR.
- Resultado consultado na API do PR antes da correção: `mergeStateStatus: BLOCKED`.
- Relatório real: [dependencies.json](evidencias/falha/dependencies.json).
- Trecho extraído do relatório: [cve-resumo.json](evidencias/falha/cve-resumo.json).
- Achado: CVE-2024-21538, cross-spawn 7.0.3, HIGH, FixedVersion `7.0.5, 6.0.6`.
- Build/testes e Gitleaks passaram no GitHub. Trivy reprovou a dependência e a imagem vulneráveis.
- Testes locais: 6 aprovados; cobertura de linhas, branches e funções de `src/app.js`: 100%.

O restante da tabela é um formulário de coleta. Ainda é necessário concluir
o SonarCloud no GitHub Actions, registrar a execução aprovada e incluir as
capturas exigidas. A captura automatizada do Edge foi impedida pelo controle
de navegação do ambiente; o relatório JSON não é uma captura de tela.

| Item | Link/arquivo/resultado |
|---|---|
| Aluno e matrícula | A preencher |
| Repositório GitHub | A preencher |
| Execução inicial com as ferramentas | A preencher |
| Projeto SonarCloud e condições do gate | A preencher |
| Captura do Quality Gate de código novo | A preencher |
| Proteção da main e checks exigidos | A preencher |
| PR da demonstração | A preencher |
| SHA do commit com cross-spawn 7.0.3 | A preencher |
| URL da execução reprovada | A preencher |
| Captura do merge bloqueado | A preencher |
| JSON do Trivy com CVE-2024-21538 | A preencher |
| SHA do commit corrigido, cross-spawn 7.0.6 | A preencher |
| URL da execução aprovada | A preencher |
| Captura de todos os checks aprovados | A preencher |
| Artifact SBOM: URL e nome | A preencher |
| SBOM baixado, com componentes e versões | A preencher |
| Execução da main e imagem publicada no GHCR | A preencher |

## Trecho do relatório

Copie do JSON real as propriedades VulnerabilityID, PkgName,
InstalledVersion, FixedVersion e Severity referentes à CVE-2024-21538.
Não substitua o relatório por um exemplo inventado.

## Explicação para a apresentação

DevSecOps integra segurança ao fluxo de desenvolvimento. Neste pipeline,
o Gitleaks examina o histórico, o SonarCloud avalia o código novo e o Trivy
analisa dependências e a imagem. HIGH/CRITICAL com correção bloqueiam;
LOW/MEDIUM são registrados. O Syft gera o inventário da imagem. Os checks
obrigatórios impedem integrar uma alteração vulnerável à main, e a publicação
depende do sucesso de todos eles. Essa antecipação é o shift-left security.
