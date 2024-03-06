# Nixvim with molten/quarto

In bash,

```sh
# Active nix shell (to get access to python)
nix-shell shell.nix

# Create a venv
python -m venv myvenv

# Install jupyter/jupytext dependencies
python -m pip install -r requirements.txt

# create a kernel
ipykernel install --prefix=./myvenv --name 'myvenv'

# try nixvim
nix run .# -- test.qmd
```

Then in nvim

1. (On first usage) `:UpdateRemotePlugins` 
2. `:MoltenInit`
3. `:MoltenInfo` 
4. `:MoltenEvaluateLine` 
