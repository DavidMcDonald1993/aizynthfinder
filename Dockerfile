
# use miniconda base image
FROM continuumio/miniconda3

# install any required system dependencies
RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    ca-certificates \
    build-essential \
    cmake \
    wget \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /

# install python dependencies
COPY ./env-users.yml /environment.yml
# COPY ./env-dev.yml /environment.yml
RUN conda env update --name base --file /environment.yml
RUN rm /environment.yml
RUN conda clean --all

# copy python scripts
COPY ./aizynthfinder /aizynthfinder

# copy config (keep fixed, for now)
COPY ./config.yml /config.yml /

# bind mount data

# bind mount smiles.txt
# can also specify single SMILES with --smiles "CCCOC"(SMILES string)
# this option is preferable as it outputs trees.json, which is basically perfect for the server

# bind mount output_dir

# run with command 
# docker run --rm -v $(pwd)/data:/data -v $(pwd)/my_output_dir:/output_dir davidmcdonald93/retrosynthetic_planning:latest --smiles "CCOC"
ENTRYPOINT [ "python", "/aizynthfinder/interfaces/aizynthcli.py", "--config", "config.yml", "--output", "output_dir/output.json" ]