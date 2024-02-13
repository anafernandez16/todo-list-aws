pipeline {
    agent any

    stages {
        stage('Get Code') {
            steps {
                git url: "https://github.com/anafernandez16/todo-list-aws.git", branch: 'develop'
                echo "Workspace: ${WORKSPACE}"
            }
        }
        
        stage('Static') {
            steps {
                sh '''
                python3 -m flake8 --format=pylint --exit-zero src >flake8.out
                bandit --exit-zero -r . -f custom -o bandit.out -ll --msg-template="{relpath}:{line}: [{test_id}, {severity}] {msg}"  
                '''
               recordIssues tools: [flake8(name: 'Flake8', pattern: 'flake8.out')], qualityGates : [[threshold: 8, type: 'TOTAL', unstable: true], [threshold: 10, type: 'TOTAL', unstable: false]] 
               recordIssues tools: [pyLint(name: 'Bandit', pattern: 'bandit.out')], qualityGates: [[threshold: 2, type: 'TOTAL', unstable: true], [threshold: 4, type: 'TOTAL', unstable: false]]
                }
        }
        
        stage('Sam') {
            steps {
                sh '''
                sam build
                sam deploy --stack-name todo-list-staging --resolve-s3 --region us-east-1 --no-fail-on-empty-changeset --force-upload --config-env staging
                '''
                }
        }
        
        stage('Rest Test') {
            steps {
                script {
                    def BASE_URL = sh(script: "aws cloudformation describe-stacks  --stack-name todo-list-staging --query 'Stacks[0].Outputs[?OutputKey==`BaseUrlApi`].OutputValue' --output text", returnStdout: true).trim()
                    // sh "bash scripts/baseurl.sh ${BASE_URL}"
                   sh "BASE_URL=${BASE_URL} pytest --junitxml=result-rest.xml test/integration/todoApiTest.py"
                }
                junit 'result*.xml'

                }
        }
        
        stage('Promote') {
            steps {
            withCredentials([gitUsernamePassword(credentialsId: 'github-credentials', gitToolName: 'Default')]) {
            sh '''
             git add .
             git commit -m "add changes to develop"
             git push --set-upstream origin develop
             git checkout master
             git merge develop
             git push
              '''
            }
                }
        }
    }
        post {
        always {
            cleanWs()
        }
        
        }
    
}