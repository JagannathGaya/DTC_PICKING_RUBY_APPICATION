pipeline {
    agent any

    environment {
        APP_DIR = "/var/www/TBCORP"
        RAILS_ENV = "development"
    }

    stages {

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

        // stage('Bundle Install') {
        //     steps {
        //         sh '''
        //         cd $APP_DIR

        //         echo "📦 Installing gems..."

        //         bundle install
        //         '''
        //     }
        // }

        stage('Start Rails Server') {
            steps {
                sh '''
                cd $APP_DIR

                echo "🛑 Stopping existing Rails server..."
                pkill -f "rails server" || true

                echo "🚀 Starting Rails server..."

                BUILD_ID=dontKillMe setsid bundle exec rails server \
                  -b 0.0.0.0 \
                  -p 3000 \
                  > app.log 2>&1 < /dev/null &
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