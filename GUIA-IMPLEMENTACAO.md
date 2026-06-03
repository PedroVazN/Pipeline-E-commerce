# Guia de implementação — RotaExpress (Case 4)

Passo a passo para implementar **todas as fases** pedidas no documento do professor (*Publicando a One-Page na AWS*).  
Repositório: https://github.com/PedroVazN/Pipeline-E-commerce

**Dupla:** Pedro Vaz ([@PedroVazN](https://github.com/PedroVazN)) + Nathan Ferreira ([@NathanSec](https://github.com/NathanSec) — aprovador de PRs).

> **Commits:** use terminal ou GitHub Desktop. Não use Agent do Cursor para commit (evita `Co-authored-by: Cursor`).

---

## Visão geral das fases

| Fase | Objetivo | Peso | Evidência (print) |
|------|----------|------|-------------------|
| **1** | EC2 + página no ar | 20% | Site com **IP na URL** + rótulo `web-srv-XX` no rodapé |
| **2** | GitHub | 20% | Tela do repositório + **link** |
| **3** | GitHub Actions (CI/CD) | 40% | Pipeline + **histórico de execução** |
| **4** | Dockerfile (IaaS) | 20% | Dockerfile + uso no pipeline |

**Entrega final:** PDF com evidências + **vídeo** (arquitetura, CI/CD, demo).

---

## Pré-requisitos

- [ ] Conta AWS (Free Tier)
- [ ] Conta GitHub (Pedro = admin do repo; Nathan = colaborador)
- [ ] Par de chaves EC2 (`.pem`)
- [ ] Docker Desktop (opcional, testes locais)
- [ ] Git instalado no Windows

---

## Configuração da dupla (faça primeiro)

### A1 — Convidar o Nathan

1. Abra https://github.com/PedroVazN/Pipeline-E-commerce  
2. **Settings** → **Collaborators** → **Add people**  
3. Usuário: `NathanSec` → permissão **Write** ou **Maintain**  
4. Nathan **aceita** o convite

### A2 — Proteger a branch `main` (Nathan como aprovador)

**Settings** → **Branches** → **Add branch protection rule**:

- [ ] Branch name pattern: `main`
- [ ] **Require a pull request before merging**
- [ ] **Require approvals:** 1
- [ ] (Recomendado) **Require status checks to pass:** `Build e teste Docker`

### A3 — Fluxo Git da dupla

```text
Pedro:  git checkout -b feature/nome
        git add / commit / push
        Abre Pull Request no GitHub
Nathan: Review → Approve
Pedro ou Nathan: Merge PR
        → Actions roda na main
```

---

## Fase 1 — EC2 + página no ar (20%)

**Objetivo:** one-page acessível em instância EC2.

### 1.1 — Criar instância EC2

Console AWS → **EC2** → **Launch instance**:

| Campo | Valor sugerido |
|-------|----------------|
| Nome | `rotaexpress-web-01` |
| AMI | Amazon Linux 2023 |
| Tipo | `t2.micro` |
| Key pair | Criar e baixar `.pem` |
| Security group | Inbound **22** (SSH), **80** (HTTP) |

Anote o **IP público**.

### 1.2 — Conectar por SSH

PowerShell (ajuste o caminho da chave):

```powershell
ssh -i "C:\caminho\rotaexpress.pem" ec2-user@SEU_IP_PUBLICO
```

### 1.3 — Instalar Docker na EC2

```bash
sudo dnf update -y
sudo dnf install -y docker git
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user
exit
```

Conecte de novo no SSH (grupo `docker` ativo).

### 1.4 — Subir a aplicação

```bash
git clone https://github.com/PedroVazN/Pipeline-E-commerce.git
cd Pipeline-E-commerce
export INSTANCE_LABEL=web-srv-01
docker build --build-arg INSTANCE_LABEL=$INSTANCE_LABEL -t rotaexpress-onepage .
docker run -d --name rotaexpress -p 80:80 -e INSTANCE_LABEL=$INSTANCE_LABEL rotaexpress-onepage
```

### 1.5 — Validar e print

- [ ] Abrir `http://SEU_IP_PUBLICO` no navegador  
- [ ] Rodapé mostra **Servido por `web-srv-01`**  
- [ ] **Print:** barra de endereço com IP + rodapé visível  

### 1.6 — Opcional (Case 4 — escala / ALB)

- [ ] Segunda EC2 `rotaexpress-web-02` com `INSTANCE_LABEL=web-srv-02`  
- [ ] **Application Load Balancer** apontando para as duas instâncias (porta 80)  
- [ ] Prints alternando o rótulo ao atualizar a página  

---

## Fase 2 — GitHub (20%)

**Objetivo:** repositório configurado com o código do projeto.

### 2.1 — Repo no ar

O código já está em: https://github.com/PedroVazN/Pipeline-E-commerce

Se ainda faltar algo local:

```powershell
cd C:\Users\25170632\Documents\case4_rotaexpress
git status
git remote -v
# deve apontar para Pipeline-E-commerce
```

### 2.2 — Corrigir commit sem Cursor (se ainda tiver Co-authored-by)

```powershell
git commit --amend -m "feat: estrutura Case 4 RotaExpress com Docker e pipeline CI/CD"
git log -1 --format=full
# NÃO pode aparecer: Co-authored-by: Cursor
```

Ou rode: `.\scripts\fix-commit-sem-cursor.ps1`

### 2.3 — Enviar alterações via PR (dupla)

```powershell
git checkout -b feature/atualizacao-docs
git add .
git commit -m "docs: readme do projeto e guia de implementação"
git push -u origin feature/atualizacao-docs
```

No GitHub: criar **Pull Request** → Nathan **aprova** → **Merge**.

### 2.4 — Evidência

- [ ] Print da página do repositório (arquivos, README, Actions)  
- [ ] Print do PR aprovado pelo **NathanSec** (opcional, reforça dupla)  
- [ ] Link no PDF: https://github.com/PedroVazN/Pipeline-E-commerce  

---

## Fase 3 — GitHub Actions / CI/CD (40%)

**Objetivo:** pipeline automático descrevendo CI/CD (integração contínua).

Arquivo do workflow: `.github/workflows/ci-cd.yml`

O pipeline valida **build + teste** da imagem Docker em todo PR e push em `main`. A EC2 já foi publicada manualmente na Fase 1 (não há job de deploy no Actions).

### 3.1 — Disparar o pipeline

1. Merge um PR em `main` (ou push em `main`)  
2. Aba **Actions** → workflow **CI/CD RotaExpress**  

Job esperado:

| Job | Quando | O que faz |
|-----|--------|-----------|
| **Build e teste Docker** | PR e push em `main` | `docker build` + teste HTTP com `curl` |

### 3.2 — Evidências

- [ ] Print do workflow (job **Build e teste Docker**)  
- [ ] Print de uma execução **verde** com logs do build e do teste  
- [ ] Print do histórico (lista de runs)  

### 3.3 — Atualizar a EC2 após mudanças no código (manual)

Quando o código mudar no GitHub e quiser atualizar o site:

```bash
cd ~/Pipeline-E-commerce   # ou pasta onde clonou
git pull origin main
export INSTANCE_LABEL=web-srv-01
docker build --build-arg INSTANCE_LABEL=$INSTANCE_LABEL -t rotaexpress-onepage .
docker rm -f rotaexpress
docker run -d --name rotaexpress -p 80:80 -e INSTANCE_LABEL=$INSTANCE_LABEL rotaexpress-onepage
```

---

## Fase 4 — Dockerfile / IaaS (20%)

**Objetivo:** Dockerfile suportando implantação + uso no pipeline.

### 4.1 — Arquivos

| Arquivo | Função |
|---------|--------|
| `Dockerfile` | Imagem `nginx:alpine` + `index.html` |
| `docker-entrypoint.sh` | Define `INSTANCE_LABEL` no HTML ao iniciar |

### 4.2 — Validar localmente (Pedro ou Nathan)

```powershell
cd C:\Users\25170632\Documents\case4_rotaexpress
docker build -t rotaexpress-onepage .
docker run -d -p 8080:80 -e INSTANCE_LABEL=web-srv-local rotaexpress-onepage
```

Abrir http://localhost:8080 — rodapé `web-srv-local`.

### 4.3 — Evidências

- [ ] Print do `Dockerfile` no GitHub  
- [ ] Print do step **Build da imagem** no Actions  
- [ ] Print do step **Teste** (curl / container) no Actions  

---

## Entrega final (PDF + vídeo)

### PDF — incluir

1. Identificação: **Case 4**, RotaExpress  
2. Integrantes: Pedro Vaz (RA ___), Nathan Ferreira (RA ___)  
3. Prints das **4 fases** (com detalhes pedidos em cada uma)  
4. Link do repositório  
5. Tabela dos **pilares AWS** (abaixo)

### Vídeo — mostrar

1. Arquitetura (EC2, Docker, GitHub, Actions)  
2. Site no ar (IP + rótulo da instância)  
3. Repositório e PR com aprovação do Nathan  
4. Pipeline executando (build + teste Docker)  
5. Dockerfile explicado brevemente  

### Pilares AWS (para relatório/vídeo)

| Pilar | Onde aparece no projeto |
|-------|-------------------------|
| Excelência operacional | CI/CD, deploy repetível, PR review |
| Segurança | Security Group, SSH com chave `.pem` |
| Confiabilidade | ALB + múltiplas EC2 (opcional), health check |
| Performance | Container Alpine + Nginx |
| Otimização de custos | t2.micro, instâncias sob demanda |

---

## Checklist geral (marque conforme for fazendo)

### Infraestrutura
- [ ] EC2 criada e acessível por SSH  
- [ ] Porta 80 aberta  
- [ ] Site no ar com `web-srv-01`  
- [ ] (Opcional) Segunda instância + ALB  

### Git / dupla
- [ ] Nathan convidado como colaborador  
- [ ] Branch protection com 1 aprovação  
- [ ] Pelo menos 1 PR aprovado pelo Nathan  

### CI/CD
- [ ] Workflow verde em PR (Build e teste Docker)  
- [ ] Workflow verde em `main`  

### Entrega
- [ ] PDF com todas as evidências  
- [ ] Vídeo gravado e enviado conforme orientação do professor  

---

## Ordem sugerida de execução (agora)

1. **Fase 1** — EC2 + Docker + site no ar → print  
2. **Fase 2** — PR com README/guia → Nathan aprova → print  
3. **Fase 3** — merge em `main` → Actions verde (build + teste) → prints  
5. **Fase 4** — prints Dockerfile + steps do Actions  
6. **PDF + vídeo**  

---

## Comandos úteis na EC2

```bash
# Ver container
docker ps

# Logs
docker logs rotaexpress

# Reiniciar após pull
cd ~/rotaexpress && git pull
docker build -t rotaexpress-onepage .
docker rm -f rotaexpress
docker run -d --name rotaexpress -p 80:80 -e INSTANCE_LABEL=web-srv-01 rotaexpress-onepage
```

---

## Problemas comuns

| Problema | Solução |
|----------|---------|
| Site não abre | Security Group porta 80; container rodando (`docker ps`) |
| Actions vermelho no build | Ver logs: erro no `docker build` ou teste `curl` |
| Cursor como contribuidor | `git commit --amend` sem co-author; desativar co-author no Cursor Settings |
| PR não pode mergear | Nathan precisa **Approve**; checks do Actions verdes |

---

*Última atualização: documento alinhado ao enunciado 11.0 Projeto Cloud One Page — Case 4 RotaExpress.*
