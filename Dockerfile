FROM ubuntu:latest

# The add-apt-repository command depends on software-properties-common
# and python-software-properties; these require apt-get update to be called first
# http://lifeonubuntu.com/ubuntu-missing-add-apt-repository-command/
RUN apt-get update && \
    apt-get install -y software-properties-common python-software-properties debconf-utils && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && \
    apt-get install -y git wget bzip2

# Set environment variables
ENV DIRPATH /sw
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV BNGPATH=$DIRPATH/BioNetGen-2.2.6-stable
ENV PATH="$DIRPATH/miniconda/bin:$PATH"

WORKDIR $DIRPATH
# Install packages via miniconda
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    chmod +x miniconda.sh && \
    bash miniconda.sh -b -p $DIRPATH/miniconda && \
    conda update -y conda && \
    conda install -y -c omnia python="3.6" qt numpy scipy sympy cython nose \
                                           lxml matplotlib networkx pygraphviz && \
    echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | \
                                               debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    update-java-alternatives -s java-8-oracle && \
    apt-get install -y oracle-java8-set-default && \
    pip install --upgrade pip && \
    pip install jsonschema coverage python-coveralls boto3 pandas doctest-ignore-unicode && \
    # PySB and dependencies
    wget "http://www.csb.pitt.edu/Faculty/Faeder/?smd_process_download=1&download_id=142" \
                                            -O BioNetGen-2.2.6-stable.tar.gz && \
    tar xzf BioNetGen-2.2.6-stable.tar.gz && \
    pip install git+https://github.com/pysb/pysb.git && \
    # Install SBT
    # http://stackoverflow.com/questions/13711395/install-sbt-on-ubuntu
    # (Note that the instructions at
    # http://www.scala-sbt.org/release/docs/Installing-sbt-on-Linux.html
    # did not work)
    wget http://apt.typesafe.com/repo-deb-build-0002.deb && \
    dpkg -i repo-deb-build-0002.deb && \
    apt-get update && \
    apt-get install -y sbt && \
    # Fix error with missing sbt launcher
    # http://stackoverflow.com/questions/36234193/cannot-build-sbt-project-due-to-launcher-version
    wget http://dl.bintray.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.13/sbt-launch.jar -P /root/.sbt/.lib/0.13.13


# Get and build the latest REACH
RUN git clone https://github.com/clulab/reach.git
WORKDIR $DIRPATH/reach
RUN git checkout b4a28418c65e6ea4c && \
    sbt compile

WORKDIR $DIRPATH

RUN pip install git+https://github.com/sorgerlab/indra



