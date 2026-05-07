pipeline {
    agent any

    environment {
        APP_DIR =  "/var/www/TBCORP"
        RAILS_ENV = "development"   // change to production later
    }

    stage('Deploy Code (rsync)') {
            steps {
                sh '''
                echo "🚀 Deploying using rsync..."

                mkdir -p $APP_DIR

                rsync -av --delete \
                  --exclude='.git' \
                  --exclude='log' \
                  --exclude='tmp' \
                  --exclude='node_modules' \
                  $WORKSPACE/ $APP_DIR/
                '''
            }
        }

    // stages {

    //     stage('Start Server') {
    //         steps {
    //             sh '''
    //             cd $APP_DIR

    //             echo "▶️ Starting Rails server..."

    //             # Kill existing rails server
    //             pkill -f "rails server" || true

    //             # Start Rails server in background
    //             RAILS_ENV=development setsid bundle exec rails server -b 0.0.0.0 -p 3000 > app.log 2>&1 < /dev/null &
    //             '''
    //         }
    //     }

    // }

    post {
        success {
            echo '✅ App deployed and running!'
        }
        failure {
            echo '❌ Deployment failed!'
        }
    }
}