pipeline {
    agent any

    environment {
        APP_DIR = "${WORKSPACE}"
        RAILS_ENV = "development"   // change to production later
    }

    stages {

        stage('Start Server') {
            steps {
                sh '''
                cd $APP_DIR

                echo "▶️ Starting Rails server..."

                # Kill existing rails server
                pkill -f "rails server" || true

                # Start Rails server in background
                RAILS_ENV=development setsid bundle exec rails server -b 0.0.0.0 -p 3000 > app.log 2>&1 < /dev/null &
                '''
            }
        }

    }

    post {
        success {
            echo '✅ App deployed and running!'
        }
        failure {
            echo '❌ Deployment failed!'
        }
    }
}