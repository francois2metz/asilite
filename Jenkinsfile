pipeline {
    agent {
        docker 'bitwalker/alpine-elixir-phoenix:latest'
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
