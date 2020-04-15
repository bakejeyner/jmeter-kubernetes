#!/usr/bin/env bash
#Create multiple Jmeter namespaces on an existing kuberntes cluster
#Started On January 23, 2018

working_dir=$(pwd)

echo "Checking if kubectl is present"

if ! hash kubectl 2>/dev/null
then
    echo "'kubectl' was not found in PATH"
    echo "Kindly ensure that you can acces an existing kubernetes cluster via kubectl"
    exit
fi

kubectl version --short

echo "Current list of namespaces on the kubernetes cluster:"

echo

kubectl get namespaces | grep -v NAME | awk '{print $1}'

echo

echo "Enter the name of the namespace you would like to deploy to."
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

echo

echo "Creating Jmeter Slave(s)"

kubectl create -n "$tenant" -f "$working_dir"/jmeter_slaves_deploy.yaml

kubectl create -n "$tenant" -f "$working_dir"/jmeter_slaves_svc.yaml

echo "Creating Jmeter Master"

kubectl create -n "$tenant" -f "$working_dir"/jmeter_master_configmap.yaml

kubectl create -n "$tenant" -f "$working_dir"/jmeter_master_deploy.yaml

echo "Creating Influxdb"

kubectl create -n "$tenant" -f "$working_dir"/jmeter_influxdb_configmap.yaml

kubectl create -n "$tenant" -f "$working_dir"/jmeter_influxdb_deploy.yaml

kubectl create -n "$tenant" -f "$working_dir"/jmeter_influxdb_svc.yaml

echo "Creating Grafana"

kubectl create -n "$tenant" -f "$working_dir"/jmeter_grafana_deploy.yaml

kubectl create -n "$tenant" -f "$working_dir"/jmeter_grafana_svc.yaml

kubectl create -n "$tenant" -f "$working_dir"/jmeter_grafana_ingress.yaml

echo "Creating Reporter"

kubectl create -n "$tenant" -f "$working_dir"/jmeter_grafana_reporter.yaml

kubectl create -n "$tenant" -f "$working_dir"/jmeter_grafana_reporter_ingress.yaml

echo "Current objects in the $tenant namespace:"

echo

kubectl get -n "$tenant" all

echo namespace = "$tenant" > "$working_dir"/tenant_export
