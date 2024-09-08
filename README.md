# fun_ds

[![CI](https://github.com/Quantco/fun_ds/actions/workflows/ci.yml/badge.svg)](https://github.com/Quantco/fun_ds/actions/workflows/ci.yml)
[![Documentation](https://img.shields.io/badge/docs-latest-success?style=plastic)](https://docs.dev.quantco.cloud/qc-github-artifacts/Quantco/fun_ds/latest/index.html)

Course material for Fundamentals of Data Science (Michaelmas 2024) at University of Cambridge

## Installation

You can install the package in development mode using:

```bash
git clone git@github.com:cambridge-FDS/fun_ds.git
cd fun_ds

# create and activate a fresh environment named fun_ds
# see environment.yml for details
mamba env create
conda activate fun_ds

pre-commit install
pip install --no-build-isolation -e .
```
