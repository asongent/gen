
FROM semaphoreui/semaphore:v2.9.37
USER root
RUN apk add --no-cache wget unzip bash
ENV TERRAFORM_VERSION=1.13.1
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
USER semaphore