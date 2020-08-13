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
                sleep 20
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
                kubectl -n prod apply -f release/kubernetes-manifests.yaml
                kubectl -n prod delete secret nginx-ssl || true
                kubectl -n prod create secret tls nginx-ssl --key ca-nginx-tls.key --cert ca-nginx-tls.crt  || true
                kubectl -n prod apply -f ingress.yaml
                '''
            }
        }
        
        stage('liveliness test') {
            steps {
                sh '''
                sleep 10
                '''
            }
        }
        
    }
}
