{ pkgs, ... }: let
  codecontests_dataset = pkgs.fetchzip {
    url       = "https://huggingface.co/datasets/talrid/CodeContests_valid_and_test_AlphaCodium/resolve/main/codecontests_valid_and_test_processed_alpha_codium.zip";
    hash      = "sha256-KHFeXdRGQxaNjNq//liudz2bybnmXIlD0bwsN1oLiFw=";
    stripRoot = false;
  };
in {
  packages = with pkgs; [
    gcc
    stdenv.cc.cc.lib
    sqlite
    readline
    zlib
    openssl
  ];

  # define your own secret key in `devenv.local.nix`
  # env.OPENAI_API_KEY = "secret key";

  enterShell = ''
    ln -f -s ${codecontests_dataset}/valid_and_test_processed datasets/.

    echo "[openai]
      key = \"$OPENAI_API_KEY\"

    [code_contests_tester]
      path_to_python_bin = \"$VIRTUAL_ENV/bin/python\"
      path_to_python_lib = [\"$VIRTUAL_ENV/lib/python3.11/\"]
    " > ./alpha_codium/settings/.secrets.toml
  '';

  languages.python = {
    enable = true;
    venv = {
      enable = true;
      requirements = builtins.readFile ./requirements.txt;
    };
  };

  scripts = {
    solve-problem.exec = "python -m alpha_codium.solve_problem";
    solve-example-problem.exec = ''
      solve-problem \
        --dataset_name valid_and_test_processed \
        --split_name test \
        --problem_number 0
    '';
  };
}
