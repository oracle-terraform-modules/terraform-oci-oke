pipeline {

  agent any
	parameters {
		choice (name: 'ACTION',
				choices: [ 'plan', 'apply', 'destroy'],
				description: 'Run terraform plan / apply / destroy')
    }

  stages {

    stage('Checkout') {
      steps {
         sh 'PATH=/usr/local/bin'
         // sh 'terraform fmt'//
         println 'Initiate Terraform provider'
         sh 'terraform init' //only need for first run 
         // sh 'terraform refresh -lock=false'//
         // sh 'cp terraform.tfvars .'//
         sh 'ls'
               
      }
    }

    stage('TF Plan') {
      			when { anyOf
					{
						environment name: 'ACTION', value: 'plan';
					}
        }          
                  
    steps {
          
          sh 'PATH=/usr/local/bin'
         // sh 'terraform fmt'//
          //sh 'terraform init' //only need for first run 
         // sh 'terraform refresh -lock=false'//
         //sh 'cp vars.tf .'//
          println 'List all files needed'
          sh 'ls'
          println 'Terraform plan oke'
          sh 'terraform plan  -lock=false -out oke_plan'
      }      
    }

    //stage('Approval') {
    //  steps {
    //    script {
    //      def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
    //    }
    //  }
    //}

    stage('TF Apply') {
      			when { anyOf
					{
						environment name: 'ACTION', value: 'apply'
					}
				}
      steps {
          println 'Apply the TF Infrastructure oke_plan'
          sh 'terraform apply -lock=false -auto-approve oke_plan'
        }
      }
 
    stage('TF Destroy') {
	       			when { anyOf
					{
						environment name: 'ACTION', value: 'destroy';
					}
				}
      steps {
          println 'Destroy the TF Infrastructure'
          sh 'terraform destroy -lock=false -auto-approve'
        }
      }
    }
}
