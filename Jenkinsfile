pipeline {
    agent any

     parameters {
    string(name: 'CLUSTER_NAME', defaultValue: 'elliott-eks-fargate-deux')
    string(name: 'ACCOUNT_NUMBER', defaultValue: '780988366548')
    string(name: 'USER_NAME', defaultValue: 'kratos')
    string(name: 'REGION', defaultValue: 'us-west-2')
  }

    stages {

         stage('Test') {
            steps {
                echo 'Testing..'
                sh ("terraform init")
                sh ("terraform plan")
            }
        }

        stage('Build & Deploy') {
            steps {
                sh ("terraform apply --auto-approve")
              
            }


        }


// /var/lib/jenkins/.kube/config
          stage('Install Prometheus and Grafana') {
            steps {
                echo 'Setting up Monitoring...'
              
            }


        }
       
      
    }
}