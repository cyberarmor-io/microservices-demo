def CACLI_URL=get_cacli_url()

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
                sudo pip3 uninstall cacli
                sudo pip3 install -U cacli --index-url ''' + "${CACLI_URL}" + '''
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

        stage('Add Basic Policy') {
            steps {
                sh 'cat network-policies/ingress-policy.yaml | sed \'s/${DEMO_NUMBER}/\'${DEMO_NUMBER}\'/g\' | cacli inp create -i - || true'
                sh 'cat network-policies/basic-policy.yaml | sed \'s/${DEMO_NUMBER}/\'${DEMO_NUMBER}\'/g\' | cacli np create -i - || true'
//                 sh 'cat network-policies/cluster-policy.yaml | sed \'s/${DEMO_NUMBER}/\'${DEMO_NUMBER}\'/g\' | cacli np create -i - || true'
                sh 'kubectl -n prod delete secret nginx-ssl || true'
                sh 'kubectl -n prod create secret generic nginx-ssl --from-file=tls.key=ca-nginx-tls.key.enc --from-file=tls.crt=ca-nginx-tls.crt.enc || true'
                sh 'cacli ec create -wlid wlid://cluster-HipsterShopCluster${DEMO_NUMBER}/namespace-prod/deployment-nginx-ingress -c nginx-ingress -kid 99d368694eb64f4d9eef46a60c18af82 -p /etc/nginx/ssl || true'
            }
        }

        stage('Attaching CyberArmor to Namespaces') {
            steps {
                sh '''
                echo "wait for webhook to run"; sleep 20
                kubectl create namespace dev || true
                kubectl label namespace dev injectCyberArmor=add
                kubectl create namespace prod || true
                kubectl label namespace prod injectCyberArmor=add
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


def get_cacli_url(){
    if ("${env.CA_ENVIRONMENT}" == "dev" || "${env.CA_ENVIRONMENT}" == "development" ) {
        return "https://carepo.system.cyberarmorsoft.com/repository/cyberarmor-pypi-dev.group/simple"
    }
    return "https://carepo.system.cyberarmorsoft.com/repository/cyberarmor-pypi.release/simple"
}