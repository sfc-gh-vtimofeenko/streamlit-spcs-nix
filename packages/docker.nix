{
  dockerTools,
  self-streamlit,
  lib,
  buildEnv,
  streamlit,
}:
dockerTools.buildImage {
  name = "streamlit-spcs-scratch";
  tag = "latest";
  copyToRoot = buildEnv {
    name = "image-root";
    paths = [ self-streamlit streamlit ];

  };

  config = {
    Cmd = lib.pipe self-streamlit [
      lib.getExe
      lib.singleton
    ];
    ExposedPorts = {
      "8501/tcp" = { };
    };
  };
}
