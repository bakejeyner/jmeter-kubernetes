# Specific Deployment Instructions
Note that the bash scripts in this project may not work on windows machines for a multitude of reasons.
Find a friend with Mac/Linux if you get stuck.

#### Create core set of elements
```bash
./jmeter_cluster_create.sh
```

#### Create Ingress routes
```bash
./jmeter_ingress_create.sh
```

Note: be sure to add the ingress routes (`jmeter-grafana` and `jmeter-reporter`) to your host file

#### Create elements for Grafana dashboard
```bash
./dashboard.sh
```

#### Import Grafana dashboard
Navigate to `http://jmeter-grafana`, import a dashboard, and provide `GrafanaJMeterTemplate.json`.

#### Add Reporter to Grafana dashboard
In the imported Grafana dashboard, add a new link to `http://jmeter-reporter/api/v5/report/ltaas`.

#### Configure load test to report to Influxdb
The provided load test must have a specifically configured listener.
Please copy the `Backend Listener` from the provided `cloudssky.jml` test plan into your own test plan.
In the parameters section, change the `application` and `testTitle` parameters to reflect your application and test plan.

#### Run load test
```bash
./start_test.sh <path_to_load_test_jmx>
```

#### View load test results
Navigate to `http://jmeter-grafana`, and locate your imported dashboard to view results.