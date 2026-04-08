# Template Cluster K8s

Projeto gerenciado via GitOps com ArgoCD e Talos Linux.

## Estrutura

- `kubernetes/`: Manifestos do cluster
- `talos/`: Configuracoes do Talos Linux
- `bootstrap/`: Scripts de inicializacao

## Como usar

1. Clone o repositorio
2. Edite `cluster.yaml` e `nodes.yaml`
3. Execute `task bootstrap:talos`
4. Execute `task bootstrap:argocd`
