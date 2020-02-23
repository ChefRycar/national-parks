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
        stage('Upload to bldr.habitat.sh') {
            steps {
                withCredentials([string(credentialsId: 'hab-depot-token', variable: 'HAB_AUTH_TOKEN')]) {
                    habitat task: 'upload', authToken: env.HAB_AUTH_TOKEN, lastBuildFile: "${workspace}/results/last_build.env", bldrUrl: "${env.HAB_BLDR_URL}"
                }
            }
        }
        stage('Promote to dev Channel') {
            steps {
                script {
                    env.HAB_PKG = sh (
                        script: "curl -s https://bldr.habitat.sh/v1/depot/channels/nrycar/unstable/pkgs/national-parks/latest\\?target\\=x86_64-linux | jq '(.ident.name + \"/\" + .ident.version + \"/\" + .ident.release)'",
                        returnStdout: true
                        ).trim()
                }
                withCredentials([string(credentialsId: 'hab-depot-token', variable: 'HAB_AUTH_TOKEN')]) {
                  habitat task: 'promote', channel: "dev", authToken: "${env.HAB_AUTH_TOKEN}", artifact: "${env.HAB_ORIGIN}/${env.HAB_PKG}", bldrUrl: "${env.HAB_BLDR_URL}"
                }
            }
        }

        stage('Wait for Deploy to Dev') {
            steps {
                sh '/usr/local/bin/deployment_status.sh national-parks np dev dev' 
            }
        }
        stage('Check Dev Health') {
            steps {
                sh '/usr/local/bin/health_check.sh national-parks np dev dev'
            }
        }
        stage('Remove prod-blue from LB') {
            input {
                message "Ready to promote to prod?"
                ok "Sure am!"
            }
            steps {
                withCredentials([string(credentialsId: 'hab-ctl-secret', variable: 'HAB_CTL_SECRET')]) {
                    sh 'hab config apply --remote-sup np-peer-prod.chef-demo.com:9632 national-parks.prod-blue $(date +%s) deployment_start.toml'
                } 
            }
        }
        stage('Promote to blue Channel') {
            steps {
                script {
                    env.HAB_PKG = sh (
                        script: "curl -s https://bldr.habitat.sh/v1/depot/channels/nrycar/dev/pkgs/national-parks/latest\\?target\\=x86_64-linux | jq '(.ident.name + \"/\" + .ident.version + \"/\" + .ident.release)'",
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
                sh 'sleep 5'
            }
        }
        stage('Check Prod-Blue Health') {
            steps {
                sh '/usr/local/bin/health_check.sh national-parks np prod prod-blue'
            }
        }
        stage('Add blue & remove green from the LB') {
            input {
                message "Is prod-blue looking healthy?"
                ok "Sure is!"
            }
            steps {
                withCredentials([string(credentialsId: 'hab-ctl-secret', variable: 'HAB_CTL_SECRET')]) {
                    sh 'hab config apply --remote-sup np-peer-prod.chef-demo.com:9632 national-parks.prod-blue $(date +%s) deployment_stop.toml'
                    sh 'sleep 5'
                    sh 'hab config apply --remote-sup np-peer-prod.chef-demo.com:9632 national-parks.prod-green $(date +%s) deployment_start.toml'
                }
            }
        }
        stage('Promote to green Channel') {
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
        stage('Wait for Deploy to Green') {
            steps {
                sh '/usr/local/bin/deployment_status.sh national-parks np prod prod-green' 
                sh 'sleep 5'
            }
        }
        stage('Check Prod-Green Health') {
            steps {
                sh '/usr/local/bin/health_check.sh national-parks np prod prod-green'
            }
        }
        stage('Add green back to LB') {
            input {
                message "Finish deployment?"
                ok "You bet!"
            }
            steps {
                withCredentials([string(credentialsId: 'hab-ctl-secret', variable: 'HAB_CTL_SECRET')]) {
                    sh 'hab config apply --remote-sup np-peer-prod.chef-demo.com:9632 national-parks.prod-green $(date +%s) deployment_stop.toml'
                } 
            }
        }
        stage('Promte to Stable') {
            steps {
                script {
                    env.HAB_PKG = sh (
                        script: "curl -s https://bldr.habitat.sh/v1/depot/channels/nrycar/prod-green/pkgs/national-parks/latest\\?target\\=x86_64-linux | jq '(.ident.name + \"/\" + .ident.version + \"/\" + .ident.release)'",
                        returnStdout: true
                        ).trim()
                }
                withCredentials([string(credentialsId: 'hab-depot-token', variable: 'HAB_AUTH_TOKEN')]) {
                  habitat task: 'promote', channel: "stable", authToken: "${env.HAB_AUTH_TOKEN}", artifact: "${env.HAB_ORIGIN}/${env.HAB_PKG}", bldrUrl: "${env.HAB_BLDR_URL}"
                }
            }
        }
    }
}
