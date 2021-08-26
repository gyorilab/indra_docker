FROM 292075781285.dkr.ecr.us-east-1.amazonaws.com/indra_deps:latest

ARG BUILD_BRANCH
ARG READING_BRANCH

WORKDIR $DIRPATH

# Install INDRA and dependencies
RUN git clone https://github.com/sorgerlab/indra.git && \
    pip list && \
    echo $PYTHONPATH && \
    cd indra && \
    git checkout $BUILD_BRANCH && \
    echo $BUILD_BRANCH && \
    git branch && \
    mkdir /root/.config && \
    mkdir /root/.config/indra && \
    echo "[indra]" > /root/.config/indra/config.ini && \
    pip install -e . && \
    # Pre-build the bio ontology
    python -m indra.ontology.bio build && \
    # Download Adeft models
    python -m adeft.download

# Install indra_reading
RUN git clone https://github.com/indralab/indra_reading.git && \
    cd indra_reading && \
    git checkout $READING_BRANCH && \
    echo $READING_BRANCH && \
    pip install -e .
