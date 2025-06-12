pipeline {
    agent any
    stages {
        stage('Clone Git Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/your-repo.git'
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
