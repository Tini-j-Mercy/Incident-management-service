pipeline {
    agent any

    environment {
        IMAGE_NAME         = "your-dockerhub-username/springboot-app"   // change this
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds'                      // Jenkins credentials ID
        AWS_CREDENTIALS       = 'aws-creds'                            // Jenkins credentials ID
        REGION                = 'ap-south-1'                           // change as per cluster
        CLUSTER_NAME          = 'your-eks-cluster'                     // change as per cluster
        DEPLOYMENT_NAME       = 'springboot-app'                       // from k8s yaml
    }

    stages {
        stage('Checkout') {
            steps {
                // In a Multibranch job, Jenkins checks out the correct branch automatically
                checkout scm
            }
        }

        stage('Build Jar') {
            steps {
                script {
                    // Change to '.' if your pom.xml is at repo root
                    dir('incident-service') {
                        sh 'mvn -B -DskipTests clean package'
                    }
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    def VERSION = "${env.BRANCH_NAME}-v${env.BUILD_NUMBER}"
                    env.DOCKER_IMAGE = "${IMAGE_NAME}:${VERSION}"

                    dir('incident-service') {
                        docker.withRegistry('', DOCKERHUB_CREDENTIALS) {
                            sh "docker build -t ${DOCKER_IMAGE} ."
                            sh "docker push ${DOCKER_IMAGE}"
                        }
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            when {
                expression { return ['dev','uat','main','prod'].contains(env.BRANCH_NAME) }
            }
            steps {
                withAWS(credentials: AWS_CREDENTIALS, region: REGION) {
                    script {
                        // Namespace & replica policy per branch
                        def namespace = (env.BRANCH_NAME == 'main') ? 'staging' : env.BRANCH_NAME
                        def replicas  = (env.BRANCH_NAME == 'prod') ? 3 : 2
                        def envLabel  = (env.BRANCH_NAME == 'main') ? 'staging' : env.BRANCH_NAME

                        sh """
                        aws eks --region ${REGION} update-kubeconfig --name ${CLUSTER_NAME}
                        mkdir -p k8s/out
                        sed 's|{{IMAGE}}|${DOCKER_IMAGE}|g; s|{{NAMESPACE}}|${namespace}|g; s|{{REPLICAS}}|${replicas}|g; s|{{ENV}}|${envLabel}|g' \
                        k8s/deployment.yaml > k8s/out/deployment-${namespace}.yaml

                        kubectl apply -f k8s/out/deployment-${namespace}.yaml
                        kubectl -n ${namespace} rollout status deployment/${DEPLOYMENT_NAME} --timeout=180s
                        kubectl -n ${namespace} get deploy,po,svc -o wide
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Build succeeded for ${env.BRANCH_NAME}. Pushed image: ${env.DOCKER_IMAGE}"
        }
        failure {
            echo "❌ Build failed for ${env.BRANCH_NAME}"
        }
        always {
            archiveArtifacts artifacts: 'k8s/out/*.yaml', fingerprint: true, onlyIfSuccessful: false
        }
    }
}
