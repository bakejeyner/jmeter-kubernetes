#!/usr/bin/env bash

working_dir=$(pwd)

# Get namespace variable
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

## Create jmeter database automatically in Influxdb

echo "Creating the jmeter database in Influxdb"

##Wait until Influxdb Deployment is up and running
##influxdb_status=`kubectl get po -n $tenant | grep influxdb-jmeter | awk '{print $2}' | grep Running

influxdb_pod=$(kubectl get po -n "$tenant" | grep influxdb-jmeter | awk '{print $1}')
kubectl exec -ti -n "$tenant" "$influxdb_pod" -- influx -execute 'CREATE DATABASE jmeter'

## Create the influxdb datasource in Grafana

echo "Creating the Influxdb data source in Grafana"

grafana_pod=$(kubectl get po -n "$tenant" | grep jmeter-grafana | awk '{print $1}')

## Make load test script in Jmeter master pod executable

#Get Master pod details

master_pod=$(kubectl get po -n "$tenant" | grep jmeter-master | awk '{print $1}')

kubectl exec -ti -n "$tenant" "$master_pod" -- cp -r /load_test /jmeter/load_test

kubectl exec -ti -n "$tenant" "$master_pod" -- chmod 755 /jmeter/load_test

##kubectl cp $working_dir/influxdb-jmeter-datasource.json -n $tenant $grafana_pod:/influxdb-jmeter-datasource.json

kubectl exec -ti -n "$tenant" "$grafana_pod" -- curl 'http://admin:admin@127.0.0.1:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"jmeterdb","type":"influxdb","url":"http://jmeter-influxdb:8086","access":"proxy","isDefault":true,"database":"jmeter","user":"admin","password":"admin"}'
