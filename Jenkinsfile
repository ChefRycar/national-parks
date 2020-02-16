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
            }
        }
        stage('test-dev') {
            steps {
                script {
                    def latest_version=$(curl -s https://bldr.habitat.sh/v1/depot/channels/nrycar/stable/pkgs/national-parks/latest\?target\=x86_64-linux | jq -r '.ident | .release')
                    def running_version=$(curl -s http://np-peer-dev.chef-demo.com:9631/census | jq -r '[.census_groups."national-parks.default".population[].pkg][0] | .release')
                    while [ "$latest_version" != "$running_version" ]
                    do
                        echo "Waiting for deploy to complete..."
                        sleep 5
                        echo ". . . . . . . . ."
                        latest_version=$(curl -s https://bldr.habitat.sh/v1/depot/channels/nrycar/stable/pkgs/national-parks/latest\?target\=x86_64-linux | jq -r '.ident | .release')
                        running_version=$(curl -s http://np-peer-dev.chef-demo.com:9631/census | jq -r '[.census_groups."national-parks.default".population[].pkg][0] | .release')
                    done
                    echo "...deploy complete"
                }
            }
        }
    }
}
