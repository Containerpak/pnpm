FROM ubuntu:26.04 AS fetch

ARG TARGETARCH
ARG PNPM_VERSION=12.4.1
ARG PNPM_SHA256_AMD64=66e9886299085dade56e203ae0e3586f35787f8801a68d33ec07ac17b0de2001
ARG PNPM_SHA256_ARM64=14f7a3e67d658d4ca8002c2aa0567f27dc5fe056a9f29f98ba7d2bfd6c81591b
ARG PNPM_LICENSE_SHA256=4b8e2a57502758b2d034ece9cabf19dd098c5609003ed8dbdafd085274f25bd9

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    case "$TARGETARCH" in \
        amd64) archive_arch=x64; checksum="$PNPM_SHA256_AMD64" ;; \
        arm64) archive_arch=arm64; checksum="$PNPM_SHA256_ARM64" ;; \
        *) echo "unsupported architecture: $TARGETARCH" >&2; exit 1 ;; \
    esac && \
    archive="pnpm-linux-${archive_arch}.tar.gz" && \
    curl -fsSLo "/tmp/${archive}" "https://github.com/pnpm/pnpm/releases/download/v${PNPM_VERSION}/${archive}" && \
    echo "${checksum}  /tmp/${archive}" | sha256sum -c - && \
    mkdir -p /opt/pnpm /usr/share/licenses/pnpm && \
    tar -xzf "/tmp/${archive}" -C /opt/pnpm && \
    curl -fsSLo /usr/share/licenses/pnpm/LICENSE "https://raw.githubusercontent.com/pnpm/pnpm/v${PNPM_VERSION}/LICENSE" && \
    echo "${PNPM_LICENSE_SHA256}  /usr/share/licenses/pnpm/LICENSE" | sha256sum -c -

FROM ghcr.io/containerpak/sdk-node-lts:main

RUN apt-get update && \
    apt-get install -y --no-install-recommends git libatomic1 openssh-client && \
    mkdir -p /usr/local/libexec && \
    mv /usr/local/bin/node /usr/local/libexec/node-lts && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*.deb /var/cache/apt/*.bin

COPY --from=fetch /opt/pnpm /opt/pnpm
COPY --from=fetch /usr/share/licenses/pnpm /usr/share/licenses/pnpm
COPY pnpm-wrapper /usr/local/bin/pnpm
COPY node-wrapper /usr/local/bin/node

RUN chmod 0755 /usr/local/bin/pnpm /usr/local/bin/node

ENV PATH=/usr/local/bin:${PATH}
