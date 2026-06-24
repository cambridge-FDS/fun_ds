# Environment Management: micromamba and pixi

This course uses Python packages (NumPy, pandas, scikit-learn, Jupyter, ...). To keep your setup **reliable** and **reproducible**, we recommend using a modern environment manager instead of installing everything globally.

This guide explains two good options:

- **micromamba**: a fast, minimal Conda-compatible package manager
- **pixi**: a modern, lockfile-first environment manager (recommended)

:::{note}
If you are new to environments: an environment is an isolated set of packages and a specific Python version.
This prevents "it works on my machine" problems and avoids conflicts between projects.
:::

:::{admonition} Day 1 Checklist
:class: tip

Here are all the steps to get your development environment ready for this course — in order:

1. **Install pixi** (this guide, Option B)
2. **Clone the course repo** and run `pixi install`
3. **Install VS Code + extensions** (see [VS Code guide](vscode.md))
4. **Configure Git identity** (see [Git guide](git.md))
5. **Set up GitHub authentication** (see [Git guide](git.md))
6. **Install pre-commit hooks** (see [pre-commit guide](pre-commit-hooks.md))
:::

---

## Option A: micromamba

### What is micromamba?

**micromamba** is a lightweight alternative to conda/mamba:

- Very fast dependency resolution
- Small installer footprint
- Uses the **conda-forge** ecosystem (huge package availability)
- Works well when you want a simple "conda-style" workflow

### When to use micromamba

Choose micromamba if:

- you already know conda environments
- you want a minimal tool that behaves like conda
- you don't need project-level lockfiles and tasks

### Installation

**macOS / Linux:**

```bash
"${SHELL}" <(curl -L micro.mamba.pm/install.sh)
```

**Windows (PowerShell):**

```powershell
Invoke-Expression ((Invoke-WebRequest -Uri https://micro.mamba.pm/install.ps1 -UseBasicParsing).Content)
```

:::{tip}
You can usually install micromamba in a user directory and avoid needing admin rights.
:::

After installation, ensure it's available in your shell:

```bash
micromamba --version
```

### Shell initialization

micromamba needs shell integration so that activation works properly:

```bash
micromamba shell init -s bash -p ~/micromamba
# Restart your shell after this
```

For zsh:

```bash
micromamba shell init -s zsh -p ~/micromamba
# Restart your shell after this
```

### Creating an environment

Create an environment with a fixed Python version and core packages:

```bash
micromamba create -n ds101 -c conda-forge python=3.11 numpy pandas scikit-learn matplotlib jupyterlab
```

Activate it:

```bash
micromamba activate ds101
```

Check Python:

```bash
python --version
```

### Installing additional packages

```bash
micromamba install -n ds101 -c conda-forge seaborn scipy
```

### Exporting the environment

You can export an environment file for sharing:

```bash
micromamba env export -n ds101 > environment.yml
```

:::{warning}
An `environment.yml` is often **not fully reproducible** over time because it can allow version drift.
Two students creating an environment months apart may end up with different dependency versions.
:::

---

## Option B: pixi (recommended)

### What is pixi?

**pixi** is a modern environment and project manager designed around:

- **Project-based workflows** (your environment "lives with" your project)
- **Lockfiles** for reproducibility
- Simple cross-platform setup (same project works on Windows/macOS/Linux)
- Optional **tasks** (run scripts like `pixi run test` / `pixi run lab`)

pixi uses the conda-forge ecosystem as well, so you still get the same broad package availability.

### Why we recommend pixi for this course

pixi is the best default for a class because it makes setups predictable:

- Students get **the same dependency versions** via the lockfile.
- Instructors can provide a single project folder that "just works".
- Running commands is consistent across platforms.

In short: fewer installation issues and fewer "dependency mismatch" problems.

### Installation

**macOS / Linux:**

```bash
curl -fsSL https://pixi.sh/install.sh | sh
```

**Windows (PowerShell):**

```powershell
winget install prefix-dev.pixi
```

Or via PowerShell directly:

```powershell
iwr -useb https://pixi.sh/install.ps1 | iex
```

After installation, open a **new terminal** and verify:

```bash
pixi --version
```

### Core concepts

pixi is project-first. The project contains:

- `pixi.toml`: high-level dependency specification
- `pixi.lock`: exact resolved versions (reproducibility)

A typical workflow is:

1. clone/download a course repository (containing `pixi.toml`)
2. run `pixi install`
3. run tools via `pixi run ...` or enter the environment with `pixi shell`

### Entering the environment shell

For an interactive session where you want to type commands directly (rather than prefixing each with `pixi run`), use:

```bash
pixi shell
```

This drops you into a shell with the environment activated. Type `exit` to leave.

:::{tip}
Use `pixi run <command>` for one-off commands and `pixi shell` when you want an interactive session.
:::

### Create a new project (example)

If you are starting from scratch:

```bash
mkdir ds101
cd ds101
pixi init
```

Add dependencies:

```bash
pixi add python=3.11 numpy pandas scikit-learn matplotlib jupyterlab
```

Install (resolve + create environment):

```bash
pixi install
```

Run Python inside the environment:

```bash
pixi run python --version
```

### `.gitignore` for pixi projects

pixi creates a `.pixi/` directory for the local environment. This should **not** be committed to Git.
When you run `pixi init`, a `.gitignore` is created automatically — check that it includes:

```text
.pixi
```

If not, add it manually.

### Starting JupyterLab via pixi

You can run JupyterLab without manual activation:

```bash
pixi run jupyter lab
```

:::{tip}
This is great for a course: you don't need to teach shell activation first.
Students can just run one command.
:::

### Optional: use tasks for common commands

pixi can define tasks in `pixi.toml` so everyone uses the same commands.

Example `pixi.toml` snippet:

```toml
[project]
name = "ds101"
channels = ["conda-forge"]
platforms = ["linux-64", "osx-64", "osx-arm64", "win-64"]

[dependencies]
python = "3.11"
numpy = "*"
pandas = "*"
scikit-learn = "*"
matplotlib = "*"
jupyterlab = "*"

[tasks]
lab = "jupyter lab"
test = "python -m pytest -q"
```

:::{note}
The `"*"` version specifier means "any version". In your own scratch projects this is fine.
In the course repository, the `pixi.lock` file pins every dependency to exact versions — so everyone
runs the same code regardless of when they install.
:::

Then students can run:

```bash
pixi run lab
```

### Updating dependencies

To update (e.g., during development):

```bash
pixi update
```

:::{note}
If you are teaching a course, you typically update dependencies only when you intend to.
The lockfile ensures students stay consistent.
:::

### Using an instructor-provided repository

If your instructor provides a folder with `pixi.toml`:

```bash
# inside the course project folder
pixi install
pixi run jupyter lab
```

---

## micromamba vs pixi (quick comparison)

| Feature | micromamba | pixi |
|---------|-----------|------|
| Primary style | environment-first (conda-like) | project-first |
| Reproducibility | good with discipline, but YAML can drift | excellent via lockfile |
| Best for courses | workable | best (fewer "it doesn't work" issues) |
| Commands | create/activate/install | add/install/run |
| Typical artifacts | `environment.yml` | `pixi.toml` + `pixi.lock` |

---

## Final recommendation for this course

We recommend **pixi**.

- It gives each project a **portable, reproducible environment**
- It reduces student setup issues
- It enables consistent commands (e.g., `pixi run jupyter lab`)
- The lockfile makes debugging and grading easier because everyone runs the same versions

If you already use conda/mamba and prefer that style, **micromamba is a solid alternative**—but for a course setting, pixi's project + lockfile workflow is the most reliable.

---

## Troubleshooting tips

- If commands are not found, restart your terminal or ensure the tool is on your PATH.
- If `pixi install` fails with an SSL or certificate error, this is common on university networks. Try connecting via a different network, disabling VPN, or asking IT about certificate configuration.
- If the pixi environment is not visible in VS Code, see the [VS Code guide](vscode.md) for how to point the interpreter selector to `.pixi/envs/default/`.
- If you are on Windows, prefer PowerShell or Windows Terminal and keep paths short (avoid deeply nested folders).

:::{warning}
Avoid mixing tools for the same project (e.g., don't use pip globally and then expect your environment manager to "see" it).
Always install packages via your chosen tool to keep the environment consistent.
:::
