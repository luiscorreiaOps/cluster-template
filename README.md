# Cluster Kubernetes Template GitOps + Talos

Projeto template de cluster Kubernetes gerenciado via GitOps, utilizando Talos e ArgoCD para reconciliacao continua.

## Arquitetura e Componentes

- **OS:** Talos Linux (Imutavel e sem SSH)
- **GitOps:** ArgoCD (App-of-Apps)
- **Ingress/Gateway:** Envoy Gateway (Gateway API)
- **Network:** Cilium (CNI)
- **DNS:** External-DNS + Cloudflare
- **Seguranca:** SOPS (Criptografia de segredos)
- **Autoscaling:** Metrics Server, HPA e VPA
- **CI/CD:** GitHub Actions (Lint e Validacao via act)

## Repositorio

- `kubernetes/argocd/`: Manifestos do Root Application (App of Apps)
- `kubernetes/infrastructure/`: Componentes de infraestrutura (Cilium, Cert-Manager, Envoy, etc)
- `kubernetes/apps/`: Aplicacoes de negocio (ex: chaos-api)
- `talos/`: Configuracoes e patches do Talos Linux
- `bin/`: Binarios das ferramentas necessarias (local)
- `http://chaos.local:8080/docs` api com documentacao Swagger

## Gerenciamento (Kustomize)

O projeto utiliza o **Kustomize** para agrupar e organizar os recursos. Cada diretorio dentro de `kubernetes/` possui um arquivo `kustomization.yaml` que:
1. **Declara os recursos:** Lista todos os arquivos YAML (Deployments, Services, etc) que pertencem ao componente.
2. **ArgoCD:** O ArgoCD le o arquivo `kustomization.yaml` para saber exatamente o que instalar e em qual ordem.

Ao adicionar uma nova aplicacao:
- Crie o diretorio em `kubernetes/apps/<seu-app>/`.
- Adicione o arquivo `kustomization.yaml` listando os novos manifestos.
- Registre o novo diretorio no arquivo `kubernetes/apps/kustomization.yaml` principal.

## Bootstrap

`task bootstrap:tools`

`task bootstrap:cluster`

`task bootstrap:argocd`

`kubectl apply -f kubernetes/argocd/root-app.yaml`

## GitOps

Alteracao no cluster deve ser feita via Git:
1. Adicione ou edite manifestos em `kubernetes/apps/` ou `kubernetes/infrastructure/`.
2. Push para o repositorio: `https://github.com/luiscorreiaOps/cluster-template.git`.
3. O ArgoCD detectara as mudancas e aplicara automaticamente.

## Local

As rotas sao gerenciadas pelo Envoy Gateway. Para o chaos-api ( app ex):
1. Mapeie o host no seu `/etc/hosts`: `127.0.0.1 chaos.local`
2. Utilize port-forward para o proxy do Envoy:
`kubectl port-forward svc/<envoy-proxy-service> -n envoy-gateway-system 8080:80`
3. Acesse: `http://chaos.local:8080`

## Autoscaling

O cluster esta configurado com:
 **HPA:** Escala replicas baseado em CPU e Memoria.
 **VPA:** Ajusta automaticamente os recursos (requests/limits) dos pods.
 **Metrics Server:** Fornece os dados necessarios para o funcionamento dos autoscalers.

---
Projeto idempotente, reprodutivel e seguro. Sem intervencao manual apos o bootstrap.
