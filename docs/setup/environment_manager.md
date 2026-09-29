# Environments: pixi (and conda)

**Previous:** [Day 1 Setup](quickstart.md) | **Next:** [VS Code](vscode.md)

---

:::{tip}
Just want to get set up? Follow the step-by-step [Day 1 Setup](quickstart.md).
This page explains _why_ we use environments, how pixi works, and how it
relates to the conda workflow shown in the Lecture 1 slides.
:::

## Why use environments at all?

A Python environment is an isolated set of packages plus a specific Python
version, scoped to a single project. Without one, you install everything into
your system Python and quickly hit trouble.

Three forces work against a "just pip install it" workflow:

- **Dependencies rot.** Libraries release breaking changes constantly. A notebook that ran fine six months ago may not import today if `pandas`, `scikit-learn`, or `numpy` have moved on. Pinning versions freezes a working combination in place.
- **Operating systems differ.** macOS (Intel vs. Apple Silicon), Linux, and Windows need different binaries. A package build that works on your laptop may not exist for a classmate's machine unless the environment manager knows how to solve per platform.
- **Hardware differs.** CUDA vs. CPU builds, ARM vs. x86: the same "package" is really a family of builds, and an environment manager picks the right one.

The goal is a **reproducible build**: given the same specification, anyone,
anywhere, at any time gets the same working environment. That is exactly what
you want when a classmate, a marker or your future self needs to rerun your
analysis.

:::{seealso}
For a broader take on why reproducibility, project layout, and automation matter in scientific work, see {cite}`wilson2017good` — "Good Enough Practices in Scientific Computing".
:::

---

## From conda to pixi

The Lecture 1 slides introduce **conda**, the long-standing package and
environment manager of the scientific Python world, and then **pixi** as the
modern alternative. The course repository uses **pixi**. The ideas are the
same; pixi adds two things conda lacks by default:

1. **A lockfile.** `pixi.lock` records the _exact_ version and build of every
   package for every platform. Two students who install a month apart get
   byte-identical environments. A conda `environment.yml` usually lists only
   top-level packages, often without versions, so it drifts over time.
2. **Project-local environments and tasks.** The environment lives inside the
   project folder (`.pixi/`), and `pixi.toml` can define named commands
   (`pixi run test`) that behave the same on every machine.

Both install from the same **conda-forge** package channel, so every package
available to conda is available to pixi.

| You want to…                | conda                                     | pixi (inside the project folder)                |
| --------------------------- | ----------------------------------------- | ----------------------------------------------- |
| Create the environment      | `conda env create -f environment.yml`     | `pixi install`                                  |
| Add a package               | `conda install seaborn` (+ edit the YAML) | `pixi add seaborn` (updates `pixi.toml` + lock) |
| Run one command in it       | `conda activate env` then `python …`      | `pixi run python …`                             |
| Get an interactive shell    | `conda activate env`                      | `pixi shell` (leave with `exit`)                |
| Share the spec              | `environment.yml`                         | `pixi.toml` + `pixi.lock` (commit both)         |
| Where the environment lives | `~/miniconda3/envs/<name>/` (global)      | `<project>/.pixi/envs/default/` (per project)   |

:::{note}
You already know conda and want to keep using it for your _own_ projects? That's
fine. The [micromamba section](#appendix-micromamba) below shows a fast,
conda-compatible tool. For the **course repository**, use pixi: its tasks
(`pixi run install`, `pixi run test`, …) and the lockfile are what keep
everyone's setup identical.
:::

---

## pixi in the course repository

### Install pixi

**macOS / Linux:**

```bash
curl -fsSL https://pixi.sh/install.sh | sh
```

**Windows (PowerShell):**

```powershell
winget install prefix-dev.pixi
# or, without winget:
iwr -useb https://pixi.sh/install.ps1 | iex
```

Open a **new terminal** and check with `pixi --version`. Keep pixi up to date
with `pixi self-update`.

### The two files that define the environment

Open `pixi.toml` in the course repository. Its main parts are:

- `[workspace]`: name, the package channel (`conda-forge`) and the
  **platforms** the lockfile is solved for (macOS Intel and Apple Silicon,
  Linux, Windows).
- `[dependencies]`: the core packages every lecture needs (`pandas`,
  `scikit-learn`, `matplotlib`, …), usually with a minimum version.
- `[feature.<name>.dependencies]`: optional groups of packages. `docs` holds
  the heavier libraries used in later lectures (`polars`, `shap`, `mlflow`, …);
  `test` holds `pytest`; `lint` holds `pre-commit` and `ruff`.
- `[environments]`: which features make up which environment. The `default`
  environment includes **all** features, so it is the only one you need.
- `[tasks]`: named commands (see below).

`pixi.lock` is generated. Never edit it by hand, but do commit it.

### Everyday commands

```bash
pixi install                 # create/update the environment from pixi.lock
pixi run <command>           # run any command inside the environment
pixi shell                   # interactive shell with the environment active (exit to leave)
pixi list                    # what is installed, with exact versions
pixi task list               # which named tasks this project defines
```

To check that a command really uses the environment's Python:

```bash
pixi run python -c "import sys; print(sys.executable)"
```

The path should contain `.pixi/envs/default/`.

### Course tasks

The course `pixi.toml` defines these tasks, which you run with `pixi run <task>`:

| Task         | What it does                                                           |
| ------------ | ---------------------------------------------------------------------- |
| `install`    | Installs the course package `fun_ds` in editable mode (run once)       |
| `test`       | Runs the unit tests in `tests/`                                        |
| `check`      | Lints `src/` and `tests/` with ruff                                    |
| `format`     | Auto-formats `src/` and `tests/` with ruff                             |
| `lint`       | Runs all pre-commit hooks on all files                                 |
| `docs-start` | Serves this book locally with live reload (for editing the book)       |
| `docs-build` | Re-executes every notebook and builds the HTML book (slow, used by CI) |

:::{warning}
`docs-build` (via `docs-execute`) re-runs every lecture notebook **in place** and
overwrites their outputs. That is what CI does. As a student you rarely need it:
run notebooks in VS Code instead.
:::

### Adding a package

Want to try a library that isn't in the environment?

```bash
pixi add <package>                     # e.g. pixi add statsmodels
```

This installs it _and_ records it in `pixi.toml` and `pixi.lock`. In the course
repository that modifies tracked files, so prefer doing it in your own project
repositories. If you need it just for a quick experiment in the course repo,
undo it afterwards with `git restore pixi.toml pixi.lock && pixi install`.

:::{warning}
Don't `pip install` into the pixi environment. pixi doesn't know about packages
installed that way: they vanish or break on the next `pixi install`, and your
classmates won't have them. If a package only exists on PyPI, use
`pixi add --pypi <package>`.
:::

---

## Starting your own pixi project

For problem sets and your project you will set up a repository from scratch.
The pattern:

```bash
mkdir my_project
cd my_project
pixi init                      # creates pixi.toml (and a .gitignore containing .pixi)
pixi add python=3.13 pandas scikit-learn matplotlib ipykernel
pixi add --feature test pytest
pixi install
```

`ipykernel` is what lets VS Code run notebooks with this environment. Don't
leave it out.

A minimal `pixi.toml` with a task might then look like:

```toml
[workspace]
name = "my_project"
channels = ["conda-forge"]
platforms = ["linux-64", "osx-64", "osx-arm64", "win-64"]

[dependencies]
python = "3.13.*"
pandas = ">=2.2"
scikit-learn = ">=1.5"
matplotlib = "*"
ipykernel = "*"

[tasks]
test = "python -m pytest -q"
```

:::{note}
**Version specifiers.** `"*"` means "any version"; `">=2.2"` sets a minimum.
The lockfile pins exact versions either way, but a bare `"*"` gives the solver
freedom to pick a surprisingly _old_ version when some other package holds
things back. **Set a lower bound on anything you depend on seriously.**
:::

Commit `pixi.toml` and `pixi.lock`; never commit the `.pixi/` folder. Check that
`.pixi` is listed in `.gitignore` (`pixi init` adds it).

---

## Appendix: micromamba

**micromamba** is a small, fast, conda-compatible package manager. It is a good
choice if you prefer the classic conda "named environment" workflow for your
own work. It is **not** needed for the course repository.

**Install (macOS / Linux):**

```bash
"${SHELL}" <(curl -L micro.mamba.pm/install.sh)
```

**Install (Windows, PowerShell):**

```powershell
Invoke-Expression ((Invoke-WebRequest -Uri https://micro.mamba.pm/install.ps1 -UseBasicParsing).Content)
```

The installer offers to set up shell integration. Accept it, then open a new
terminal and check `micromamba --version`.

**Typical workflow:**

```bash
micromamba create -n myenv -c conda-forge python=3.13 numpy pandas scikit-learn ipykernel
micromamba activate myenv
micromamba install -n myenv -c conda-forge seaborn
micromamba env export -n myenv > environment.yml    # share the spec
```

:::{warning}
An exported `environment.yml` is **not a lockfile**. Recreating it months later
can give different versions, which is exactly the problem pixi's lockfile
solves.
:::

---

## Troubleshooting

Installation problems (`pixi: command not found`, SSL errors on university
Wi-Fi, VS Code not seeing the environment, Windows path issues) are covered in
[Day 1 Setup → Troubleshooting](quickstart.md#troubleshooting).

---

**Next:** [VS Code](vscode.md)
