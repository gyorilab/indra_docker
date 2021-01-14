FROM 292075781285.dkr.ecr.us-east-1.amazonaws.com/indra_deps:latest

ARG BUILD_BRANCH
ARG READING_BRANCH

ENV DIRPATH /sw
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
WORKDIR $DIRPATH
ADD mti_jars.zip $DIRPATH

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
    # Install new dependencies before they are added to deps docker
    pip uninstall -y enum34 && \
    pip install obonet flask_restx flask_cors docstring-parser && \
    pip install pybel==0.15.0 && \
    # Pre-build the bio ontology
    python -m indra.ontology.bio build && \
    # Download Adeft models
    python -m adeft.download && \
    # Download some files useful for testing
    cd $DIRPATH/indra/indra/benchmarks/assembly_eval/batch4 && \
    wget -nv http://sorger.med.harvard.edu/data/bachman/trips_reach_batch4.gz && \
    tar -xf trips_reach_batch4.gz && \
    apt-get install zip unzip && \
    mkdir $DIRPATH/mti_jars && \
    unzip $DIRPATH/mti_jars.zip -d $DIRPATH/mti_jars/

# Install indra_reading
RUN git clone https://github.com/indralab/indra_reading.git && \
    cd indra_reading && \
    git checkout $READING_BRANCH && \
    echo $READING_BRANCH && \
    pip install -e .

# Install indra_wm_service
RUN git clone https://github.com/indralab/indra_wm_service.git
