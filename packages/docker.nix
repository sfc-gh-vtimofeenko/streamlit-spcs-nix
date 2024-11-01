{
  dockerTools,
  lib,
  app-source,
  streamlit-runtime,
}:
dockerTools.buildLayeredImage {
  name = "streamlit-spcs-scratch";
  tag = "latest";

  contents = [ ];

  config = {
    Entrypoint = lib.pipe streamlit-runtime [
      lib.getExe
      lib.singleton
    ];
    Cmd = [
      "-m"
      "streamlit"
      "run"
      "${app-source}/share/src/streamlit_app.py"
    ];
    ExposedPorts = {
      "8501/tcp" = { };
    };
  };
}
