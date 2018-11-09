pipeline {
    agent {
        docker {
            image 'bitwalker/alpine-elixir-phoenix:latest'
            alwaysPull true
        }
    }

    stages {
        stage("tests") {
            steps {
                sh "mix do deps.get, deps.compile"
                sh "mix test"
            }
        }
    }
}
