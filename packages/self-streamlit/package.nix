{
  streamlit,
  writeShellApplication,
}:
writeShellApplication {
  name = "runme";
  runtimeInputs = [ streamlit ];
  text = ''
    streamlit run ${./src}/streamlit_app.py
  '';
}
