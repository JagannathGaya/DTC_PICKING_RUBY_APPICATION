pipeline {
    agent any

    environment {
        APP_DIR = "/var/www/TBCORP"
        RAILS_ENV = "development"   // change to production later
    }

    stages {

        stage('Deploy Code') {
            steps {
                sh '''
                echo "🚀 Copying code..."

                 echo "🚀  $WORKSPACE "

                // mkdir -p $APP_DIR
                rm -rf $APP_DIR/*
                sudo cp -r $WORKSPACE/* $APP_DIR/
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                cd $APP_DIR

                echo "📦 Installing gems..."
                bundle install

                if [ -f "package.json" ]; then
                  echo "📦 Installing JS dependencies..."
                  yarn install
                fi
                '''
            }
        }

        stage('Setup Database') {
            steps {
                sh '''
                cd $APP_DIR

                echo "🗄 Creating & migrating DB..."
                bundle exec rails db:create
                bundle exec rails db:migrate

                echo "🌱 Seeding DB (optional)..."
                bundle exec rails db:seed || true
                '''
            }
        }

        stage('Start Server') {
            steps {
                sh '''
                cd $APP_DIR

                echo "▶️ Starting Rails server..."

                # Kill existing server if running
                pkill -f "rails server" || true

                # Start server in background
                nohup bundle exec rails server -b 0.0.0.0 -p 3000 > app.log 2>&1 &
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