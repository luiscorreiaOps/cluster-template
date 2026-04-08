# ARCHITECTURE

- Kubernetes: Talos Linux
- GitOps: ArgoCD
- Network: Cilium
- Ingress/Gateway: Envoy Gateway
- DNS: External-DNS + Cloudflare
- Secrets: SOPS (age ou gpg)
- CI/CD: GitHub Actions
- Dependency update: Renovate
- Tunnel: Cloudflared

O cluster deve ser 100% gerenciado via Git (single source of truth)

---

# REPOSITORY STRUCTURE

Criar estrutura:
.
├── kubernetes/
│ ├── apps/
│ ├── infrastructure/
│ ├── argocd/
│ └── components/
├── talos/
├── bootstrap/
├── scripts/
├── .github/workflows/
├── cluster.yaml
├── nodes.yaml
├── talconfig.yaml
├── talenv.yaml
└── README.md
---

## cluster.yaml
- clusterName
- domain
- network config
- gateway ip
- cloudflare domain

## nodes.yaml
- lista de nodes
- IP
- role (controlplane/worker)

---

# STAGE 2 - TALOS CONFIG GENERATION

Criar automação:

- Gerar config Talos via template
- Criar comandos:
  - `task talos:generate-config`
  - `task talos:apply-node`

Talos deve ser imutável e sem SSH.

---

# STAGE 3 - GITOPS BASE (ARGOCD)

Instalar ArgoCD via manifest oficial:

- Namespace: argocd

Componentes esperados:
- argocd-server
- argocd-repo-server
- argocd-application-controller
- argocd-dex (opcional)

Configurar:

- acesso ao repo Git
- sync automático habilitado:
  - selfHeal: true
  - prune: true

---

# STAGE 4 - GITOPS MODEL 



| ArgoCD    build ex  

| Application              
| Application (Helm source)
| repoURL                  
|  Auto Sync                

---

# STAGE 5 - CORE INFRASTRUCTURE

Instalar via ArgoCD Applications:

## Estrutura:


kubernetes/infrastructure/<component>/
├── kustomization.yaml
└── helmrelease.yaml (se helm)


## Criar Applications:

- cilium
- external-dns
- cert-manager
- envoy-gateway
- reloader

Cada infra deve ter um `Application` ArgoCD.

---

# STAGE 6 - APP OF APPS (CRÍTICO)

Criar padrão App-of-Apps:

kubernetes/argocd/root-app.yaml

Esse Application:

- aponta para `kubernetes/apps` e `kubernetes/infrastructure`
- cria automaticamente todos os outros Applications

---

# STAGE 7 - CLOUDFARE INTEGRATION

- Criar tunnel com cloudflared
- Configurar:
  - ingress externo via tunnel
  - DNS automático via external-dns

---

# STAGE 8 - SECRETS MANAGEMENT

- Implementar SOPS
- Integrar com ArgoCD usando:

Opções:
- KSOPS plugin
- ou argocd-vault-plugin

Regra:
- nenhum secret em plaintext

---

# STAGE 9 - BOOTSTRAP FLOW

Criar automação:
1. Instalar Talos
2. Bootstrap Kubernetes
3. Instalar CNI
4. Instalar ArgoCD
5. Aplicar root-app
6. ArgoCD sincroniza tudo

Comandos:
task bootstrap:talos
task bootstrap:argocd


---

# STAGE 10 - GITHUB ACTIONS

Criar pipeline:
- lint YAML
- validate kustomize
- validate helm
- validar Applications ArgoCD
- validar SOPS encryption
- opcional: diff manifests

---

# STAGE 11 - RENOVATE

Configurar:
- update helm charts
- update imagens docker
- update github actions

---

# STAGE 12 - APPLICATION MODEL

Estrutura:
kubernetes/apps/<app-name>/
├── application.yaml
├── kustomization.yaml

Cada app é um `Application` ArgoCD.

---

# STAGE 13 - DNS STRATEGY

- Public:
  - Cloudflare + external-dns

- Internal:
  - split DNS
  - gateway interno

---

# STAGE 14 - VALIDATIONS

Comandos:

argocd app list
argocd app get <app>
kubectl get pods -A
cilium status
---

# STAGE 15 - RESET / REBUILD

Criar comando:
task talos:reset
Cluster deve ser recriável do zero via Git.

---

# RULES

- Tudo via Git (NUNCA kubectl manual fora bootstrap)
- ArgoCD é o único reconciler
- Idempotente
- Reprodutível
- Sem hardcode
- Secrets criptografados

---

# EXPECTED RESULT

- Cluster Kubernetes funcional
- ArgoCD sincronizando automaticamente
- Apps deployados via Git
- DNS funcionando
- TLS automático
- Infra totalmente reprodutível

---

# OPTIONAL IMPROVEMENTS

- ArgoCD Image Updater
- External Secrets Operator
- Multi-cluster ArgoCD
- Terraform para infra
- Observabilidade (Prometheus + Grafana)


# FINAL INSTRUCTION

A IA deve:

1. Criar todos os manifests ArgoCD
2. Criar root Application (App of Apps)
3. Substituir completamente Flux por ArgoCD
4. Garantir bootstrap com:

- git clone
- config edit
- bootstrap

Sem intervenção manual adicional.
