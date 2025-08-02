group "default" {
    targets = ["datascience-mldd"]
}

target "foundation" {
    context = "https://github.com/jupyter/docker-stacks.git#main:images/docker-stacks-foundation"
    tags = ["docker-stacks-foundation"]
}

target "base-notebook" {
    context = "https://github.com/jupyter/docker-stacks.git#main:images/base-notebook"
    contexts = {
        docker-stacks-foundation = "target:foundation"
    }
    args = {
        BASE_IMAGE = "docker-stacks-foundation"
    }
    tags = ["base-notebook"]
}

target "minimal-notebook" {
    context = "https://github.com/jupyter/docker-stacks.git#main:images/minimal-notebook"
    contexts = {
        base-notebook = "target:base-notebook"
    }
    args = {
        BASE_IMAGE = "base-notebook"
    }
    tags = ["minimal-notebook"]
}

target "scipy-notebook" {
    context = "https://github.com/jupyter/docker-stacks.git#main:images/scipy-notebook"
    contexts = {
        minimal-notebook = "target:minimal-notebook"
    }
    args = {
        BASE_IMAGE = "minimal-notebook"
    }
    tags = ["scipy-notebook"]
}

target "datascience-mldd" {
    context = "."
    contexts = {
        scipy-notebook = "target:scipy-notebook"
    }
    args = {
        BASE_IMAGE = "scipy-notebook"
    }
    tags = ["datascience-mldd"]
}
