#!/bin/bash
echo "Teste Politica de Rede - Zero Trust"
echo "Tentando acessar a api a partir de um pod nao autorizado..."
kubectl run stranger-pod -n default --image=curlimages/curl --restart=Never --rm -i --tty -- /usr/bin/curl --connect-timeout 5 chaos-api.chaos-api.svc.cluster.local:80
