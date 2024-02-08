pipeline {
    agent any

    stages {
        stage('Get Code') {
            steps {
                git url: 'https://github.com/anafernandez16/todo-list-aws.git', branch: 'develop'
                echo "Workspace: ${WORKSPACE}"
                sh 'whoami'
                sh 'hostname'
            }
        }
        
        stage('Static') {
            steps {
                sh '''
                python3 -m flake8 --format=pylint --exit-zero src >flake8.out
                '''
               recordIssues tools: [flake8(name: 'Flake8', pattern: 'flake8.out')], qualityGates : [[threshold: 8, type: 'TOTAL', unstable: true], [threshold: 10, type: 'TOTAL', unstable: false]]            
                }
        }
        
        stage('Sam') {
            steps {
                sh '''
                sam build
                sam deploy --stack-name todo-aws-jenkins --resolve-s3 --region us-east-1 --no-fail-on-empty-changeset --force-upload
                '''
                }
        }
        
        stage('Rest Test') {
            steps {
                script {
                    def BASE_URL = sh(script: "aws cloudformation describe-stacks  --stack-name todo-aws-jenkins --query 'Stacks[0].Outputs[?OutputKey==`BaseUrlApi`].OutputValue' --output text", returnStdout: true)
                    sh "bash scripts/baseurl.sh ${BASE_URL}"
                }

                }
        }
        
        stage('Promote') {
            steps {
            sh '''
             git checkout master
             git merge develop
             git add .
             git commit -m "merge to master"
             git push
            '''
        
                }
}
    }
        post {
        always {
            cleanWs()
        }
        
        }
    
}