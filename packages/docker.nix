{
  dockerTools,
  self-streamlit,
  lib,
  buildEnv,
  streamlit,
}:
dockerTools.buildLayeredImage {
  name = "streamlit-spcs-scratch";
  tag = "latest";

  contents = [
    self-streamlit
  ];

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
