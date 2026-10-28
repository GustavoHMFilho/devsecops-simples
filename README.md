# Pipeline DevSecOps com GitHub Actions

**Aluno:** Gustavo Henrique Moraes Filho  
**Matrícula:** 202310429  
**Disciplina:** DevOps - UFLA

## Aplicação

API em Node.js com três rotas: `GET /`, `GET /health` e `GET /runtime`.
A rota `/runtime` utiliza cross-spawn para consultar a versão do Node com
executável e argumentos fixos. O projeto integra build, testes, análise de
segurança, geração de SBOM e publicação de imagem Docker no GHCR.

## Execução local

Com Node.js 24 instalado:

```powershell
npm ci --ignore-scripts
npm run build
npm test
npm start
```

A aplicação atende na porta 3000. Os seis testes cobrem respostas válidas,
rota inexistente, método inválido e indisponibilidade do runtime. A cobertura
de linhas, branches e funções de `src/app.js` foi de 100%. O relatório LCOV
é enviado ao SonarCloud.

```powershell
docker build -t devsecops-local .
docker run --rm -p 3000:3000 devsecops-local
```

## Pipeline e critérios de bloqueio

O workflow [devsecops.yml](.github/workflows/devsecops.yml) executa na abertura,
reabertura e atualização dos PRs para `main`, em pushes para `main` e por
acionamento manual.

| Check | Verificação | Critério de falha |
|---|---|---|
| Build e testes | Sintaxe, testes e cobertura | Falha de build ou teste |
| Gitleaks | Histórico Git completo, com fetch-depth 0 e --all | Detecção de segredo |
| SonarCloud Quality Gate | SAST e Quality Gate Sonar way sobre código novo | Gate reprovado ou análise indisponível |
| Trivy dependencias | Dependências registradas no lockfile | HIGH/CRITICAL com correção disponível |
| Docker Trivy e SBOM | Imagem construída, vulnerabilidades e inventário Syft | HIGH/CRITICAL corrigível ou falha na geração do SBOM |
| Seguranca obrigatoria | Resultados dos checks anteriores | Qualquer resultado diferente de success |

O Gitleaks retorna código 1 ao detectar segredos e oculta os valores dos
achados com `--redact`. Nenhuma credencial real foi utilizada nos testes.

O SonarCloud utiliza a organização `gustavohmfilho` e o projeto
`GustavoHMFilho_devsecops-simples`. A análise automática do serviço está
desativada para utilizar o GitHub Actions. O token fica no secret
`SONAR_TOKEN`. A opção `sonar.qualitygate.wait=true` faz o scanner aguardar
o Quality Gate e retornar falha se ele reprovar. O timeout é de 300 segundos.

O Trivy gera relatórios JSON completos, incluindo LOW, MEDIUM e achados sem
correção. Em uma etapa separada, aplica `--severity HIGH,CRITICAL
--ignore-unfixed --exit-code 1`. Assim, LOW/MEDIUM são registrados sem
bloquear; HIGH/CRITICAL com correção disponível bloqueiam a execução.

O Syft gera o SBOM da imagem Docker em SPDX JSON, com componentes, versões e
relacionamentos. O arquivo é publicado como artifact do GitHub Actions.
Os relatórios também são preservados quando o Trivy reprova a execução.

## Proteção e publicação

A `main` exige PR, branch atualizada e os seis checks obrigatórios, inclusive
para administradores. A configuração está registrada em
[protecao-main.json](docs/evidencias/protecao-main.json).

A imagem é construída e examinada antes da publicação. O job de publicação
carrega a mesma imagem aprovada, sem reconstruí-la. Somente pushes para
`main`, após aprovação de todos os checks, publicam no GHCR. PRs não publicam.
A imagem final executa com usuário `node` e não inclui npm e Yarn, utilizados
apenas na etapa de build.

Imagem publicada na execução de referência:
`ghcr.io/gustavohmfilho/devsecops-simples:f61bbda2b968238f0294f0fad1a3f26e3936ccf7`.

## Demonstração da vulnerabilidade e correção

No [PR #1](https://github.com/GustavoHMFilho/devsecops-simples/pull/1), a versão cross-spawn 7.0.3 foi introduzida na branch
de teste. O Trivy identificou a CVE-2024-21538, de severidade HIGH, uma
vulnerabilidade de negação de serviço por expressão regular. O relatório
informa correção disponível em 7.0.5/6.0.6. Os testes, Gitleaks e SonarCloud
passaram enquanto o Trivy reprovou dependências e imagem, bloqueando o merge.

No mesmo PR, cross-spawn foi atualizado para 7.0.6. Após a correção, todos os
checks passaram e o PR foi integrado à `main`. A publicação ocorreu somente
depois da nova verificação na branch principal.

O [PR #2](https://github.com/GustavoHMFilho/devsecops-simples/pull/2) reproduziu o bloqueio para registrar a captura da
interface autenticada, com Trivy obrigatório reprovado e botão de merge
desabilitado. Após a captura, esse PR foi fechado sem merge.

## Evidências

- [Execução reprovada pela CVE](https://github.com/GustavoHMFilho/devsecops-simples/actions/runs/40611844168)
- [Execução aprovada após a correção](https://github.com/GustavoHMFilho/devsecops-simples/actions/runs/40612244995)
- [Execução da main com publicação aprovada](https://github.com/GustavoHMFilho/devsecops-simples/actions/runs/40612509002)
- [Projeto SonarCloud](https://sonarcloud.io/dashboard?id=GustavoHMFilho_devsecops-simples)
- [Registro das evidências e arquivos](docs/EVIDENCIAS.md)

As verificações antecipam a identificação de problemas para a etapa de PR,
aplicando shift-left security ao fluxo de integração e entrega contínuas.

## Referências

- [CVE-2024-21538 no GitHub Advisory Database](https://github.com/advisories/GHSA-3xgq-45jj-v275)
- [Gitleaks](https://github.com/gitleaks/gitleaks)
- [SonarCloud com GitHub Actions](https://docs.sonarsource.com/sonarqube-cloud/analyzing-source-code/ci-based-analysis/github-actions-for-sonarcloud/)
- [Trivy](https://trivy.dev/docs/dev/guide/scanner/vulnerability/)
- [Syft no GitHub Actions](https://github.com/anchore/sbom-action)
