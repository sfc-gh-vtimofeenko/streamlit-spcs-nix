{
  writeShellApplication,
  python3,
  fetchPypi,
}:
writeShellApplication {
  name = "runme";
  runtimeInputs = [
    (python3.withPackages (ps: [
      ps.streamlit
      ps.snowflake-connector-python

      (python3.pkgs.buildPythonPackage rec {
        pname = "snowflake-snowpark-python";
        version = "1.23.0";
        src = fetchPypi {
          inherit  version;
          pname = "snowflake_snowpark_python";
          hash = "sha256-R/ZJrTpzmd3TvHFPpC2YRc7L0mADkyDEBuVHG+szSjU=";
        };
        build-system = [
          python3.pkgs.setuptools
        ];
        propagatedBuildInputs = [
          ps.snowflake-connector-python
          ps.pyyaml
          ps.cloudpickle
          ps.pip
          ps.setuptools
        ];

        doCheck = false; # Poor man's relaxdepshook

      })
    ]))
  ];
  text = ''
    python -m streamlit run ${./src}/streamlit_app.py
  '';
}
