pipeline {
    agent {
        label "${env.NODE_LABEL}"
    }
    environment {
        DEMO_NUMBER = "${env.DEMO_NUMBER}"
    }
    stages {
        stage('Login to CyberArmor') {
            steps {
                sh '''
                sudo pip3 install -U cacli --index-url https://carepo.system.cyberarmorsoft.com/repository/cyberarmor-pypi-dev.group/simple
                cacli login -e ${CA_ENVIRONMENT} -u ${CA_USERNAME} -p ${CA_PASSWORD} -c ${CA_CUSTOMER}
                '''
            }
        }
        
        stage('Install CyberArmor In Cluster') {
            steps {
                sh '''
                kubectl delete namespace cyberarmor-system || true
                cacli cluster unregister -n HipsterShopCluster${DEMO_NUMBER} || true
                '''
                sh '''
                cacli wt list | python3 -c "import json,sys;d=json.load(sys.stdin);print('\n'.join(filter(lambda s: s.count('cluster-HipsterShopCluster${DEMO_NUMBER}'),d)))" | xargs -L1 cacli cleanup -wlid $@  || true
                '''
                sh '''
                cacli cluster register -n HipsterShopCluster${DEMO_NUMBER} --run -p ${CA_PASSWORD}
                '''
            }
        }

        
        stage('liveliness test') {
            steps {
                sh '''
                echo "wait for all workloads to run attached"; sleep 160
                cacli ec create -wlid "wlid://cluster-HipsterShopCluster${DEMO_NUMBER}/namespace-prod/deployment-productcatalogservice" -c "server" -p ".*\\.json" -kid "99d368694eb64f4d9eef46a60c18af82" || true
                kubectl -n prod patch  deployment  productcatalogservice -p '{"spec": {"template": {"spec": { "volumes": [{"name": "catalog", "hostPath": {"path": "'"${PWD}"'/products.json", "type": "File"}}],"containers": [{"name": "server", "volumeMounts": [{"name": "catalog", "mountPath": "/productcatalogservice/products.json", "readOnly": false}]}]}}}}' || true
                kubectl -n prod delete pod $(kubectl -n prod get pods | grep cartservice | awk '{print $1}')  || true
                kubectl -n prod delete pod $(kubectl -n dev get pods | grep recommendationservice | awk '{print $1}') || true
                kubectl -n prod delete pod $(kubectl -n prod get pods | grep recommendationservice | awk '{print $1}') || true
                sleep 10
                kubectl -n prod delete pod $(kubectl -n dev get pods | grep frontend | awk '{print $1}')  || true
                kubectl -n prod delete pod $(kubectl -n prod get pods | grep frontend | awk '{print $1}')  || true
                '''
            }
        }
    }
}
