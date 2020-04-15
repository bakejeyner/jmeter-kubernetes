#!/usr/bin/env bash

working_dir=$(pwd)

echo "Checking if kubectl is present"

if ! hash kubectl 2>/dev/null
then
    echo "'kubectl' was not found in PATH"
    echo "Kindly ensure that you can acces an existing kubernetes cluster via kubectl"
    exit
fi

kubectl version --short

tenant=$(awk '{print $NF}' "$working_dir"/tenant_export)

if [ -z "$tenant" ]
then
  echo "Configured namespace not found. Please run the jmeter_cluster_create.sh script first."
  echo "If you know what you are doing, enter the name of the namespace you would like to deploy to."
  read tenant
  echo

  #Check If namespace exists
  kubectl get namespace "$tenant" > /dev/null 2>&1

  if [ $? -eq 0 ]
  then
    echo "Using namespace: $tenant."
  else
    echo "Creating namespace: $tenant."
    kubectl create namespace "$tenant"
    echo
    echo "Namspace $tenant has been created."
  fi
else
  echo "Using namespace: $tenant."
fi

echo

echo "Creating Grafana Ingress"

kubectl create -n "$tenant" -f "$working_dir"/jmeter_grafana_ingress.yaml

echo "Creating Reporter Ingress"

kubectl create -n "$tenant" -f "$working_dir"/jmeter_grafana_reporter_ingress.yaml

echo "Current objects in the $tenant namespace:"

echo

kubectl get -n "$tenant" all

echo namespace = "$tenant" > "$working_dir"/tenant_export
