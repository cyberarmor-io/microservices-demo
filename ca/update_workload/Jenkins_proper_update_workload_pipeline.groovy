pipeline {
    agent { label '${NODE_LABEL}' }
    stages {
        stage('git') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/ingress_version']], userRemoteConfigs: [[url:'https://github.com/cyberarmor-io/microservices-demo.git']]])
            }
        }

        stage('deploy in dev environment') {
            steps {
                sh '''
                kubectl set image deployment/redis-cart -n prod redis=redis:alpine
                kubectl -n dev apply -f release/kubernetes-manifests-edited.yaml
                '''
            }
        }

        stage('system test') {
            steps {
                sh '''
                sleep 120
                '''
            }
        }

        stage('sign workload') {
            steps {
            sh '''
            ./ca/update_workload/signone.sh
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
                kubectl -n prod apply -f release/kubernetes-manifests-edited.yaml
                '''
            }
        }

        stage('liveliness test') {
            steps {
                sh '''
                sleep 120
                kubectl -n prod delete pod $(kubectl -n prod get pods | grep frontend | awk '{print $1}')
                sleep 5
                '''
            }
        }

    }
}
