pipeline {
    agent any
    stages {
        stage('Clone Git Repo') {
            steps {
                git branch: 'main', 
                url: 'https://github.com/Harshwardhanjadhav0/Project-Docker-image-automation-using-Jenkins.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    // Build with timestamp tag
                    def imageName = "localhost:5000/my-nginx:${env.BUILD_ID}"
                    dockerImage = docker.build(imageName)
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
        
        stage('Deploy Container') {
            steps {
                script {
                    // Stop and remove any existing container
                    sh 'docker stop my-nginx-container || true'
                    sh 'docker rm my-nginx-container || true'
                    
                    // Run new container with the built image
                    sh """
                    docker run -d \
                        --name my-nginx-container \
                        -p 8080:80 \
                        localhost:5000/my-nginx:${env.BUILD_ID}
                    """
                    
                    // Verify deployment
                    sh 'curl -I http://localhost:8080'
                }
            }
        }
    }
    
    post {
        always {
            // Clean up workspace
            cleanWs()
        }
    }
}
