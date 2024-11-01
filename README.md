This repo contains a very simple Streamilt application that shows how
`st.file_uploader` can be used in Snowpark container services.

The code uploads the file and stores it in binary format in a table, then calls
an image recognition function `image_recognition_using_bytes` to identify what's
on the image. The source for image_recognition_using_bytes is available in [this
quickstart][1].

# Building the image

## (Portable way) plain docker

The [`Dockerfile`](./Dockerfile) file provides a simple way to build a full python
environment for running Streamlit.

Pros:

- Fast to build
- Readable

Cons:

- Non-deterministic
- Fairly large image (~2G)

## (Reproducible way) docker+nix

The `Dockerfile-nix` uses a multi-stage build to build a reproducible
environment that pins all dependencies. There is no need to have nix installed –
it will be pulled during intermediate build.

Pros:

- Deterministic
- Smaller size of final image (~1G)

Cons:
- More space required during the building
- Requires editing nix code if one wants to extend this image
- Slower to build

## (Reproducible way, potentially without docker) nix

Use nix to produce docker archive; load it and push it:

```shell
export REPOSITORY_URL="<urlOfImageRepo>"
nix build .#packages.x86_64-linux.default
snow spcs image-registry login
docker load < ./result && docker tag streamlit-spcs-scratch:latest "$REPOSITORY_URL/streamlit-spcs-scratch:latest" && docker push "$REPOSITORY_URL/streamlit-spcs-scratch:latest"
```

`docker load ...` line can be replaced with your tool of choice (`podman`/`skopeo`) that works with docker archives

# Creating a service

1. Follow [common setup for SPCS][2]
2. [Build and push the image][3]. See the corresponding section on different
   ways to build the image. Make sure architecture is specified as linux/amd64
3. Create the service:

    ```sql
    CREATE SERVICE <srvName>
    IN COMPUTE POOL <poolName>
    FROM SPECIFICATION
    $$
    ---
    spec:
      containers:
      - name: "main"
        image: "<imageTag>"
        resources:
          requests:
            memory: "0.5Gi"
            cpu: "0.5"
      endpoints:
      - name: "main"
        port: 8501
        public: true
    $$;
    ```
4. Open the endpoint from `SHOW ENDPOINTS IN SERVICE <srvName>`

[1]: https://quickstarts.snowflake.com/guide/image_recognition_snowpark_pytorch_streamlit_openai/index.html?index=..%2F..index#0
[2]: https://docs.snowflake.com/en/developer-guide/snowpark-container-services/tutorials/common-setup
[3]: https://docs.snowflake.com/en/developer-guide/snowpark-container-services/tutorials/tutorial-1#build-an-image-and-upload
