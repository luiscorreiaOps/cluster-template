#!/bin/bash
echo "Teste de Estresse  HPA ---"
echo "Gerando carga na api..."
kubectl run load-generator -n chaos-api --image=busybox --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://chaos-api:80; done"
