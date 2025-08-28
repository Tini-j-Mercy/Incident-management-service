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

                # ✅ Proper sed with -e for multiple replacements and variable expansion
                sed -e "s|{{IMAGE}}|${DOCKER_IMAGE}|g" \
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
        }
    }
}
