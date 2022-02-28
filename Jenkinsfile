pipeline {
    agent{
        label 'jamesbond'
    }

    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "M3"
    }

    stages {
        
        stage('Clear running apps'){
            steps{
                
                sh 'docker rm -f pandaapp || true'
            }
            
        }
        
        stage('Clone'){
            steps{
                git branch: 'final', url: 'https://github.com/andm90/panda_application'
            }
            
        }        
        stage('Build') {
            steps {
                // Get some code from a GitHub repository
                

                // Run Maven on a Unix agent.
                sh "mvn -Dmaven.test.failure.ignore=true clean install"

                // To run Maven on a Windows agent, use
                // bat "mvn -Dmaven.test.failure.ignore=true clean package"
            }
        }
        stage('Test') {
            steps {
                // Get some code from a GitHub repository
                
                // Run Maven on a Unix agent.
                sh "mvn test -Pselenium"

                // To run Maven on a Windows agent, use
                // bat "mvn -Dmaven.test.failure.ignore=true clean package"
            }
        
            post {
                // If Maven was able to run the tests, even if some of the test
                // failed, record the test results and archive the jar file.
                success {
                    junit '**/target/surefire-reports/TEST-*.xml'
                    archiveArtifacts 'target/*.jar'
                }
            }
        }
    }
}
