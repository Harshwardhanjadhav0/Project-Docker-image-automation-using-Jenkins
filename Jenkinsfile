pipeline {
    agent any
    stages {
        stage('Clone Git Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/Harshwardhanjadhav0/Project-Docker-image-automation-using-Jenkins.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("localhost:5000/my-nginx:${env.BUILD_ID}")
                }
            }
        }
        stage('Push to Local Registry') {
            steps {
                script {
                    docker.withRegistry('http://localhost:5000') {
                        dockerImage.push()
                    }
                }
            }
        }
    }
}
