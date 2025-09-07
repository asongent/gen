
FROM semaphoreui/semaphore:v2.9.37
USER root
RUN apk add --no-cache wget unzip bash python3 py3-pip
ENV TERRAFORM_VERSION=1.13.1

RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# ENV AWS_ACCESS_KEY="" \
#     AWS_ACCESS_SECRET_KEY=""
RUN apk update 
RUN apk upgrade 
RUN pip3 install --upgrade pip
RUN pip3 install --no-cache-dir awscli
RUN rm -rf /var/cache/apk/* 
USER semaphore