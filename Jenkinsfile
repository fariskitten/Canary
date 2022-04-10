def gitSHA
podTemplate(label: 'jenkins-slave', cloud: 'kubernetes'){
    node('jenkins-slave') {
        stage('Checkout') {
            checkout scm
            script {
              gitSHA = sh(returnStdout: true, script: 'git rev-parse --short HEAD')
            }
        }
        stage('Install') {
            container('python') {
                sh 'pip install -r requirements.txt'
            }
        }
        stage('Test') {
            container('python') {
                sh 'pytest'
            }
        }
        stage('Build') {
            container('docker') {
                sh 'docker login -u iamapikey -p $REGISTRY_TOKEN uk.icr.io'
                sh "export TAG=$gitSHA" + 'docker build -t $IMAGE_REGISTRY/sampleapp:$TAG .'
                sh "export TAG=$gitSHA" + 'docker push $IMAGE_REGISTRY/sampleapp:$TAG'
            }
        }
        stage('Deploy Canary') {
            if { branch 'canary' }
            container('kubectl') {
                sh 'apk update && apk add gettext'
                sh "export TAG=$gitSHA" + 'envsubst < deployment/canary.yaml | kubectl apply -f -'
                sh "export PROD_WEIGHT=95 CANARY_WEIGHT=5" + 'envsubst < deployment/istio.yaml | kubectl apply -f -'
            }
        }
        stage('Deploy Production') {
            if { branch 'master' }
            container('kubectl') {
                sh 'apk update && apk add gettext'
                sh "export TAG=$gitSHA" + 'envsubst < deployment/app.yaml | kubectl apply -f -'
                sh "export PROD_WEIGHT=100 CANARY_WEIGHT=0" + 'envsubst < deployment/istio.yaml | kubectl apply -f -'
            }
        }
    }
}
