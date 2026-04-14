# Cluster Kubernetes Template GitOps + Talos

Projeto template de cluster Kubernetes gerenciado via GitOps, utilizando Talos e ArgoCD para reconciliacao continua.

## Arquitetura e Componentes

- **OS:** Talos Linux (Imutavel e sem SSH)
- **GitOps:** ArgoCD (App-of-Apps)
- **Ingress/Gateway:** Envoy Gateway (Gateway API)
- **Network:** Cilium (CNI) + CiliumNetworkPolicy (Zero Trust)
- **Backup:** Velero (Backup & Restore)
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

## Kustomize

Agrupa e os recursos. `kubernetes/`  `kustomization.yaml`:
1. **Declara os recursos:** Lista  YAML  que pertencem ao componente.
2. **ArgoCD:** Le `kustomization.yaml`.

Apss:
`kubernetes/apps/<*app>/`. app
`kustomization.yaml`  manifestos.
`kubernetes/apps/kustomization.yaml` regristro.

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

## Testes

 `simulacao/`:
 `CiliumNetworkPolicy` bloqueia acessos.
 `./simulacao/test-network-policy.sh` test
 `./simulacao/stress-test.sh` test
 `./bin/velero backup create validation-test --include-namespaces chaos-api` bkp
 `./bin/velero backup get` bkp
 `cilium`: On/Off  para restaurar o DNS interno usando CNI padrao do Talos ou `kubernetes/infrastructure/cilium`.
 `minio` e `velero` `privileged` para disco local.
 `taints`: On/off

---
Projeto idempotente, reprodutivel e seguro. Sem intervencao manual apos o bootstrap.
