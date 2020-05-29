FROM docker:stable as static-docker-source

FROM python:3.8-slim

#####################################################################

ARG WORKDIR=/opt/apps
WORKDIR ${WORKDIR}
RUN mkdir -p ${WORKDIR}/bin
ENV PATH=$PATH:${WORKDIR}/bin

#####################################################################

# Install dep
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qqy && apt-get install -qqy \
    curl \
    git \
    jq \
    unzip

# Install pip
RUN python3 -m ensurepip && \
    pip3 --no-cache-dir install -U pip wheel

# Install Docker
COPY --from=static-docker-source /usr/local/bin/docker ${WORKDIR}/bin/docker

#####################################################################

#### Kubectl ####
ARG KUBECTL_VERSION=1.18.3
# Install kubectl (same version of aws esk)
RUN curl --silent -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    mv kubectl ${WORKDIR}/bin/kubectl && \
    chmod +x ${WORKDIR}/bin/kubectl

#####################################################################

#### Helm ####
ARG HELM_VERSION=3.2.1
# Install helm (latest release)
# ENV BASE_URL="https://storage.googleapis.com/kubernetes-helm"
ENV BASE_URL="https://get.helm.sh"
ENV TAR_FILE="helm-v${HELM_VERSION}-linux-amd64.tar.gz"
RUN curl --silent -L ${BASE_URL}/${TAR_FILE} | tar xvz && \
    mv linux-amd64/helm ${WORKDIR}/bin/helm && \
    chmod +x ${WORKDIR}/bin/helm && \
    rm -rf linux-amd64
RUN helm plugin install https://github.com/databus23/helm-diff --version master

#####################################################################

#### Pulumi ####
ARG PULUMI_VERSION=2.3.0
# Install pulumi
RUN if [ "$PULUMI_VERSION" = "latest" ]; then \
      curl -fsSL https://get.pulumi.com/ | sh; \
    else \
      curl -fsSL https://get.pulumi.com/ | sh -s -- --version $PULUMI_VERSION; \
    fi
ENV PATH=$PATH:/root/.pulumi/bin
# Install pulumi plugins
# RUN pulumi plugin install resource kubernetes 2.2.0
# RUN pulumi plugin install resource random 2.1.1
# RUN pulumi plugin install resource terraform 2.2.0
# RUN pulumi plugin install resource tls 2.1.0

#####################################################################

#### Terraform ####
ARG TERRAFORM_VERSION=0.12.25
RUN curl --silent -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform ${WORKDIR}/bin && \
    chmod +x ${WORKDIR}/bin/terraform && \
    rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip

#####################################################################

#### Tekton ####
ARG TEKTON_VERSION=0.9.0
RUN curl --silent --location "https://github.com/tektoncd/cli/releases/download/v${TEKTON_VERSION}/tkn_${TEKTON_VERSION}_Linux_x86_64.tar.gz" | tar xz -C /tmp && \
    mv /tmp/tkn ${WORKDIR}/bin && \
    chmod +x ${WORKDIR}/bin/tkn

#####################################################################

#### Argo ####
ARG ARGO_VERSION=2.8.1
RUN curl --silent -LO "https://github.com/argoproj/argo/releases/download/v${ARGO_VERSION}/argo-linux-amd64" && \
    mv argo-linux-amd64 ${WORKDIR}/bin/argo && \
    chmod +x ${WORKDIR}/bin/argo

#####################################################################

# Copy Scripts

#####################################################################

WORKDIR /apps

#####################################################################
