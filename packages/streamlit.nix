{
  streamlit,
  stdenv,
}:
stdenv.mkDerivation {
  name = "sample-streamlit-app";
  src = ./src;
  buildInputs = [ streamlit ];
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share

    cat <<EOF >$out/bin/runme
      streamlit run $out/share/streamlit_app.py
    EOF

    chmod +x $out/bin/runme

    cp -R $src/* $out/share
  '';
  meta.mainProgram = "runme";
}
