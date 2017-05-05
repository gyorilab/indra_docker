FROM ubuntu:latest

# The add-apt-repository command depends on software-properties-common
# and python-software-properties; these require apt-get update to be called first
# http://lifeonubuntu.com/ubuntu-missing-add-apt-repository-command/
RUN apt-get update && \
    apt-get install -y software-properties-common python-software-properties debconf-utils && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && \
    # jnius-indra requires cython which requires gcc
    apt-get install -y git wget bzip2 gcc && \
    # Dependencies required by Conda
    # See https://github.com/conda/conda/issues/1051
    apt-get install -y libsm6 libxrender1 libfontconfig1 && \
    # To address problem with gcc
    # # http://stackoverflow.com/questions/11912878/gcc-error-gcc-error-trying-to-exec-cc1-execvp-no-such-file-or-directory
    apt-get install -y --reinstall build-essential

# Set environment variables
ENV DIRPATH /sw
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV BNGPATH=$DIRPATH/BioNetGen-2.2.6-stable
ENV PATH="$DIRPATH/miniconda/bin:$PATH"
ENV KAPPAPATH=$DIRPATH/KaSim
# Default character encoding for Java in Docker is not UTF-8, which
# leads to problems with REACH; so we set option
# See https://github.com/docker-library/openjdk/issues/32
ENV JAVA_TOOL_OPTIONS -Dfile.encoding=UTF8
# These are used by INDRA when running REACH
ENV REACH_JAR_PATH=$DIRPATH/reach/target/scala-2.11/reach-gordo-1.3.3-SNAPSHOT.jar
ENV REACH_VERSION=1.3.3-b4a284

WORKDIR $DIRPATH

# Install Java
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | \
                                               debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    update-java-alternatives -s java-8-oracle && \
    apt-get install -y oracle-java8-set-default && \
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
    wget http://dl.bintray.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.13/sbt-launch.jar -P /root/.sbt/.lib/0.13.13 && \
    # Get and build the latest REACH
    git clone https://github.com/clulab/reach.git && \
    cd reach && \
    git checkout b4a28418c65e6ea4c && \
    echo 'mainClass in assembly := Some("org.clulab.reach.RunReachCLI")' >> build.sbt && \
    sbt assembly && \
    cd ../ && \
    # Install packages via miniconda
    apt-get install python && \
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    chmod +x miniconda.sh && \
    bash miniconda.sh -b -p $DIRPATH/miniconda && \
    conda update -y conda && \
    # For the time being qt needs to be set to version 4, and matplotlib to 1.5
    # See https://github.com/ContinuumIO/anaconda-issues/issues/1068
    conda install -y -c omnia python="3.5.2" qt=4 numpy scipy sympy cython nose \
                                           lxml matplotlib=1.5.0 networkx pygraphviz && \
    pip install --upgrade pip && \
    pip install jsonschema coverage python-coveralls boto3 pandas doctest-ignore-unicode \
                jnius-indra && \
    # PySB and dependencies
    wget "http://www.csb.pitt.edu/Faculty/Faeder/?smd_process_download=1&download_id=142" \
                                            -O BioNetGen-2.2.6-stable.tar.gz && \
    tar xzf BioNetGen-2.2.6-stable.tar.gz && \
    pip install git+https://github.com/pysb/pysb.git && \
    # Install Kappa (m4 macro library is required)
    apt-get install -y ocaml-nox opam m4 && \
    # First install ocamlfind via opam (needed to build KaSim/KaSa)
    opam init -a git://github.com/ocaml/opam-repository && eval $(opam config env) && \
    opam install ocamlfind --yes && \
    # Install KaSim/KaSa
    git clone https://github.com/Kappa-Dev/KaSim.git && \
    cd KaSim && \
    git checkout f87eada && \
    make all && \
    cd ../ && \
    # Install INDRA and dependencies
    git clone --recursive https://github.com/johnbachman/indra.git && \
    cd indra && \
    git checkout origin/aws_batch && \
    git submodule update --remote && \
    pip install -e . && \
    # Download some files useful for testing
    cd $DIRPATH/indra/indra/benchmarks/assembly_eval/batch4 && \
    wget http://sorger.med.harvard.edu/data/bachman/trips_reach_batch4.gz && \
    tar -xf trips_reach_batch4.gz

WORKDIR $DIRPATH

