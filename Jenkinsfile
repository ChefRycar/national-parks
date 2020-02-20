pipeline {
    agent any
    environment {
        HAB_NOCOLORING = false
        HAB_BLDR_URL = 'https://bldr.habitat.sh/'
        HAB_ORIGIN = 'nrycar'
    }
    stages {
        stage('Clone from GitHub') {
            steps {
                git url: 'https://github.com/ChefRycar/national-parks.git', branch: 'master'
            }
        }
        stage('Build Chef Habitat Artifact') {
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
        stage('Upload to unstable channel on bldr.habitat.sh') {
            steps {
                withCredentials([string(credentialsId: 'hab-depot-token', variable: 'HAB_AUTH_TOKEN')]) {
                    habitat task: 'upload', authToken: env.HAB_AUTH_TOKEN, lastBuildFile: "${workspace}/results/last_build.env", bldrUrl: "${env.HAB_BLDR_URL}"
                }
            }
        }

        stage('Wait for Deploy to Dev') {
            steps {
                sh '/usr/local/bin/deployment_status.sh national-parks np dev unstable' 
            }
        }
        stage('Check Dev Health') {
            steps {
                sh '/usr/local/bin/health_check.sh national-parks np dev'
            }
        }
        stage('Promote to blue Channel') {
            input {
                message "Ready to promote to prod?"
                ok "Sure am!"
            }
            steps {
                script {
                    env.HAB_PKG = sh (
                        script: "curl -s https://bldr.habitat.sh/v1/depot/channels/nrycar/unstable/pkgs/national-parks/latest\\?target\\=x86_64-linux | jq '(.ident.name + \"/\" + .ident.version + \"/\" + .ident.release)'",
                        returnStdout: true
                        ).trim()
                }
                withCredentials([string(credentialsId: 'hab-depot-token', variable: 'HAB_AUTH_TOKEN')]) {
                  habitat task: 'promote', channel: "prod-blue", authToken: "${env.HAB_AUTH_TOKEN}", artifact: "${env.HAB_ORIGIN}/${env.HAB_PKG}", bldrUrl: "${env.HAB_BLDR_URL}"
                }
            }
        }
        stage('Wait for Deploy to Blue') {
            steps {
                sh '/usr/local/bin/deployment_status.sh national-parks np prod prod-blue' 
            }
        }
        stage('Check Prod-Blue Health') {
            steps {
                sh '/usr/local/bin/health_check.sh national-parks np prod prod-blue'
            }
        }
        stage('Promote to green Channel') {
            input {
                message "Is prod-blue looking healthy?"
                ok "Sure is!"
            }
            steps {
                script {
                    env.HAB_PKG = sh (
                        script: "curl -s https://bldr.habitat.sh/v1/depot/channels/nrycar/prod-blue/pkgs/national-parks/latest\\?target\\=x86_64-linux | jq '(.ident.name + \"/\" + .ident.version + \"/\" + .ident.release)'",
                        returnStdout: true
                        ).trim()
                }
                withCredentials([string(credentialsId: 'hab-depot-token', variable: 'HAB_AUTH_TOKEN')]) {
                  habitat task: 'promote', channel: "prod-green", authToken: "${env.HAB_AUTH_TOKEN}", artifact: "${env.HAB_ORIGIN}/${env.HAB_PKG}", bldrUrl: "${env.HAB_BLDR_URL}"
                }
            }
        }        
    }
}
