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
                sleep 10
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
                kubectl -n dev apply -f release/kubernetes-manifests.yaml
                kubectl delete --all pods --namespace=prod
                '''
            }
        }
        
        stage('liveliness test') {
            steps {
                sh '''
                sleep 120
                kubectl -n prod delete pod $(kubectl -n dev get pods | grep recommendationservice | awk '{print $1}') || true
                kubectl -n prod delete pod $(kubectl -n prod get pods | grep recommendationservice | awk '{print $1}')  || true
                '''
            }
        }
    }
}
