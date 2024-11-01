FROM nixos/nix:latest AS builder
COPY . /tmp/build
WORKDIR /tmp/build

# Build the package
RUN nix \
    --extra-experimental-features "nix-command flakes" \
    --option filter-syscalls false \
    build .#streamlit-runtime

RUN mkdir -p /tmp/nix-store-closure
# Copy the closure
RUN cp -R $(nix-store -qR result/) /tmp/nix-store-closure

# Final image is based on scratch. We copy a bunch of Nix dependencies
# but they're fully self-contained so we don't need Nix anymore.
FROM scratch AS app-build

WORKDIR /app

# Copy /nix/store
COPY --from=builder /tmp/nix-store-closure /nix/store
COPY --from=builder /tmp/build/result /app
COPY /src /app
