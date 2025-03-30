This repository contains a custom docker image that suits the needs of Machine Learning for Drug Discovery in Python and R. The packets installed are based on my workflow and requirements, therefore, you can adjust them if needed.
The docker image is based on the [Jupyter Docker Stack Data Science Notebook](https://github.com/jupyter/docker-stacks/tree/main/images/datascience-notebook). As can be seen from the Dockerfile, the packets added are:
1. Python: 
    1. ChEMBL Web Resource Client for scraping bioactivity data from the [ChEMBL database](https://www.ebi.ac.uk/chembl/).
    2. [PaDELPy](https://github.com/ecrl/padelpy), a Python wrapper for the PaDEL Descriptor. I use this to calculate the molecular descriptor and fingerprint from SMILES.
    3. [RDKit](https://www.rdkit.org/), a collection of cheminformatics and ML software. It can also be used to generate [descriptors and fingerprints](https://www.rdkit.org/docs/GettingStartedInPython.html#list-of-available-descriptors).
2. R:
    1. Data processing and visualization packets: dplyr, forcats, ggplot2, ggsci (color pallette for ggplot), reader, rstatix, tidyr.
    2. rcdk: interface to the CDK Java framework for cheminformatics.

Regardless these packets are successfully added and the docker image is successfully built please note that the packets might not be tested in a production environment yet.

# Building Docker Image
At the moment, the image has to be built by yourself. The GitHub action is being considered. To build the image, use the following command **after** getting into the repo directory
```
docker buildx bake
```
Please note that you must have docker installed. The build process may take several moments, depending on your Internet speed.
