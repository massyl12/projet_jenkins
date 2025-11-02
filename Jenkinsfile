@Library('massyl-shared-library')_

pipeline {
    environment {
        IMAGE_NAME = "webapp"
        IMAGE_TAG = "v1"
        DOCKER_PASSWORD = credentials('docker-password')
        DOCKER_USERNAME = 'massyl12'
        HOST_PORT = 80
        CONTAINER_PORT = 80
        IP_DOCKER = '172.17.0.1'
        INVENTORY_FILE = "inventory"
    }

    agent any

    stages {
        stage('Build') {
            steps {
                sh "docker build --no-cache -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Test') {
            steps {
                sh '''
                docker run --rm -dp $HOST_PORT:$CONTAINER_PORT --name $IMAGE_NAME $IMAGE_NAME:$IMAGE_TAG
                sleep 5
                curl -I http://$IP_DOCKER
                docker stop $IMAGE_NAME
                '''
            }
        }

        stage('Release') {
            steps {
                sh '''
                docker tag $IMAGE_NAME:$IMAGE_TAG $DOCKER_USERNAME/$IMAGE_NAME:$IMAGE_TAG
                echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                docker push $DOCKER_USERNAME/$IMAGE_NAME:$IMAGE_TAG
                '''
            }
        }

        // ===================================
        // DEPLOY REVIEW
        // ===================================
        stage('Deploy Review') {
            steps {
                script {
                    timeout(time: 30, unit: 'MINUTES') {
                    input message: 'Déployer Review ?', ok: 'Yes'
                    }
                    sshagent(['key-pair']) {
                    // 1️⃣ Installer Docker via Ansible
                    sh """
                    ansible-playbook -i ${INVENTORY_FILE} install_docker.yml --limit review
                    """

                    // 2️⃣ Déployer le conteneur
                    sh """
                    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                    ansible -i ${INVENTORY_FILE} review -b -m shell -a '
                        docker rm -f ${IMAGE_NAME} || true && \
                        docker pull ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} && \
                        docker run -d -p ${HOST_PORT}:${CONTAINER_PORT} --name ${IMAGE_NAME} ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                    '
                """
            }
        }
    }
}


        // ===================================
        // DEPLOY STAGING
        // ===================================
        stage('Deploy Staging') {
            steps {
                script {
                    timeout(time: 30, unit: 'MINUTES') {
                        input message: 'Déployer Staging ?', ok: 'Yes'
                    }
                    sshagent(['key-pair']) {
                        sh """
                        ansible-playbook -i ${INVENTORY_FILE} install_docker.yml --limit staging
                        """

                        sh '''
                        echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                        ansible -i $INVENTORY_FILE staging -b -m shell -a "
                            docker rm -f $IMAGE_NAME || true &&
                            docker pull $DOCKER_USERNAME/$IMAGE_NAME:$IMAGE_TAG &&
                            docker run -d -p $HOST_PORT:$CONTAINER_PORT --name $IMAGE_NAME $DOCKER_USERNAME/$IMAGE_NAME:$IMAGE_TAG
                        "
                        '''
                    }
                }
            }
        }

        // ===================================
        // DEPLOY PROD
        // ===================================
        stage('Deploy Prod') {
            steps {
                script {
                    timeout(time: 30, unit: 'MINUTES') {
                        input message: 'Déployer Prod ?', ok: 'Yes'
                    }
                    sshagent(['key-pair']) {
                        sh """
                        ansible-playbook -i ${INVENTORY_FILE} install_docker.yml --limit prod
                        """

                        sh '''
                        echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                        ansible -i $INVENTORY_FILE prod -b -m shell -a "
                            docker rm -f $IMAGE_NAME || true &&
                            docker pull $DOCKER_USERNAME/$IMAGE_NAME:$IMAGE_TAG &&
                            docker run -d -p $HOST_PORT:$CONTAINER_PORT --name $IMAGE_NAME $DOCKER_USERNAME/$IMAGE_NAME:$IMAGE_TAG
                        "
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                slackNotifier currentBuild.result
            }
        }
    }
}
