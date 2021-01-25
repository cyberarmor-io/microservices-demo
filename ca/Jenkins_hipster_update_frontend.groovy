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
        
        stage('update frontend') {
            steps {
                sh '''
                kubectl -n prod patch deployment frontend --patch "$(cat frontend_new_version.yaml)"
                sleep 10
                '''
            }
        }
    }
}
