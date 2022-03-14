pipeline {

    agent{
        label 'jamesbond'
    }

    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "M3"
    }
    environment {
        IMAGE = readMavenPom().getArtifactId()
        VERSION = readMavenPom().getVersion()
        
    }
    stages {
        
        stage('Clear running apps'){
            steps{
                
                sh 'docker rm -f pandaapp || true'
            }
            
        }
        stage('Build and Junit'){
            steps{
                sh "mvn clean install"
            }
        }

        stage('Build Docker image'){
            steps{
                sh "mvn package -Pdocker"
            }
        }
        stage('Run Docker app'){
            steps{
                sh "docker run -d -p 0.0.0.0:8080:8080 --name pandaapp ${IMAGE}:${VERSION}"
            }
        }
        stage('Test Selenium'){
            steps{
                sh "mvn test -Pselenium"
            }
        }
        stage('Deploy jar to artifactory'){
            steps{
                
                /*withMaven(globalMavenSettingsConfig: 'null', jdk: 'null', maven: 'M3', mavenSettingsConfig: '493c7c67-5f92-477c-9709-4ee8e175cf4c') {
                    sh 'mvn deploy'
                }*/
                //alternatywa
                configFileProvider([configFile(fileId: '493c7c67-5f92-477c-9709-4ee8e175cf4c', variable: 'MAVEN_GLOBAL_SETTINGS')]) {
                    sh "mvn -gs $MAVEN_GLOBAL_SETTINGS deploy -Dmaven.test.skip=true -e"
                }
            }
        }
        stage('Run terraform') {
            steps{
                dir('infrastructure/terraform'){

                
                    withCredentials([file(credentialsId: 'panda_key', variable: 'terraformpanda')]) {
                    sh "cp \$terraformpanda ../panda.pem"
                    }

                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws']]) {

                         sh 'terraform init && terraform apply -auto-approve -var-file panda.tfvars'

                    }  
                
                }
                
            }
        }
        stage('Copy Ansible role'){
            steps{

                sh 'sleep 180'
                sh 'cp -r infrastructure/ansible/panda/ /etc/ansible/roles'
            }
        }
        stage('Run Ansible'){
            steps{
                dir('infrastructure/ansible')
                sh 'chmod 600 ../panda.pem'
                sh 'ansible-playbook -i ./inventory playbook.yml -e ansible_python_interpreter=/usr/bin/python3'
            }
        }
        stage('Remove environment') {
            steps {
                input 'Remove environment'
                dir('infrastructure/terraform') { 
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws']]) {
                        sh 'terraform destroy -auto-approve -var-file panda.tfvars'
                    }
                }
            }
        }

    }
    post {

        success {
            sh 'docker stop pandaapp'
            deleteDir()
        }
        failure {
            dir('infrastructure/terraform') { 
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS']]) {
                    sh 'terraform destroy -auto-approve -var-file panda.tfvars'
                }
            }
            sh 'docker stop pandaapp'
            deleteDir()
        }
    }

}
