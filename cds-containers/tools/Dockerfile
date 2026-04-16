ARG BASE_IMAGE="nvcr.io/nvidia/base/ubuntu:22.04_20240212"
FROM ${BASE_IMAGE}
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        build-essential \
        ca-certificates \
        curl \
        git \
        git-lfs \
        gnupg \
        jq \
        lsb-release \
        make \
        python3 \
        python3-pip \
        python3-dev \
        software-properties-common \
        unzip \
    && apt-get autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24 LTS
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get update \
    && apt-get install --no-install-recommends -y nodejs \
    && node --version \
    && npm --version

# Note: nvault is not included as GitHub runners cannot reach internal URM
# For internal GitLab runners, use the GitLab version of this container

# kubectl (latest version: curl -sSL https://dl.k8s.io/release/stable.txt)
ARG KUBECTL_VERSION="1.35.4"
RUN curl -fsSL -o kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && mv ./kubectl  /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && kubectl version --client

# kubelogin
ARG KUBELOGIN_VERSION="0.2.17"
RUN curl -fsSL -o kubelogin.zip "https://github.com/Azure/kubelogin/releases/download/v${KUBELOGIN_VERSION}/kubelogin-linux-amd64.zip" \
    && unzip -j kubelogin.zip \
    && mv kubelogin /usr/local/bin/kubelogin \
    && kubelogin --version

# yq
ARG YQ_VERSION="4.52.5"
RUN curl -fsSL -o yq "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64" \
    && mv ./yq /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq \
    && yq --version

# ngccli
ARG NGCCLI_VERSION="4.17.0"
RUN curl -sSL -O "https://api.ngc.nvidia.com/v2/resources/nvidia/ngc-apps/ngc_cli/versions/${NGCCLI_VERSION}/files/ngccli_linux.zip" \
    && unzip ngccli_linux.zip \
    && rm ngccli_linux.zip \
    && ln -s /ngc-cli/ngc /usr/local/bin/ngc \
    && ngc version info

# NGC CLI - disable trace
# https://nvidia.slack.com/archives/C7VGNG1V3/p1738003396389109
# Transient error StatusCode.DEADLINE_EXCEEDED encountered while exporting traces to prod.otel.kaizen.nvidia.com:8282, retrying in 1s.
ENV NGC_CLI_TRACE_DISABLE=true

# docker
RUN curl -sSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
    && echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        # docker-ce \
        # containerd.io \
        docker-ce-cli \
        docker-buildx-plugin \
        docker-compose-plugin \
    && apt-get autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && docker --version

# regctl
ARG REGCTL_VERSION="0.11.3"
RUN curl -fsSL -o regctl "https://github.com/regclient/regclient/releases/download/v${REGCTL_VERSION}/regctl-linux-amd64" \
    && mv ./regctl /usr/local/bin/regctl \
    && chmod +x /usr/local/bin/regctl \
    && regctl version

# helm
ENV VERIFY_CHECKSUM=true \
    VERIFY_SIGNATURES=false
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash \
    && helm version

# terraform
ARG TERRAFORM_VERSION="1.14.8"
RUN curl -fsSL -o terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip terraform.zip && \
    rm terraform.zip && \
    mv ./terraform /usr/local/bin/terraform \
    && terraform --version

# terragrunt
ARG TERRAGRUNT_VERSION="1.0.1"
RUN curl -fsSL -o terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" \
    && mv ./terragrunt /usr/local/bin/terragrunt \
    && chmod +x /usr/local/bin/terragrunt \
    && terragrunt --version

# bazel - multiple versions for different projects
# Install Bazel 6.5.0 (required for KubeVirt - VMAAS-708, NID-8024)
ARG BAZEL6_VERSION="6.5.0"
RUN curl -fsSL -o bazel6 "https://github.com/bazelbuild/bazel/releases/download/${BAZEL6_VERSION}/bazel-${BAZEL6_VERSION}-linux-x86_64" \
    && mv ./bazel6 /usr/local/bin/bazel-${BAZEL6_VERSION} \
    && chmod +x /usr/local/bin/bazel-${BAZEL6_VERSION} \
    && ln -s /usr/local/bin/bazel-${BAZEL6_VERSION} /usr/local/bin/bazel6 \
    && bazel6 --version

# Install Bazel 8.4.0 (latest stable for other projects)
ARG BAZEL8_VERSION="8.4.0"
RUN curl -fsSL -o bazel8 "https://github.com/bazelbuild/bazel/releases/download/${BAZEL8_VERSION}/bazel-${BAZEL8_VERSION}-linux-x86_64" \
    && mv ./bazel8 /usr/local/bin/bazel-${BAZEL8_VERSION} \
    && chmod +x /usr/local/bin/bazel-${BAZEL8_VERSION} \
    && ln -s /usr/local/bin/bazel-${BAZEL8_VERSION} /usr/local/bin/bazel8 \
    && bazel8 --version

# Default bazel points to version 8 (latest)
RUN ln -s /usr/local/bin/bazel8 /usr/local/bin/bazel \
    && echo "Installed Bazel versions:" \
    && bazel6 --version \
    && bazel8 --version \
    && bazel --version

# uv (latest version: 0.11.7)
COPY --from=ghcr.io/astral-sh/uv:0.11.7 /uv /uvx /usr/local/bin/
RUN uv self version

# Note: CDS CLI is not included as GitHub runners cannot reach internal GitLab
# For internal GitLab runners, use the GitLab version of this container
