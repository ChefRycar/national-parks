pipeline {
    agent any
    environment {
        HAB_NOCOLORING = true
        HAB_BLDR_URL = 'https://bldr.habitat.sh/'
        HAB_ORIGIN = 'nrycar'
    }
    stages {
        stage('scm') {
            steps {
                git url: 'https://github.com/ChefRycar/national-parks.git', branch: 'master'
            }
        }
        stage('build') {
            steps {
                withCredentials([string(credentialsId: 'hab-depot-token', variable: 'HAB_AUTH_TOKEN')]) {
                    script {
                       sh 'hab origin key download --secret $HAB_ORIGIN -z $HAB_AUTH_TOKEN'
                       sh 'hab origin key download $HAB_ORIGIN'
                    }
                }
                habitat task: 'build', directory: '.', origin: "${env.HAB_ORIGIN}", docker: true
            }
        }
        stage('upload') {
            steps {
                withCredentials([string(credentialsId: 'hab-depot-token', variable: 'HAB_AUTH_TOKEN')]) {
                    habitat task: 'upload', authToken: env.HAB_AUTH_TOKEN, lastBuildFile: "${workspace}/results/last_build.env", bldrUrl: "${env.HAB_BLDR_URL}"
                }
            }
        }
        stage('promote-to-dev') {
            steps {
                script {
                    env.HAB_PKG = sh (
                        script: "ls -t ${workspace}/results | grep hart | head -n 1 | sed 's/-x86_64-linux.hart//' | cut -d '-' -f 2-20 | sed 's/\\(.*\\)-/\\1\\//' | sed 's/\\(.*\\)-/\\1\\//'",
                        returnStdout: true
                        ).trim()
                }
                withCredentials([string(credentialsId: 'hab-depot-token', variable: 'HAB_AUTH_TOKEN')]) {
                  habitat task: 'promote', channel: "canary", authToken: "${env.HAB_AUTH_TOKEN}", artifact: "${env.HAB_ORIGIN}/${env.HAB_PKG}", bldrUrl: "${env.HAB_BLDR_URL}"
                }
                script('check-deployment-status'){
                   sh '/usr/local/deployment_status.sh' 
                }
            }
        }
        stage('dev-health-check') {
            steps {
                script {
                    np_health=`curl -s np-peer-dev.chef-demo.com:9631/services/national-parks/prod/health | jq .status`
                    if [ "$np_health" = "\"OK\"" ]; then
                        echo "The app is healthy!"
                        exit 0
                    else
                        echo "Something is horribly wrong! The health check returned ${np_health}"
                        exit 1
                    fi    
                }
            }
        }
        stage('deployment-status') {
            steps {
                sh '/usr/local/deployment_status.sh'
            }
        }
    }
}
