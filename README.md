# Fundamentals of Data Science

Course material for **Fundamentals of Data Science** — MPhil in Economics and Data Science, University of Cambridge.

**Online book:** <https://cambridge-fds.github.io/fun_ds>

## Quick Start

New to git, pixi or VS Code? Follow the step-by-step
[Day 1 Setup](https://cambridge-fds.github.io/fun_ds/quickstart) guide
(source: [`docs/setup/quickstart.md`](docs/setup/quickstart.md)).

```bash
git clone https://github.com/cambridge-FDS/fun_ds.git
cd fun_ds

# Install the environment and the course package
pixi install
pixi run install

# Check everything works
pixi run test
```

Then open the `fun_ds` folder in VS Code, open a notebook in `docs/lectures/`
and select the pixi environment (`.pixi/envs/default`) as the kernel.

## Building the book

```bash
pixi run docs-start   # live preview of the book (does not re-execute notebooks)
pixi run docs-build   # re-execute all notebooks in place + build HTML (slow; what CI runs)
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
