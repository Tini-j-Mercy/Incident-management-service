node {
    // Environment variables
    def IMAGE_NAME = "tinimercy/springboot-app"
    def DOCKERHUB_CREDENTIALS = 'docker-hub-credentials'
    def AWS_CREDENTIALS = 'jenkins-aws'
    def REGION = 'ap-south-1'
    def CLUSTER_NAME = 'my-demo-eks'
    def DEPLOYMENT_NAME = 'springboot-app'

    try {
        stage('Checkout') {
            checkout scm
        }

        stage('Build Jar') {
            dir('incident-service') {
                sh 'mvn -B -DskipTests clean package'
            }
        }

        stage('Build & Push Docker Image') {
            dir('incident-service') {
                def VERSION = "${env.BRANCH_NAME}-v${env.BUILD_NUMBER}"
                env.DOCKER_IMAGE = "${IMAGE_NAME}:${VERSION}"
                docker.withRegistry('', DOCKERHUB_CREDENTIALS) {
                    sh "docker build -t ${env.DOCKER_IMAGE} ."
                    sh "docker push ${env.DOCKER_IMAGE}"
                }
            }
        }

        stage('Deploy to EKS') {
            script {
                if (['dev','uat','main','prod'].contains(env.BRANCH_NAME)) {
                    def namespace = (env.BRANCH_NAME == 'main') ? 'staging' : env.BRANCH_NAME
                    def replicas  = (env.BRANCH_NAME == 'prod') ? 3 : 2
                    def envLabel  = (env.BRANCH_NAME == 'main') ? 'staging' : env.BRANCH_NAME

                    withAWS(credentials: AWS_CREDENTIALS, region: REGION) {
                        sh """
                        aws eks --region ${REGION} update-kubeconfig --name ${CLUSTER_NAME}
                        mkdir -p k8s/out
                        sed -e "s|{{IMAGE}}|${env.DOCKER_IMAGE}|g" \
                            -e "s|{{NAMESPACE}}|${namespace}|g" \
                            -e "s|{{REPLICAS}}|${replicas}|g" \
                            -e "s|{{ENV}}|${envLabel}|g" \
                            k8s/deployment.yaml > k8s/out/deployment-${namespace}.yaml

                        echo '--- Rendered Manifest ---'
                        cat k8s/out/deployment-${namespace}.yaml

                        kubectl apply -f k8s/out/deployment-${namespace}.yaml
                        kubectl -n ${namespace} rollout status deployment/${DEPLOYMENT_NAME} --timeout=180s
                        kubectl -n ${namespace} get deploy,po,svc -o wide
                        """
                    }
                } else {
                    echo "Skipping deployment for branch ${env.BRANCH_NAME}"
                }
            }
        }

        echo "✅ Build and deployment finished for branch ${env.BRANCH_NAME}"

    } catch (err) {
        echo "❌ Pipeline failed: ${err}"
        currentBuild.result = 'FAILURE'
        throw err
    } finally {
        archiveArtifacts artifacts: 'k8s/out/*.yaml', fingerprint: true, onlyIfSuccessful: false
    }
}
