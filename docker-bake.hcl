group "default" {
    targets = ["datascience-mldd"]
}

target "foundation" {
    context = "https://github.com/jupyter/docker-stacks.git#main:images/docker-stacks-foundation"
    args = {
        PYTHON_VERSION = "3.12"
    }
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

target "pytorch-notebook" {
    context = "https://github.com/jupyter/docker-stacks.git#main:images/pytorch-notebook/cuda12"
    contexts = {
        scipy-notebook = "target:scipy-notebook"
    }
    args = {
        BASE_IMAGE = "scipy-notebook"
    }
    tags = ["datascience-notebook"]
}

target "datascience-mldd" {
    context = "."
    contexts = {
        pytorch-notebook = "target:pytorch-notebook"
    }
    args = {
        BASE_IMAGE = "pytorch-notebook"
    }
    tags = ["datascience-mldd:cuda12"]
}
