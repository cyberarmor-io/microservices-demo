pipeline {
    agent {
        label "${env.NODE_LABEL}"
    }
    environment {
        DEMO_NUMBER = "${env.DEMO_NUMBER}"
    }
    stages {
        stage('git') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/ingress_version']], userRemoteConfigs: [[url:'https://github.com/cyberarmor-io/microservices-demo.git']]])
            }
        }
        
        stage('deploy in dev environment') {
            steps {
                sh '''
                kubectl create namespace dev || true
                kubectl -n dev apply -f release/kubernetes-manifests.yaml
                kubectl -n dev apply -f ingress_dev.yaml
                '''
            }
        }
        
        stage('system test') {
            steps {
                sh '''
                sleep 10
                '''
            }
        }

        stage('processing workload data') {
            steps {
                sh '''
                sleep 60
                '''
            }
        }
        
        stage('signing workloads') {
            steps {
            sh '''
            cd ca
            ./signall.sh
            cd ..
            sleep 120
            '''
            }
        }
        
        stage('promote') {
            steps {
                sh '''
                sleep 10
                '''
            }
        }
        
        stage('deploy in prod environment') {
            steps {
                sh '''
                kubectl create namespace prod || true
                kubectl delete --all pods --namespace=prod
                kubectl -n prod apply -f release/kubernetes-manifests.yaml
                kubectl -n prod delete secret nginx-ssl || true
                kubectl -n prod create secret generic nginx-ssl --from-file=tls.key=ca-nginx-tls.key.enc --from-file=tls.crt=ca-nginx-tls.crt.enc 
                kubectl -n prod apply -f ingress.yaml
                '''
            }
        }
        
        stage('liveliness test') {
            steps {
                sh '''
                sleep 30
                kubectl -n prod delete pod $(kubectl -n prod get pods | grep frontend | awk '{print $1}')
                sleep 5
                '''
            }
        }
        
    }
}
