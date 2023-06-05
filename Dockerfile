
# use miniconda base image
FROM continuumio/miniconda3 AS build

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
RUN conda env update --name myenv --file /environment.yml
RUN rm /environment.yml
# RUN conda clean --all

# Make RUN commands use the new environment:
SHELL ["conda", "run", "-n", "myenv", "/bin/bash", "-c"]

# Use conda-pack to create a standalone enviornment
# in /venv:
RUN conda-pack -n myenv -o /tmp/env.tar && \
  mkdir /venv && cd /venv && tar xf /tmp/env.tar && \
  rm /tmp/env.tar

# We've put venv in same path it'll be in final image,
# so now fix up paths:
RUN /venv/bin/conda-unpack

# The runtime-stage image; we can use Debian as the
# base image since the Conda env also includes Python
# for us.
FROM debian:buster AS runtime

# Copy /venv from the previous stage:
COPY --from=build /venv /venv

# system dependencies
RUN apt-get update && apt-get install -y libxrender1 libxtst6 libxi6

# copy python scripts
COPY ./aizynthfinder /aizynthfinder

# copy config (keep fixed, for now)
COPY ./config.yml /config.yml /

# bind mount data

# bind mount smiles.txt
# can also specify single SMILES with --smiles "CCCOC"(SMILES string)
# this option is preferable as it outputs trees.json, which is basically perfect for the server

# bind mount output_dir

COPY ./entrypoint.sh /

# run with command 
# docker run --rm -v $(pwd)/data:/data -v $(pwd)/my_output_dir:/output_dir davidmcdonald93/retrosynthetic_planning:latest --smiles "CCOC"
# ENTRYPOINT [ "python", "/aizynthfinder/interfaces/aizynthcli.py", "--config", "config.yml", "--output", "output_dir/output.json" ]
SHELL ["/bin/bash", "-c"]
# ENTRYPOINT source /venv/bin/activate && \
#            python /aizynthfinder/interfaces/aizynthcli.py --smiles smiles.txt --config config.yml --output output/output.json

# TODO: entrypoint in JSON format for extra args
# ENTRYPOINT [ "/bin/bash", "-c", "source /venv/bin/activate", "&&",  "python", "/aizynthfinder/interfaces/aizynthcli.py" ]

# this seems to work if additional args are required
ENTRYPOINT [ "/entrypoint.sh" ]