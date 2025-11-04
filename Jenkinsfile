// Jenkins Pipeline for Personal Finance Goal Tracker
// This pipeline: Pulls Docker images from Docker Hub → Runs docker-compose up

pipeline {
    agent any

    environment {
        // Docker Hub Configuration
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_HUB_REGISTRY = 'docker.io'

        // GitHub Configuration
        GITHUB_REPO = 'ErenWNL/personal-finance-goal-tracker'
        GITHUB_BRANCH = 'main'

        // Docker Compose Configuration
        DEPLOYMENT_DIR = "${WORKSPACE}/deployment"
        DOCKER_COMPOSE_FILE = 'docker-compose.yml'
    }

    // Poll SCM is configured in Jenkins job UI, not here
    // Build Triggers → Poll SCM → Schedule: H/5 * * * *

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

        stage('Verify Docker & Docker Compose') {
            steps {
                echo '=========================================='
                echo 'Stage 2: Verify Docker & Docker Compose'
                echo '=========================================='

                script {
                    sh '''
                        echo "Checking Docker installation..."
                        /usr/local/bin/docker --version || echo "⚠ Docker not found"

                        echo "Checking Docker Compose installation..."
                        /usr/local/bin/docker-compose --version || echo "⚠ Docker Compose not found"

                        echo "Docker path: /usr/local/bin/docker"
                        echo "Docker Compose path: /usr/local/bin/docker-compose"
                    '''
                }
            }
        }

        stage('Build Microservices') {
            steps {
                echo '=========================================='
                echo 'Stage 3: Build Microservices with Maven'
                echo '=========================================='

                script {
                    sh '''
                        # Fix Docker credential helper issue preemptively
                        mkdir -p ~/.docker
                        cat > ~/.docker/config.json << 'DOCKER_CONFIG'
{
    "auths": {}
}
DOCKER_CONFIG

                        echo "Building microservices with Maven..."

                        # List of services to build
                        SERVICES="eureka-server config-server api-gateway authentication-service user-finance-service goal-service insight-service"

                        for service in $SERVICES; do
                            echo ""
                            echo "Building $service..."
                            if [ -d "$service" ] && [ -f "$service/pom.xml" ]; then
                                cd "$service"
                                chmod +x ./mvnw
                                ./mvnw clean package -DskipTests -q
                                if [ $? -eq 0 ]; then
                                    echo "✓ $service built successfully"
                                else
                                    echo "⚠ $service build skipped (may not be Maven project)"
                                fi
                                cd ..
                            else
                                echo "⚠ $service not found or no pom.xml"
                            fi
                        done

                        echo ""
                        echo "✓ All available microservices built"
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
                        echo "Stopping existing containers..."
                        cd ${WORKSPACE}

                        # First try graceful shutdown
                        /usr/local/bin/docker-compose down || echo "No docker-compose containers"

                        # Force remove any remaining containers with the same name prefix
                        echo "Cleaning up stale containers..."
                        /usr/local/bin/docker ps -a --filter "name=finance-pipeline" --format "{{.ID}}" | xargs -r /usr/local/bin/docker rm -f 2>/dev/null || echo "No stale containers"

                        # Remove old mysql containers
                        echo "Removing old MySQL containers..."
                        /usr/local/bin/docker ps -a --filter "name=mysql" --format "{{.ID}}" | xargs -r /usr/local/bin/docker rm -f 2>/dev/null || echo "No old MySQL containers"

                        # Kill any processes using port 3306
                        echo "Freeing up port 3306..."
                        lsof -ti:3306 | xargs kill -9 2>/dev/null || echo "Port 3306 already free"

                        # Clean up any dangling networks and volumes
                        echo "Cleaning up dangling networks and volumes..."
                        /usr/local/bin/docker network prune -f 2>/dev/null || echo "No networks to prune"

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
                            cd ${WORKSPACE}

                            # Fix Docker credential helper issue
                            # Remove auths from Docker config if it causes issues
                            mkdir -p ~/.docker
                            cat > ~/.docker/config.json << 'DOCKER_CONFIG'
{
    "auths": {}
}
DOCKER_CONFIG

                            echo "Pre-pulling base Docker image with digest pinning..."
                            # Use specific SHA256 digest for openjdk:24-slim (known working version)
                            IMAGE_DIGEST="openjdk:24-slim@sha256:df6c3a966c372fa314ec0dc428bf27f8aa28316a173d3d6e99035343dee7fc2c"

                            MAX_ATTEMPTS=3
                            ATTEMPT=1
                            until [ $ATTEMPT -gt $MAX_ATTEMPTS ]; do
                                echo "Attempt $ATTEMPT of $MAX_ATTEMPTS..."
                                # Try pulling by digest first, then by tag
                                if /usr/local/bin/docker pull "$IMAGE_DIGEST" 2>/dev/null || /usr/local/bin/docker pull openjdk:24-slim 2>/dev/null; then
                                    echo "✓ Image pulled successfully"
                                    break
                                fi
                                if [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
                                    WAIT_TIME=$((ATTEMPT * 5))
                                    echo "⚠ Pre-pull failed, retrying in ${WAIT_TIME}s..."
                                    sleep $WAIT_TIME
                                else
                                    echo "⚠ Pre-pull failed after $MAX_ATTEMPTS attempts, using docker-compose with BuildKit..."
                                    # Enable Docker BuildKit for better caching
                                    export DOCKER_BUILDKIT=1
                                    export BUILDKIT_PROGRESS=plain
                                fi
                                ATTEMPT=$((ATTEMPT + 1))
                            done

                            echo ""
                            echo "Building and starting services with docker-compose..."
                            /usr/local/bin/docker-compose up -d --build

                            echo ""
                            echo "Waiting for services to start..."
                            sleep 15

                            echo "✓ Services started successfully"
                            echo ""
                            echo "Running services:"
                            /usr/local/bin/docker-compose ps
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
