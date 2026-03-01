FROM jmugu/jupyterhub-k8s-singleuser-sample:4.3.4
# Install system dependencies (optional but useful)
# RUN apt-get update && apt-get install -y --no-install-recommends 
# \
#     ca-certificates \
#     && rm -rf /var/lib/apt/lists/*

WORKDIR /home/jovyan

# Install Python dependencies
COPY requirements.txt .
USER root
# RUN /bin/sh -c apt-get update
RUN pip install --no-cache-dir -r requirements.txt
USER jovyan