FROM ubuntu:latest

# The add-apt-repository command depends on software-properties-common
# and python-software-properties; these require apt-get update to be called first
# http://lifeonubuntu.com/ubuntu-missing-add-apt-repository-command/
RUN apt-get update && \
    apt-get install -y software-properties-common python-software-properties debconf-utils && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && \
    apt-get install -y git python wget bzip2

ENV DIRPATH /sw
WORKDIR $DIRPATH
# Install packages via miniconda
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    chmod +x miniconda.sh && \
    bash miniconda.sh -b -p $DIRPATH/miniconda && \
    conda update -y conda && \
    conda install -y -c omnia python="3.6" qt numpy scipy sympy cython nose \
                                           lxml matplotlib networkx pygraphviz
# Install Java
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | \
                                                                debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    update-java-alternatives -s java-8-oracle && \
    apt-get install -y oracle-java8-set-default

# Install Python packages
RUN pip install jsonschema coverage python-coveralls boto3 pandas doctest-ignore-unicode
    #pip install pygraphviz --install-option="--include-path=/usr/include/graphviz/" \
    #                       --install-option="--library-path=/usr/lib/graphviz/"

# PySB and dependencies
RUN wget "http://www.csb.pitt.edu/Faculty/Faeder/?smd_process_download=1&download_id=142" \
                                            -O BioNetGen-2.2.6-stable.tar.gz && \
    tar xzf BioNetGen-2.2.6-stable.tar.gz
RUN pip install git+https://github.com/pysb/pysb.git

# Set environment variables
# http://stackoverflow.com/questions/27093612/in-a-dockerfile-how-to-update-path-environment-variable
ENV PATH="$DIRPATH/miniconda/bin:$PATH"
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV BNGPATH=$DIRPATH/BioNetGen-2.2.6-stable


# Get and build the latest REACH?

# Get the latest INDRA master and pip install from git
ENTRYPOINT /bin/bash
