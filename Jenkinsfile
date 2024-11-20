pipeline {
    agent any

    tools {
        go 'go1.20'
    }

    environment {
        DOCKERHUB_CREDENTIALS = 'docker-registry-credentials'
        DOCKER_IMAGE = 'quocanuit/guessbook'
        GITHUB_CREDENTIALS = 'github-credentials'
        PRIVATE_INSTANCE = '192.168.2.81'
        SSH_CREDENTIALS = 'private-instance-ssh'
        MANIFESTS_DIR = '/home/ubuntu/k8s-manifests'
    }

    stages{
        stage('Source'){
            steps{
                echo "Checking out repo"
                git url: 'https://github.com/quocanuit/guestbook-go.git', branch: 'master',
                credentialsId: "${GITHUB_CREDENTIALS}"
            }
        }
        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'sonar-scanner';
                    withSonarQubeEnv('sonar-server') {
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }
        stage('Build'){
            steps{
                script{
                    echo "Starting docker build"
                    sh "docker build -t ${DOCKER_IMAGE}:v3.${env.BUILD_ID} ."
                    echo "Docker built successfully"
                }
            }
        }
        stage('Push Image'){
            steps{
                echo "Pushing to docker hub"
                script{
                    docker.withRegistry('https://registry.hub.docker.com', DOCKERHUB_CREDENTIALS) {
                        docker.image("${DOCKER_IMAGE}:v3.${env.BUILD_ID}").push()
                    }
                }
                echo "Done"
            }
        }
        stage('Deploy'){
            steps{
                script {
                    sh "sed -i 's|image: .*|image: ${DOCKER_IMAGE}:v3.${env.BUILD_ID}|' guestbook-controller.yaml"
                    
                    withCredentials([sshUserPrivateKey(credentialsId: SSH_CREDENTIALS, keyFileVariable: 'SSH_KEY')]) {
                        sh """
                            # Ensure manifest directory exists on private instance
                            ssh -o StrictHostKeyChecking=no -i "\${SSH_KEY}" ubuntu@${PRIVATE_INSTANCE} "mkdir -p ${MANIFESTS_DIR}"
                            
                            # Copy all required manifests
                            scp -o StrictHostKeyChecking=no -i "\${SSH_KEY}" \
                                redis-master-controller.yaml \
                                redis-master-service.yaml \
                                redis-replica-controller.yaml \
                                redis-replica-service.yaml \
                                guestbook-controller.yaml \
                                guestbook-service.yaml \
                                ubuntu@${PRIVATE_INSTANCE}:${MANIFESTS_DIR}/
                            
                            # Deploy to Kubernetes
                            ssh -o StrictHostKeyChecking=no -i "\${SSH_KEY}" ubuntu@${PRIVATE_INSTANCE} '
                                cd ${MANIFESTS_DIR}
                                kubectl apply -f redis-master-controller.yaml
                                kubectl apply -f redis-master-service.yaml
                                kubectl apply -f redis-replica-controller.yaml
                                kubectl apply -f redis-replica-service.yaml
                                kubectl apply -f guestbook-controller.yaml
                                kubectl apply -f guestbook-service.yaml
                                kubectl rollout status deployment/guestbook --timeout=300s
                            '
                        """
                    }
                    echo "Deployment completed successfully"
                }
            }
        }
    }

    post {
        always{
            cleanWs()
        }
    }
}