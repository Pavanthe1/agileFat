pipeline {
    agent any
    
    parameters {
        booleanParam(name: 'RUN_TESTS', defaultValue: true, description: 'Execute automated lint and validation stages')
        string(name: 'ENVIRONMENT', defaultValue: 'production', description: 'Target Kubernetes Environment')
    }

    environment {
        DOCKER_IMAGE = "pavansaladi/agilefat:latest"
    }

    stages {
        stage('Clone Code') {
            steps {
                echo "Pulling latest code branches from GitHub..."
                git branch: 'main', url: 'https://github.com'
            }
        }

        // Feature: Conditional Stage Execution based on 'RUN_TESTS' parameter
        stage('Validation Framework') {
            when {
                expression { return params.RUN_TESTS }
            }
            // Feature: Parallel Stage Execution for fast processing
            parallel {
                stage('HTML Code Check') {
                    steps {
                        echo "Validating index.html structure..."
                        // Fixed: Added case-insensitive query to prevent Windows exit status 1 crashes
                        bat 'findstr /i "html" index.html'
                    }
                }
                stage('Docker Specifications Check') {
                    steps {
                        echo "Analyzing Dockerfile structural parameters..."
                        bat 'findstr "FROM" Dockerfile'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building application image using local engine..."
                bat "docker build -t %DOCKER_IMAGE% ."
            }
        }

        stage('Push Image to Hub') {
            steps {
                echo "Injecting secure vault assets into runtime environment..."
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhubb', 
                    usernameVariable: 'USER', 
                    passwordVariable: 'PASS'
                )]) {
                    echo "Logging into Docker Hub..."
                    bat 'docker login -u %USER% -p %PASS%'
                    echo "Pushing application image..."
                    bat 'docker push %DOCKER_IMAGE%'
                }
            }
        }

        stage('Deploy & Monitor Rollout') {
            steps {
                withCredentials([file(credentialsId: 'kuberconfig', variable: 'KUBECONFIG')]) {
                    bat '''
                    set KUBECONFIG=%KUBECONFIG%
                    
                    echo "Applying manifests to the cluster..."
                    kubectl apply -f deployment.yaml --validate=false
                    
                    echo "Monitoring deployment stability (60-second window)..."
                    kubectl rollout status deployment/e-waste-portal --timeout=60s
                    '''
                }
            }
            // Feature: Automated Recovery / Rollback from Failed Releases
            post {
                failure {
                    withCredentials([file(credentialsId: 'kuberconfig', variable: 'KUBECONFIG')]) {
                        echo "🚨 CRITICAL WARNING: Application failed health probes! Rolling back to last functional release..."
                        bat '''
                        set KUBECONFIG=%KUBECONFIG%
                        kubectl rollout undo deployment/e-waste-portal
                        kubectl rollout status deployment/e-waste-portal
                        '''
                    }
                }
            }
        }
    }
}
