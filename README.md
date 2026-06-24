# Fundamentals of Data Science

Course material for **Fundamentals of Data Science** — MPhil in Economics and Data Science, University of Cambridge.

## Quick Start

```bash
git clone git@github.com:cambridge-FDS/fun_ds.git
cd fun_ds

# Install dependencies and the package
pixi install
pixi run install

# Build the online book
pixi run docs-build
pixi run docs-start
```

## Development

```bash
pixi run test         # run tests
pixi run check        # lint with ruff
pixi run format       # auto-format
pixi run lint         # run all pre-commit hooks
```

## License

This material is licensed under [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/).
