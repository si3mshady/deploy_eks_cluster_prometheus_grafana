pipeline {
    agent any

     parameters {
    string(name: 'CLUSTER_NAME', defaultValue: 'elliotteks')
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
            
                // sh("eksctl create cluster --name $CLUSTER_NAME --region $REGION --fargate" || true)
                sh ("terraform apply --auto-approve")
                sh("eksctl create iamidentitymapping --cluster  $CLUSTER_NAME --region=$REGION --arn arn:aws:iam::$ACCOUNT_NUMBER:user/$USER_NAME --group system:masters --username $USER_NAME")

                sh("sh aws eks update-kubeconfig --name $CLUSTER_NAME")
                // sh ("terraform destroy --auto-approve")

              
            }


        }

          stage('Install Prometheus and Grafana') {
            steps {
                echo 'Setting up Monitoring...'
                sh("helm repo add prometheus-community https://prometheus-community.github.io/helm-charts")
                sh("helm repo update")
                sh("helm install studio-prom prometheus-community/kube-prometheus-stack")
            }


        }
       
      
    }
}