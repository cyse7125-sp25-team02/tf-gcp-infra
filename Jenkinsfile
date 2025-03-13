pipeline {
    agent any
    
    options {
        timeout(time: 15, unit: 'MINUTES')
    }
    
    environment {
        TF_IN_AUTOMATION = 'true'
        TF_INPUT = 'false'
    }
    
    stages {
        stage('Validate Dev Environment') {
            steps {
                dir('gcp-project-dev') {
                    withCredentials([file(credentialsId: 'gcp-service-account-key', variable: 'GCP_KEY_FILE')]) {
                        withEnv(["GOOGLE_APPLICATION_CREDENTIALS=${GCP_KEY_FILE}"]) {
                            sh 'gcloud auth activate-service-account --key-file=$GCP_KEY_FILE'
                            sh 'terraform init -no-color'
                            sh 'terraform fmt -check -no-color'
                            sh 'terraform validate -no-color'
                        }
                    }
                }
            }
        }
        
        stage('Validate DNS Environment') {
            steps {
                dir('gcp-project-dns') {
                    sh 'terraform init -no-color'
                    sh 'terraform fmt -check -no-color'
                    sh 'terraform validate -no-color'
                }
            }
        }
        
        stage('Validate Prod Environment') {
            steps {
                dir('gcp-project-prod') {
                    sh 'terraform init -no-color'
                    sh 'terraform fmt -check -no-color'
                    sh 'terraform validate -no-color'
                }
            }
        }
        
        stage('Validate Bastion Module') {
            steps {
                dir('modules/bastion') {
                    sh 'terraform init -no-color'
                    sh 'terraform fmt -check -no-color'
                    sh 'terraform validate -no-color'
                }
            }
        }
        
        stage('Validate GKE Module') {
            steps {
                dir('modules/gke') {
                    sh 'terraform init -no-color'
                    sh 'terraform fmt -check -no-color'
                    sh 'terraform validate -no-color'
                }
            }
        }
        
        stage('Validate Networking Module') {
            steps {
                dir('modules/networking') {
                    sh 'terraform init -no-color'
                    sh 'terraform fmt -check -no-color'
                    sh 'terraform validate -no-color'
                }
            }
        }

        stage('Validate CMEK Module') {
            steps {
                dir('modules/cmek') {
                    sh 'terraform init -no-color'
                    sh 'terraform fmt -check -no-color'
                    sh 'terraform validate -no-color'
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo 'All Terraform configurations validated successfully!'
        }
        failure {
            echo 'Terraform validation failed. Check the logs for details.'
        }
    }
}