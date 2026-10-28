# Trabalho prático: pipeline DevSecOps

API simples em Node.js com build, testes, Docker, Gitleaks, SonarCloud,
Trivy e Syft. Como não havia aplicação anterior disponível, esta é a aplicação
de referência para executar a atividade desde o início.

**Execução real aprovada:** https://github.com/GustavoHMFilho/devsecops-simples/actions/runs/40611680339

Repositório, SonarCloud e proteção da main configurados. Veja docs/EVIDENCIAS.md para relatórios, SBOM, capturas e a limitação da captura do botão de merge.

## 1. Rodar localmente

Requisitos locais: Node.js 22.17+ (24 recomendado), Git e GitHub CLI.
Docker Desktop é necessário apenas para executar a imagem localmente;
o GitHub Actions já fornece Docker.

```powershell
npm ci --ignore-scripts
npm run build
npm test
npm start
```

Rotas: `GET /`, `GET /health` e `GET /runtime`. Porta 3000.
A dependência cross-spawn é usada em `/runtime` para consultar a versão
do Node com executável e argumentos fixos, sem executar comandos do usuário.
Os testes cobrem sucesso, rota inexistente, método inválido e falha do runtime.
`npm test` produz `lcov.info` para o SonarCloud.

```powershell
docker build -t devsecops-local .
docker run --rm -p 3000:3000 devsecops-local
```

## 2. Criar o repositório

Extraia o ZIP e abra o PowerShell dentro desta pasta.
Autentique pelo navegador; nunca coloque tokens no código ou no chat.

```powershell
gh auth login --hostname github.com --git-protocol https --web --scopes workflow
git init -b main
git add .
git commit -m "feat: aplicacao e pipeline DevSecOps"
gh repo create devsecops-simples --public --source=. --remote=origin --push
```

Se o Git pedir identidade, configure `git config user.name` e
`git config user.email` com seus próprios dados e repita o commit.
O primeiro pipeline falhará no SonarCloud até a próxima etapa ser concluída;
isso demonstra configuração ausente, não a CVE exigida na atividade.

## 3. Configurar o SonarCloud (SonarQube Cloud)

1. Entre em https://sonarcloud.io com GitHub e importe o repositório público.
2. Selecione análise por GitHub Actions/CI. Desative a análise automática
   do SonarCloud para não disputar com a análise enviada pelo workflow.
3. Copie a chave da organização e a chave do projeto exibidas pelo serviço.
4. Em GitHub > Settings > Secrets and variables > Actions, crie:
   - Secret `SONAR_TOKEN`: token gerado na sua conta SonarCloud.
   - Variable `SONAR_ORGANIZATION`: chave exata da organização.
   - Variable `SONAR_PROJECT_KEY`: chave exata do projeto.
5. Em SonarCloud > Project > Quality Gate, associe o gate **Sonar way**.
   Confira os critérios de código novo: nenhuma issue nova, 100% dos
   Security Hotspots revisados, cobertura de pelo menos 80% e duplicação
   de no máximo 3%. Se a interface usar ratings, exija A em segurança,
   confiabilidade e manutenibilidade. Guarde uma captura dos critérios.
6. Em New Code, configure a referência da branch principal, por exemplo
   Previous version. Nos PRs, o código novo é a diferença para a branch alvo.
7. Confira em https://docs.sonarsource.com/sonarqube-cloud/ se o plano
   escolhido permite análise de PR para seu projeto. Se houver restrição,
   utilize um plano educacional ou habilitação compatível; não pule o gate.
8. GitHub > Actions > DevSecOps > Run workflow > main. Aguarde a análise
   inicial da main aprovar antes de criar a branch de demonstração.

O scanner usa `sonar.qualitygate.wait=true`: aguarda o resultado e retorna
falha se o gate reprovar ou se a espera exceder 300 segundos. A ausência de
token ou de identificação do projeto também falha; não existe bypass.
Se o projeto pequeno receber a regra de isenção de cobertura/duplicação para
menos de 20 linhas novas, registre essa regra na evidência do Quality Gate;
ela não dispensa as condições de segurança e revisão de hotspots.

## 4. Verificações e regras de bloqueio

| Check | O que verifica | Quando bloqueia |
|---|---|---|
| Build e testes | Sintaxe, testes e cobertura da aplicação | Build ou teste falha |
| Gitleaks | Todo o histórico Git disponível, com `fetch-depth: 0` e `--all` | Segredo detectado, exit code 1 |
| SonarCloud Quality Gate | Análise estática e gate de código novo | Gate reprovado, indisponível ou sem configuração |
| Trivy dependencias | Dependências no package-lock.json | HIGH/CRITICAL com correção disponível |
| Docker Trivy e SBOM | Build, inventário Syft e vulnerabilidades da imagem | HIGH/CRITICAL com correção; falha de build/SBOM |
| Seguranca obrigatoria | Resultado de todos os checks anteriores | Qualquer resultado diferente de success, inclusive skipped |

Gitleaks usa a CLI oficial em container, sem depender de licença de uma Action.
Os resultados têm valores de segredos ocultados com `--redact`.
Não são usadas credenciais reais nos testes. Para uma demonstração opcional,
use somente um segredo fictício em repositório temporário, pois remover o
arquivo em um commit posterior não elimina o segredo do histórico.

Cada análise Trivy gera primeiro um relatório JSON de todas as severidades,
incluindo LOW e MEDIUM e vulnerabilidades sem correção. Essa etapa usa
`--exit-code 0` exclusivamente para registrar o relatório. A etapa seguinte
aplica o bloqueio real com `--severity HIGH,CRITICAL --ignore-unfixed
--exit-code 1`. LOW/MEDIUM e achados sem correção permanecem visíveis no JSON,
mas não bloqueiam. Erros operacionais do scanner também falham o job.

O Syft analisa a **imagem construída**, não apenas a pasta do projeto, e gera
`sbom.spdx.json` em SPDX JSON com nomes, versões e relacionamentos dos
componentes. O artifact `sbom-<sha>.spdx.json` é guardado por 90 dias, conforme
o limite de retenção permitido no repositório. Baixe-o antes de expirar.
O SBOM é produzido antes do gate Trivy da imagem, inclusive para a demonstração
vulnerável, mas a imagem vulnerável nunca é publicada.

Todos os checks executam na abertura, reabertura e atualização de PRs para
main. Não há filtros de caminho que dispensem verificações. Não se usa
`pull_request_target`. PRs de forks não recebem SONAR_TOKEN e falham de forma
segura; a demonstração deve usar uma branch no próprio repositório.

Somente um **push para main**, após sucesso do gate agregado, publica no GHCR
(`ghcr.io/dono/repositorio:<sha>`). O job carrega a mesma imagem examinada,
sem reconstruir depois do scan. PRs e execuções manuais não publicam.
O usuário do container é `node`, sem privilégios de root.

## 5. Proteger main e demonstrar a CVE

Após uma execução inicial completa, substitua `DONO` pelo seu usuário:

```powershell
.\scripts\proteger-main.ps1 -Repositorio DONO/devsecops-simples
```

O script exige PR, branch atualizada e os seis checks, também para
administradores. Não exige aprovação de outra pessoa, para permitir o trabalho
individual. Verifique em Settings > Branches se a regra foi aplicada.
Se a API informar indisponibilidade do recurso no plano/repositório, guarde
a mensagem e uma captura; o enunciado condiciona essa configuração à
disponibilidade. Repositório público normalmente facilita essa configuração.

**Primeiro, introduza a falha:**

```powershell
.\scripts\demo.ps1 -Etapa vulneravel
```

O script cria `demo/cve-2024-21538`, fixa `cross-spawn@7.0.3`, atualiza o
lockfile e abre o PR. A CVE-2024-21538 é uma negação de serviço por expressão
regular, classificada HIGH pelo GitHub Advisory Database, corrigida na série
7 a partir de 7.0.5. A demonstração instala o pacote; não executa um ataque.

**Pare e capture antes de corrigir:**

1. O job `Trivy dependencias` deve falhar por CVE-2024-21538, indicando
   versão instalada 7.0.3 e versão corrigida no relatório.
2. `Docker Trivy e SBOM` também deve apontar o pacote na imagem.
3. Capture a área do PR mostrando o merge bloqueado pelos checks obrigatórios.
   Check vermelho sozinho não comprova proteção de branch.
4. Salve o link do PR, SHA do commit vulnerável, URL da execução e o JSON
   `trivy-dependencies` da aba Artifacts.

**Depois, corrija no mesmo PR:**

```powershell
.\scripts\demo.ps1 -Etapa corrigir
```

O script atualiza para 7.0.6 e envia novo commit. Aguarde todos os checks,
capture a aprovação e baixe o SBOM. Preserve a URL da execução que falhou,
pois a visão atual do PR passará a mostrar apenas os checks mais recentes.
Não faça merge antes da correção. Após aprovação, faça merge pela interface;
o push da main executará os gates novamente antes de publicar a imagem.

Novas CVEs podem surgir na imagem base ou em dependências. Se o pipeline
ainda reprovar depois da correção demonstrada, examine o relatório e atualize
os componentes afetados, sem reduzir severidades ou desativar gates.

## 6. Entrega e pontuação

Preencha [docs/EVIDENCIAS.md](docs/EVIDENCIAS.md) e anexe capturas reais.

| Critério | Pontos | Evidência necessária |
|---|---:|---|
| Gitleaks | 15 | Job executado, comando e resultado |
| SonarCloud e Quality Gate | 20 | Análise, gate de código novo e resultado |
| Trivy e bloqueio | 20 | JSON e falha por HIGH/CRITICAL corrigível |
| SBOM | 15 | Artifact real do Syft, baixado e inspecionado |
| Bloqueio e correção | 20 | Mesmo PR: execução vermelha, bloqueio e execução verde |
| Organização/documentação | 10 | Código, workflow, README e evidências |
| **Total possível** | **100** | Depende da execução e avaliação do professor |

Entregue: link do repositório, link do PR, links das duas execuções, capturas,
JSON que identifica a CVE e SBOM publicado como artifact. A existência dos
arquivos de configuração sozinha não atende ao requisito de evidências.

## Referências oficiais

- [GitHub Advisory: CVE-2024-21538](https://github.com/advisories/GHSA-3xgq-45jj-v275)
- [Trivy: vulnerabilidades e severidades](https://trivy.dev/docs/dev/guide/scanner/vulnerability/)
- [SonarCloud com GitHub Actions](https://docs.sonarsource.com/sonarqube-cloud/analyzing-source-code/ci-based-analysis/github-actions-for-sonarcloud/)
- [Syft no GitHub Actions](https://github.com/anchore/sbom-action)
- [Gitleaks CLI](https://github.com/gitleaks/gitleaks)

