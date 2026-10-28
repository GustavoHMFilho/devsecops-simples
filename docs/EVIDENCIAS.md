# Evidências verificadas

Aluno: Gustavo Henrique Moraes Filho. Informe a matrícula na submissão.

- Repositório: https://github.com/GustavoHMFilho/devsecops-simples
- PR: https://github.com/GustavoHMFilho/devsecops-simples/pull/1
- Todos os checks aprovados: https://github.com/GustavoHMFilho/devsecops-simples/actions/runs/40611680339
- Demonstração isolada da CVE: https://github.com/GustavoHMFilho/devsecops-simples/actions/runs/40611844168
- SonarCloud: https://sonarcloud.io/dashboard?id=GustavoHMFilho_devsecops-simples

O commit 28a33a9 instala cross-spawn 7.0.3 somente na branch do PR. Trivy reprova dependências e imagem por CVE-2024-21538, HIGH, com correção disponível em 7.0.5/6.0.6. SonarCloud, Gitleaks e testes passam, isolando o motivo do bloqueio. O commit 031981e restaura cross-spawn 7.0.6.

## Arquivos reais em evidencias/

- pr-bloqueado.json: API retornando mergeStateStatus BLOCKED durante a falha.
- protecao-main.json: checks obrigatórios, inclusive para administradores.
- demonstracao-final/dependencies.json: relatório Trivy com a CVE.
- falha/cve-resumo.json: trecho extraído do primeiro relatório.
- 01-execucao-reprovada.png e 03-pr-checks-reprovados.png: capturas das execuções reprovadas.
- 02-execucao-aprovada.png: captura dos checks aprovados.
- sbom-aprovado/: SPDX JSON baixado do artifact da imagem aprovada.

As capturas mostram os resultados das execuções. O bloqueio de merge está registrado no JSON da API. Para atender literalmente à captura do botão de merge desabilitado, acrescente uma captura da interface autenticada do PR durante uma execução vulnerável: o navegador interno não exibe esse botão sem login e a captura do Edge falhou.

Nenhuma imagem vulnerável foi publicada. A publicação só ocorre após os gates na main. A imagem final não inclui npm e Yarn, eliminando vulnerabilidades de ferramentas usadas apenas no build.

Testes locais: 6 aprovados; cobertura de linhas, branches e funções de src/app.js: 100%. npm audit: zero vulnerabilidades na versão corrigida.

DevSecOps integra segurança ao desenvolvimento: Gitleaks examina o histórico, SonarCloud avalia código novo, Trivy verifica dependências e imagem, e Syft gera o inventário com componentes e versões. HIGH/CRITICAL com correção bloqueiam; LOW/MEDIUM ficam nos relatórios. A proteção da main impede integrar alterações que falhem nos checks. Essa antecipação é shift-left security.
