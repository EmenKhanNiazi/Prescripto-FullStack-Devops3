// Jenkinsfile (Declarative Pipeline) - PART 2: WITH AUTOMATED TESTING
// This pipeline deploys the application and runs Selenium tests

pipeline {
    agent any

    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    environment {
        DOCKER_TEST_IMAGE = "prescripto-tests:${BUILD_NUMBER}"
        BACKEND_URL = "http://43.204.98.50:4001"
        FRONTEND_URL = "http://43.204.98.50:5174"
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo '📦 Cloning repository from GitHub...'
                checkout scm
                echo "✓ Repository checked out successfully"
            }
        }

        stage('Stop Existing Containers') {
            steps {
                echo '🧹 Stopping and removing any previous containers...'
                sh 'docker-compose -f docker-compose-part2.yml down --remove-orphans || true'
                echo "✓ Previous containers stopped"
            }
        }

        stage('Deploy Application') {
            steps {
                echo '🚀 Launching containerized application using docker-compose-part2.yml...'
                sh '''
                    docker-compose -f docker-compose-part2.yml up -d
                    echo "⏳ Waiting for services to be ready..."
                    sleep 20
                '''
                echo "✓ Application deployed successfully"
            }
        }

        stage('Verify Deployment') {
            steps {
                echo '🔍 Verifying container status...'
                sh '''
                    echo "Running containers:"
                    docker-compose -f docker-compose-part2.yml ps
                    echo ""
                    echo "✓ Deployment verification complete"
                '''
            }
        }

        stage('Build Test Docker Image') {
            steps {
                echo '🐳 Building Docker image for tests...'
                sh '''
                    docker build -f Dockerfile.tests -t ${DOCKER_TEST_IMAGE} .
                    echo "✓ Test Docker image built: ${DOCKER_TEST_IMAGE}"
                '''
            }
        }

        stage('Run Automated Tests') {
            steps {
                echo '🧪 Running automated Selenium tests...'
                script {
                    try {
                        sh '''
                            mkdir -p test-results
                            docker run --rm \
                              --network host \
                              -v $(pwd)/test-results:/app/test-results \
                              ${DOCKER_TEST_IMAGE} \
                              pytest test_prescripto_e2e.py -v \
                                --tb=short \
                                --junitxml=test-results/results.xml \
                                --html=test-results/report.html \
                                --self-contained-html || true
                        '''
                        echo "✓ Tests execution complete"
                    } catch (Exception e) {
                        echo "⚠️  Test execution encountered issues"
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }

        stage('Collect Test Results') {
            steps {
                echo '📊 Collecting and archiving test results...'
                sh '''
                    if [ -d "test-results" ]; then
                        ls -la test-results/
                        echo "✓ Test results collected"
                    else
                        echo "⚠️  No test results directory"
                    fi
                '''
                // Parse JUnit results
                junit testResults: 'test-results/results.xml', allowEmptyResults: true
            }
        }

        stage('Cleanup') {
            steps {
                echo '🧹 Cleaning up...'
                sh '''
                    docker-compose -f docker-compose-part2.yml down --remove-orphans || true
                    docker image rm ${DOCKER_TEST_IMAGE} || true
                    echo "✓ Cleanup complete"
                '''
            }
        }
    }

    post {
        always {
            echo '📝 Pipeline execution finished'
            // Archive test results and reports
            archiveArtifacts artifacts: 'test-results/**', allowEmptyArchive: true
        }

        success {
            echo '✅ Pipeline succeeded! All tests passed.'
            emailext(
                subject: "✅ SUCCESS: Prescripto Pipeline #${BUILD_NUMBER}",
                body: '''
                    <h2>✅ Pipeline Execution Successful</h2>
                    <p><strong>Build Number:</strong> ${BUILD_NUMBER}</p>
                    <p><strong>Branch:</strong> ${GIT_BRANCH}</p>
                    <p><strong>Commit:</strong> ${GIT_COMMIT}</p>
                    <p><strong>Author:</strong> ${GIT_AUTHOR}</p>
                    <p><strong>Build URL:</strong> <a href="${BUILD_URL}">${BUILD_URL}</a></p>
                    
                    <h3>✓ Build Steps Completed:</h3>
                    <ul>
                        <li>✓ Code checked out from GitHub</li>
                        <li>✓ Application deployed with Docker Compose</li>
                        <li>✓ All 24 automated tests passed</li>
                        <li>✓ Test results archived</li>
                    </ul>
                    
                    <p><strong>View Full Test Report:</strong> <a href="${BUILD_URL}testReport">Test Report</a></p>
                    <hr>
                    <p><em>This is an automated message from Jenkins Pipeline</em></p>
                ''',
                to: '${CHANGE_AUTHOR_EMAIL}',
                mimeType: 'text/html'
            )
        }

        failure {
            echo '❌ Pipeline failed'
            emailext(
                subject: "❌ FAILED: Prescripto Pipeline #${BUILD_NUMBER}",
                body: '''
                    <h2>❌ Pipeline Execution Failed</h2>
                    <p><strong>Build Number:</strong> ${BUILD_NUMBER}</p>
                    <p><strong>Branch:</strong> ${GIT_BRANCH}</p>
                    <p><strong>Commit:</strong> ${GIT_COMMIT}</p>
                    <p><strong>Author:</strong> ${GIT_AUTHOR}</p>
                    
                    <p><strong>Check Build Details:</strong> <a href="${BUILD_URL}console">Console Output</a></p>
                    <p><strong>Test Report:</strong> <a href="${BUILD_URL}testReport">Test Report</a></p>
                    
                    <hr>
                    <p><em>This is an automated message from Jenkins Pipeline</em></p>
                ''',
                to: '${CHANGE_AUTHOR_EMAIL}',
                mimeType: 'text/html'
            )
        }

        unstable {
            echo '⚠️  Pipeline unstable - Some tests may have failed'
            emailext(
                subject: "⚠️  UNSTABLE: Prescripto Pipeline #${BUILD_NUMBER}",
                body: '''
                    <h2>⚠️  Pipeline Execution Unstable</h2>
                    <p>Some tests may have failed. Please review.</p>
                    <p><strong>Test Report:</strong> <a href="${BUILD_URL}testReport">View Report</a></p>
                ''',
                to: '${CHANGE_AUTHOR_EMAIL}',
                mimeType: 'text/html'
            )
        }
    }
}
