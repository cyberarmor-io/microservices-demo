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
                sudo pip3 uninstall -y cacli || true
                pip3 uninstall -y cacli || true
                sudo pip3 install --upgrade --force-reinstall cacli --index-url ''' + "${CACLI_URL}" + '''
                cacli --version
                cacli login -e ${CA_ENVIRONMENT} -u ${CA_USERNAME} -p ${CA_PASSWORD} -c "${CA_CUSTOMER}"
                '''
            }
        }
        
        stage('Install CyberArmor In Cluster') {
            steps {
                sh '''
                kubectl delete namespace cyberarmor-system || true
                cacli cluster unregister -n ${CLUSTER} || true
                '''
                sh '''
                cacli wt list | python3 -c "import json,sys;d=json.load(sys.stdin);print('\n'.join(filter(lambda s: s.count('cluster-${CLUSTER}'),d)))" | xargs -L1 cacli cleanup -wlid $@  || true
                '''
                sh '''
                export CA_ENABLE_SCANNING=true
                cacli cluster register -n ${CLUSTER} --run -p ${CA_PASSWORD}
                '''
                sh'''
                #!/bin/bash
                while true; do
                    i=$(($i + 1))
                    status=$(kubectl get pod -n cyberarmor-system | grep webhook |  awk '{print $3}' )
                    if [ ! -z ${status} ] && [ ${status} = "Running" ]; then
                        break
                    fi
                    if [ $i -eq 18 ]; then
                        echo "webhook is not running after 3 minutes"
                        exit 1
                    fi
                sleep 10
                done
                '''
            }
        }

        stage('Add Basic Policy') {
            steps {
                sh 'cat network-policies/ingress-policy.yaml | sed \'s/${DEMO_NUMBER}/\'${DEMO_NUMBER}\'/g\' | cacli inp create -i - || true'
                sh 'cat network-policies/basic-policy.yaml | sed \'s/${DEMO_NUMBER}/\'${DEMO_NUMBER}\'/g\' | cacli np create -i - || true'
//                 sh 'cat network-policies/cluster-policy.yaml | sed \'s/${DEMO_NUMBER}/\'${DEMO_NUMBER}\'/g\' | cacli np create -i - || true'

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
                cacli ec create -wlid "wlid://cluster-${CLUSTER}/namespace-prod/deployment-productcatalogservice" -c "server" -p ".*\\.json" -kid "99d368694eb64f4d9eef46a60c18af82" || true
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

