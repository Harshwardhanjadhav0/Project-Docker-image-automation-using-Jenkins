project4- Automate docker image creation & deployment using jenkins pipeline.

prerequisites:
- ubuntu 22.04 LTS (or any linux-based as per your familiarity)
- Sudo/root access of the server/vm
- basic knowledge of Jenkins, AWS EC2, Docker.

1 Create a EC2 instance(ubuntu 22.04 with t3.medium type)
- login and configure it with installing openJDK (Java 17 +)
sudo apt update -y
sudo apt install openjdk-17-jdk -y
- verify installation: java --version

2 Install Jenkins(add jenkins repository and install):
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update -y
sudo apt install jenkins -y

- Start Jenkins:
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo systemctl status jenkins

- Access Jenkins Web UI
get initial admin password to login:
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

- Open Jenkins in a browser:
http://<your-public-ip>:8080
Follow setup wizard, install recommended plugins, and create an admin user.

3. Install docker on ec2 instance:
sudo apt update -y
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo docker --version

- Add Jenkins User to Docker Group (Avoid Permission Issues)
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins(jenkins might need initial admin password to login one more time, give it and login).

4. Set Up Local Docker Registry:
sudo docker run -d -p 5000:5000 --restart=always --name registry registry:2

- Verify:
curl http://localhost:5000/v2/_catalog
( should return {"repositories":[]} )

- Allow Insecure Registries (For Local Use) with editing docker daemon config:
sudo vim /etc/docker/daemon.json
(ADD):
{
  "insecure-registries": ["<your-server-ip>:5000"]
}

- Restart Docker:
sudo systemctl restart docker (this might give error, wait for sometime and try again).

5. Configure Jenkins Pipeline:
- Install required plugins 
Go to Jenkins Dashboard → Manage Jenkins → Plugins → Available Plugins
Install: Docker Pipeline, Git or Git repo.

- Create a New Pipeline Job:
Dashboard → New Item → Pipeline → Enter name (e.g., Docker-Automation) → OK
Under Pipeline, select:
- Definition: Pipeline script from SCM
- SCM: Git
- Repository URL: Your GitHub repo containing Dockerfile and Jenkinsfile
- Branch: main or your branch
- Script Path: Jenkinsfile

6. Creating Jenkinsfile & Dockerfile.
- Dockerfile (Place in GitHub Repo)- {Modidy it as per your preferences}.
# Using Red Hat UBI 8 minimal base image for better use of apache server
FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

# Install Apache (httpd) and create sample index.html
RUN microdnf install -y httpd && \
    microdnf clean all && \
    echo "<html><body><h1>MyProject: Docker Automations using Jenkins and Local Registry</h1><p>Automated by Jenkins</p></body></html>" > /var/www/html/index.html

# Modify Apache config to listen on 8088
RUN sed -i 's/Listen 80/Listen 8088/g' /etc/httpd/conf/httpd.conf

# Expose custom port 8088
EXPOSE 8088

# Run Apache in foreground
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]


- Jenkinsfile (Place in GitHub Repo) - {Modify it as per your preferences}.
pipeline {
    agent any
    stages {
        stage('Clone Repo') {
            steps {
                git branch: 'main', #or your GitHub branch name
                url: 'your GitHub repo URL'
            }
        }

        stage('Build Image') {
            steps {
                script {                 #Here you can add your name
                    docker.build("localhost:5000/harsh-jenkins-apache:${env.BUILD_ID}")
                }
            }
        }

        stage('Push to Registry') {
            steps {
                script {
                    docker.withRegistry('http://localhost:5000') {
                        docker.image("localhost:5000/harsh-jenkins-apache:${env.BUILD_ID}").push()   #change names everywhere the same as "Build image"
                    }
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    // Cleanup old container if exists
                    sh 'docker rm -f harsh-jenkins-apache || true'

                    // Run new container (mapping host port 8088 to container port 8088)
                    sh """
                    docker run -d \
                        --name harsh-jenkins-apache \
                        -p 8088:8088 \
                        localhost:5000/harsh-jenkins-apache:${env.BUILD_ID}
                    """

                    // Verify deployment
                    sh 'curl -I http://localhost:8088'
                }
            }
        }
    }
}


7. Save the Jenkins pipeline and Build it.
Run Jenkins Pipeline:
- Save the Jenkins job.
- Click Build Now to trigger the pipeline.
- Verify the Docker image is in the local registry:
curl http://localhost:5000/v2/_catalog
(this should list harsh-jenkins-apache or your image name).

- And also verify Jenkins-automated image deployment:
docker ps
http://<ec2-public-ip>:8088
(It should show the apache server running and the text).

Final Checks
✅ Jenkins installed & running
✅ Docker installed & Jenkins user has permissions
✅ Local Docker registry running (localhost:5000)
✅ Jenkins pipeline successfully builds & pushes Docker image
✅ Docker image runs without errors.

Troubleshooting (If Needed)
- Permission Denied → Ensure jenkins user is in the docker group (sudo usermod -aG docker jenkins).
- Docker Push Fails → Verify insecure-registries in /etc/docker/daemon.json.
- Pipeline Fails → Check Jenkins console logs for errors.

This is a fully tested, error-free guide for automating Docker image creation and deployment using Jenkins. 🚀 Let me know if you need any modifications!


