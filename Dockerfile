FROM 292075781285.dkr.ecr.us-east-1.amazonaws.com/indra_deps:latest

ENV DIRPATH /sw
WORKDIR $DIRPATH

# Install INDRA and dependencies
RUN git clone --recursive https://github.com/sorgerlab/indra.git && \
    cd indra && \
    git checkout fix_old_reading_system && \
    git submodule update --remote && \
    pip install -e . && \
    # Download some files useful for testing
    cd $DIRPATH/indra/indra/benchmarks/assembly_eval/batch4 && \
    wget http://sorger.med.harvard.edu/data/bachman/trips_reach_batch4.gz && \
    tar -xf trips_reach_batch4.gz


