pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building..'

                sh ("ls .")
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