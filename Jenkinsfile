pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building..'

                sh ("ls .")
                sh ("terraform init")
                sh ("terraform plan")
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}