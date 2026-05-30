pipeline {
    agent any

    environment {
        AWS_REGION      = 'eu-north-1'
        ECR_REPO        = '718959508575.dkr.ecr.eu-north-1.amazonaws.com/my-java-app'
        IMAGE_TAG       = "${BUILD_NUMBER}"
        APP_NAME        = 'my-java-app'
    }

    stages {

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image with tag: ${IMAGE_TAG}"
                sh """
                    docker build -t ${APP_NAME}:${IMAGE_TAG} .
                    docker tag ${APP_NAME}:${IMAGE_TAG} ${ECR_REPO}:${IMAGE_TAG}
                    docker tag ${APP_NAME}:${IMAGE_TAG} ${ECR_REPO}:latest
                """
            }
        }

        stage('Push to ECR') {
            steps {
                echo 'Logging into Amazon ECR and pushing image...'
                sh """
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin ${ECR_REPO}

                    docker push ${ECR_REPO}:${IMAGE_TAG}
                    docker push ${ECR_REPO}:latest
                """
            }
        }

        stage('Deploy Container') {
            steps {
                echo 'Deploying application container...'
                sh """
                    docker stop ${APP_NAME} || true
                    docker rm   ${APP_NAME} || true

                    docker run -d \
                        --name ${APP_NAME} \
                        -p 80:8080 \
                        --restart unless-stopped \
                        ${ECR_REPO}:latest
                """
            }
        }
    }

    post {
        success {
            echo "Build #${BUILD_NUMBER} deployed successfully!"
        }
        failure {
            echo "Build #${BUILD_NUMBER} failed. Check logs above."
        }
        always {
            sh 'docker image prune -f'
        }
    }
}
