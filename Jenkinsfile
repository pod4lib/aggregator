pipeline {
  agent any

  environment {
    SIDEKIQ_PRO_SECRET = credentials("sidekiq_pro_secret")
    SLACK_WEBHOOK_URL = credentials("access_slack_webhook")
  }

  stages {
    stage('Deploy on release') {

      when {
        tag "v*"
      }

      steps {
        checkout scm

        sshagent (['sul-devops-team', 'sul-continuous-deployment']){
          sh '''#!/bin/bash -l
          export DEPLOY=1
          export REVISION=$TAG_NAME

          # Load RVM
          rvm use 3.0.1@pod --create
          gem install bundler

          bundle install --without production

          # Deploy it
          bundle exec cap prod deploy
          '''
        }
      }

      post {
        success {
          sh '''#!/bin/bash -l
            curl -X POST -H 'Content-type: application/json' --data '{"text":"[ivplus/aggregator] The deploy to prod was successful"}' $SLACK_WEBHOOK_URL
          '''
        }

        failure {
          sh '''#!/bin/bash -l
            curl -X POST -H 'Content-type: application/json' --data '{"text":"[ivplus/aggregator] The deploy to prod was unsuccessful"}' $SLACK_WEBHOOK_URL
          '''
        }
      }
    }
  }
}
