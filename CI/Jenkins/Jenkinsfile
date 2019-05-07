pipeline {
    agent any
    environment {
        IMAGE_NAME = 'matt/node'
        TARGET_CONTAINER = "${IMAGE_NAME}"
        BUILD_TAG = "latest"
    }

    stages {
        stage('Build') {
            steps {
                echo "docker build -t $IMAGE_NAME:$BUILD_TAG ."
            }
        }
        stage('twistlock scan') {
            steps {
                sh 'echo try this'
                sh 'docker images | grep matt | grep node'
                sh "docker build -t $IMAGE_NAME:$BUILD_TAG ."
                sh 'docker images | grep matt | grep node'
                script {
                    try {
                        currentBuild.result = 'SUCCESS'
                        echo 'Running tests...'
                        twistlockScan ca: '',
                            cert: '',
                            policy: 'high',
                            compliancePolicy: 'high',
                            containerized: false,
                            dockerAddress: 'unix:///var/run/docker.sock',
                            gracePeriodDays: 0,
                            ignoreImageBuildTime: true,
                            key: '',
                            logLevel: 'true',
                            requirePackageUpdate: false,
                            timeout: 10,
                            repository: "${TARGET_CONTAINER}",
                            tag: "${BUILD_TAG}",
                            image: "${TARGET_CONTAINER}:${BUILD_TAG}"
                    }
                    catch (err) {
                        echo "Exception thrown:\n ${err}"
                        echo 'Scan failed with error ' + err.toString()
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }
        stage('twistlock publish') {
            steps {
                twistlockPublish ca: '',
                        cert: '',
                        dockerAddress: 'unix:///var/run/docker.sock',
                        ignoreImageBuildTime: true,
                        key: '',
                        logLevel: 'true',                        
                        timeout: 10,
                        repository: "${TARGET_CONTAINER}",
                        tag: "${BUILD_TAG}",
                        image: "${TARGET_CONTAINER}:${BUILD_TAG}"
            }
        }
            
        
        stage('Deploy') {
            steps {
                script {
                    if (currentBuild.result == 'SUCCESS')
                        echo 'Deploying....'
                    else
                        echo 'Deployment skipped, problem occurred, possibly Twistlock scan found CVEs or compliance issues!'
                }
            }
        }
    }
}
