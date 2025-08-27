pipeline {
    agent any

    environment {
        GITHUB_CREDENTIALS    = 'github-credentials'
        DOCKERHUB_CREDENTIALS = 'docker-hub-credentials'
        AWS_CREDENTIALS       = 'jenkins-aws'
        REGION                = "ap-south-1"
        DEPLOYMENT_NAME       = "springboot-app"
        IMAGE_NAME            = "tinimercy/incident-service"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Jar') {
            steps {
                dir('incident-service') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                dir('incident-service') {
                    script {
                        def BRANCH = env.BRANCH_NAME
                        def VERSION = "${BRANCH}-${env.BUILD_NUMBER}"
                        env.DOCKER_IMAGE = "${IMAGE_NAME}:${VERSION}"

                        docker.withRegistry('', "${DOCKERHUB_CREDENTIALS}") {
                            sh "docker build -t ${DOCKER_IMAGE} ."
                            sh "docker push ${DOCKER_IMAGE}"
                        }
                    }
                }
            }
        }

        stage('Deploy') {
    steps {
        script {
            // Map branches to namespaces
            def namespaceMap = [
                "main": "main-namespace",
                "dev" : "dev-namespace",
                "qa"  : "qa-namespace",
                "prod": "prod-namespace"
            ]

            if (namespaceMap.containsKey(env.BRANCH_NAME)) {
                def targetNamespace = namespaceMap[env.BRANCH_NAME]
                echo "Deploying ${DOCKER_IMAGE} to ${env.BRANCH_NAME} environment (namespace: ${targetNamespace})"

                sh """
                    kubectl set image deployment/${DEPLOYMENT_NAME} \
                    ${DEPLOYMENT_NAME}=${DOCKER_IMAGE} \
                    -n ${targetNamespace}
                """
            } else {
                echo "Branch ${env.BRANCH_NAME} not configured for deployment"
            }
        }
    }
}
