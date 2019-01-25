FROM 292075781285.dkr.ecr.us-east-1.amazonaws.com/indra_deps:latest

ARG BUILD_BRANCH

ENV DIRPATH /sw
WORKDIR $DIRPATH

# Install INDRA and dependencies
RUN git clone --recursive https://github.com/sorgerlab/indra.git && \
    pip list && \
    echo $PYTHONPATH && \
    cd indra && \
    git checkout $BUILD_BRANCH && \
    echo $BUILD_BRANCH && \
    git branch && \
    mkdir /root/.config && \
    mkdir /root/.config/indra && \
    echo "[indra]" > /root/.config/indra/config.ini && \
    pip install python-libsbml flask && \
    pip install -e . && \
    # Download some files useful for testing
    cd $DIRPATH/indra/indra/benchmarks/assembly_eval/batch4 && \
    wget -nv http://sorger.med.harvard.edu/data/bachman/trips_reach_batch4.gz && \
    tar -xf trips_reach_batch4.gz
