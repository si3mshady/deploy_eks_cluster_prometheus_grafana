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

                sh("aws eks update-kubeconfig --name $CLUSTER_NAME --region=$REGION")
                sh ("sudo sed -i 's/v1alpha1/v1beta1/g' /var/lib/jenkins/.kube/config")
                // sh ("terraform destroy --auto-approve")
                // jenkins ALL=(ALL) NOPASSWD: ALL
              
            }


        }


// /var/lib/jenkins/.kube/config
          stage('Install Prometheus and Grafana') {
            steps {
                echo 'Setting up Monitoring...'
                sh("helm repo add prometheus-community https://prometheus-community.github.io/helm-charts")
                sh("helm repo update")
                sh("helm install studio-prom-1 prometheus-community/kube-prometheus-stack")
            }


        }
       
      
    }
}