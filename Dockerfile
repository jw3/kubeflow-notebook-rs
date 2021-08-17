FROM public.ecr.aws/j1r0q0g6/notebooks/notebook-servers/jupyter:master-ebc0c4f0

USER 0

RUN apt update \
 && apt install -y curl build-essential

WORKDIR /tmp

RUN curl -o conda.sh -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
 && bash conda.sh -p /opt/miniconda -b \
 && rm conda.sh

ENV PATH=/opt/miniconda/bin:${PATH}

RUN conda init bash \
 && conda update -y conda \
 && conda install -c anaconda cmake -y \
 && conda install -y -c conda-forge nb_conda_kernels jupyterlab=3.1.7

RUN mkdir -p /opt/notebooks /opt/miniconda/share/jupyter/lab/extensions \
 && chown jovyan:users /opt/notebooks /opt/miniconda/share/jupyter/lab

USER jovyan

RUN curl -o rust.sh https://sh.rustup.rs -sSf \
 && bash rust.sh -y -q --profile minimal \
 && rm rust.sh

WORKDIR /home/jovyan

ENV PATH=$HOME/.cargo/bin:${PATH}

RUN rustup component add rust-src
RUN cargo install evcxr_jupyter
RUN evcxr_jupyter --install

EXPOSE 8888

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--notebook-dir=/opt/notebooks", "--allow-root", "--no-browser"]
