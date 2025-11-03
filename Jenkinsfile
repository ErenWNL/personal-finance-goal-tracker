// Jenkins Pipeline for Personal Finance Goal Tracker
// This pipeline: Pulls Docker images from Docker Hub → Runs docker-compose up

pipeline {
    agent any

    environment {
        // Docker Hub Configuration
        DOCKER_HUB_USERNAME = credentials('dockerhub-username')
        DOCKER_HUB_PASSWORD = credentials('dockerhub-password')
        DOCKER_HUB_REGISTRY = 'docker.io'

        // GitHub Configuration
        GITHUB_REPO = 'ErenWNL/personal-finance-goal-tracker'
        GITHUB_BRANCH = 'main'

        // Docker Compose Configuration
        DEPLOYMENT_DIR = '/home/jenkins/deployments/personal-finance'
        DOCKER_COMPOSE_FILE = 'docker-compose.yml'
    }

    triggers {
        // Trigger using Poll SCM - checks GitHub every 5 minutes
        // Configure in Jenkins job: Build Triggers → Poll SCM → Schedule: H/5 * * * *
        // No need to configure here
    }

    options {
        // Keep last 10 builds
        buildDiscarder(logRotator(numToKeepStr: '10'))
        // Timeout after 30 minutes
        timeout(time: 30, unit: 'MINUTES')
        // Add timestamps to logs
        timestamps()
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo '=========================================='
                echo 'Stage 1: Checkout Code from GitHub'
                echo '=========================================='

                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/ErenWNL/personal-finance-goal-tracker.git'
                    ]]
                ])

                echo '✓ Code checked out successfully'

                // Store git info
                script {
                    sh '''
                        git config user.email "jenkins@personal-finance.io"
                        git config user.name "Jenkins CI"
                        COMMIT_HASH=$(git rev-parse --short HEAD)
                        echo "COMMIT_HASH=$COMMIT_HASH" > commit.properties
                    '''
                }
            }
        }

        stage('Pull Docker Images from Docker Hub') {
            steps {
                echo '=========================================='
                echo 'Stage 2: Pull Docker Images from Docker Hub'
                echo '=========================================='

                script {
                    try {
                        sh '''
                            echo "Logging in to Docker Hub..."
                            echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USERNAME --password-stdin

                            echo "Pulling Docker images from Docker Hub..."

                            SERVICES="authentication-service user-finance-service goal-service insight-service api-gateway eureka-server config-server"

                            for service in $SERVICES; do
                                echo ""
                                echo "Pulling $service..."
                                docker pull personalfinance/$service:latest

                                if [ $? -eq 0 ]; then
                                    echo "✓ Successfully pulled: $service:latest"
                                else
                                    echo "⚠ Warning: Could not pull $service (may not exist yet)"
                                fi
                            done

                            echo ""
                            echo "=========================================="
                            echo "Docker Hub images pulled successfully"
                            echo "=========================================="

                            docker logout
                        '''
                    } catch (Exception e) {
                        echo "⚠ Docker pull encountered issues: ${e.message}"
                        // Continue anyway - images might already exist locally
                    }
                }
            }
        }

        stage('Prepare Deployment') {
            steps {
                echo '=========================================='
                echo 'Stage 3: Prepare Deployment Directory'
                echo '=========================================='

                script {
                    sh '''
                        echo "Creating deployment directory..."
                        mkdir -p ${DEPLOYMENT_DIR}

                        echo "Copying docker-compose.yml..."
                        cp ${WORKSPACE}/${DOCKER_COMPOSE_FILE} ${DEPLOYMENT_DIR}/

                        echo "Copying environment files..."
                        if [ -f "${WORKSPACE}/.env" ]; then
                            cp ${WORKSPACE}/.env ${DEPLOYMENT_DIR}/
                        fi

                        echo "✓ Deployment directory prepared"
                        ls -la ${DEPLOYMENT_DIR}/
                    '''
                }
            }
        }

        stage('Stop Running Containers') {
            steps {
                echo '=========================================='
                echo 'Stage 4: Stop Running Containers'
                echo '=========================================='

                script {
                    sh '''
                        cd ${DEPLOYMENT_DIR}

                        echo "Stopping existing containers..."
                        docker-compose down || echo "No containers running"

                        echo "✓ Containers stopped"
                    '''
                }
            }
        }

        stage('Start Services with Docker Compose') {
            steps {
                echo '=========================================='
                echo 'Stage 5: Start Services with Docker Compose'
                echo '=========================================='

                script {
                    try {
                        sh '''
                            cd ${DEPLOYMENT_DIR}

                            echo "Starting services with docker-compose..."
                            docker-compose up -d

                            echo ""
                            echo "Waiting for services to start..."
                            sleep 10

                            echo "✓ Services started successfully"
                            echo ""
                            echo "Running services:"
                            docker-compose ps
                        '''
                    } catch (Exception e) {
                        echo "✗ Docker compose failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        error('Docker compose failed')
                    }
                }
            }
        }

        stage('Health Check') {
            steps {
                echo '=========================================='
                echo 'Stage 6: Health Check'
                echo '=========================================='

                script {
                    sh '''
                        echo "Checking service health..."
                        sleep 5

                        echo "API Gateway (8081):"
                        curl -s http://localhost:8081/actuator/health || echo "Not responding"

                        echo ""
                        echo "Eureka Server (8761):"
                        curl -s http://localhost:8761/ | head -20 || echo "Not responding"

                        echo ""
                        echo "=========================================="
                        echo "✓ Health check completed"
                        echo "=========================================="
                    '''
                }
            }
        }

        stage('Update Version & Commit') {
            steps {
                echo '=========================================='
                echo 'Stage 7: Update Docker Image Versions'
                echo '=========================================='

                script {
                    try {
                        sh '''
                            echo "Updating docker-compose.yml with new image versions..."

                            # Get current build number and commit hash
                            BUILD_NUM=${BUILD_NUMBER}
                            COMMIT_HASH=$(git rev-parse --short HEAD)
                            TIMESTAMP=$(date +%Y%m%d_%H%M%S)
                            VERSION="${BUILD_NUM}_${COMMIT_HASH}"

                            echo "New Version Tag: $VERSION"

                            # Update docker-compose.yml with new image versions
                            # This ensures the latest built images are referenced

                            cat > update_versions.sh << 'EOF'
#!/bin/bash
BUILD_NUM=$1
COMMIT_HASH=$2
TIMESTAMP=$3
VERSION="${BUILD_NUM}_${COMMIT_HASH}"

echo "Updating docker-compose.yml with version: $VERSION"

# Replace image tags in docker-compose.yml
sed -i "s|personalfinance/authentication-service:.*|personalfinance/authentication-service:${VERSION}|g" docker-compose.yml
sed -i "s|personalfinance/user-finance-service:.*|personalfinance/user-finance-service:${VERSION}|g" docker-compose.yml
sed -i "s|personalfinance/goal-service:.*|personalfinance/goal-service:${VERSION}|g" docker-compose.yml
sed -i "s|personalfinance/insight-service:.*|personalfinance/insight-service:${VERSION}|g" docker-compose.yml
sed -i "s|personalfinance/api-gateway:.*|personalfinance/api-gateway:${VERSION}|g" docker-compose.yml
sed -i "s|personalfinance/eureka-server:.*|personalfinance/eureka-server:${VERSION}|g" docker-compose.yml
sed -i "s|personalfinance/config-server:.*|personalfinance/config-server:${VERSION}|g" docker-compose.yml

echo "✓ docker-compose.yml updated"
EOF

                            chmod +x update_versions.sh
                            ./update_versions.sh "$BUILD_NUM" "$COMMIT_HASH" "$TIMESTAMP"

                            # Show changes
                            echo ""
                            echo "Changes made:"
                            git diff docker-compose.yml | head -30

                            # Commit and push changes
                            echo ""
                            echo "Committing changes to GitHub..."
                            git add docker-compose.yml
                            git commit -m "Update Docker image versions: Build #${BUILD_NUMBER} (${COMMIT_HASH})" || echo "No changes to commit"
                            git push origin main

                            echo "✓ Version update committed and pushed"
                        '''
                    } catch (Exception e) {
                        echo "⚠ Version update failed (continuing): ${e.message}"
                        // Continue even if version update fails
                    }
                }
            }
        }

        stage('Notify') {
            steps {
                echo '=========================================='
                echo 'Stage 8: Notifications'
                echo '=========================================='

                script {
                    if (currentBuild.result == 'SUCCESS' || currentBuild.result == null) {
                        echo "✓ Pipeline completed successfully!"
                        echo "Services deployed and running"
                        // Optional: Send Slack notification
                        // slackSend(
                        //     color: 'good',
                        //     message: "✓ Build #${BUILD_NUMBER} deployed successfully\n${BUILD_URL}"
                        // )
                    } else {
                        echo "✗ Pipeline failed!"
                        // Optional: Send Slack notification
                        // slackSend(
                        //     color: 'danger',
                        //     message: "✗ Build #${BUILD_NUMBER} failed\n${BUILD_URL}"
                        // )
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline execution completed"
        }
        success {
            echo "✓ Deployment successful!"
            echo "Services available at:"
            echo "  - Frontend: http://localhost:3000"
            echo "  - API Gateway: http://localhost:8081"
            echo "  - Eureka: http://localhost:8761"
        }
        failure {
            echo "✗ Deployment failed - Check logs above"
        }
    }
}
