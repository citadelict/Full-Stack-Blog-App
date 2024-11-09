pipeline {
    agent any
    tools {
        jdk "jdk"
        maven "maven"
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/citadelict/Full-Stack-Blog-App.git'
            }
        }
        stage('Compile') {
            steps {
                sh "mvn compile"
            }
        }
        stage('Trivy FS') {
            steps {
                sh "trivy fs . --format table -o fs.html"
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqubeServer') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Blogging-app -Dsonar.projectKey=Blogging-app \
                          -Dsonar.java.binaries=target'''
                }
            }
        }
        stage('Build') {
            steps {
                sh "mvn package"
            }
        }
        stage('Publish Artifacts') {
            steps {
                withMaven(globalMavenSettingsConfig: 'maven-settings', jdk: 'jdk', maven: 'maven', mavenSettingsConfig: '', traceability: true) {
                    sh "mvn deploy"
                }
            }
        }
        stage('Docker Build & Tag') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'dockerhub-cred', url: 'https://index.docker.io/v1/') {
                        sh "docker build -t citatech/blog-app ."
                    }
                }
            }
        }
        stage('Trivy Image Scan') {
            steps {
                sh "trivy image --format table -o image.html citatech/blog-app:latest"
            }
        }
        stage('Docker Push Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'dockerhub-cred', url: 'https://index.docker.io/v1/') {
                        sh "docker push citatech/blog-app"
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                // Get job name, build number, and pipeline status
                def jobName = env.JOB_NAME
                def buildNumber = env.BUILD_NUMBER
                def pipelineStatus = currentBuild.result ?: 'SUCCESS'

                // Set the banner color based on the status
                def bannerColor = pipelineStatus == 'SUCCESS' ? 'green' : 'red'

                // HTML body for the email
                def body = """
                <body>
                    <div style="border: 2px solid ${bannerColor}; padding: 10px;">
                        <h3 style="color: ${bannerColor};">
                            Pipeline Status: ${pipelineStatus}
                        </h3>
                        <p>Job: ${jobName}</p>
                        <p>Build Number: ${buildNumber}</p>
                        <p>Status: ${pipelineStatus}</p>
                    </div>
                </body>
                """

                // Send email notification
                emailext(
                    subject: "${jobName} - Build ${buildNumber} - ${pipelineStatus}",
                    body: body,
                    to: 'citatech30@gmail.com',
                    from: 'jenkins@example.com',
                    replyTo: 'jenkins@example.com',
                    mimeType: 'text/html'
                )
            }
        }
    }
}
