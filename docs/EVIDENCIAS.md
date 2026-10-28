# Registro das evidências reais

Este arquivo é um formulário de coleta, não uma declaração de execução.
Preencha após executar os workflows e acrescente as capturas nesta pasta.

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
