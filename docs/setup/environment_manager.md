# Environment Management: micromamba and pixi

## Why use environments at all?

Before we get to the tools, the *why*: a Python environment is an isolated set of packages and a specific Python version, scoped to a single project. Without one, you install everything into your system Python and quickly hit trouble.

Three forces conspire against a "just pip install it" workflow:

- **Dependencies rot.** Libraries release breaking changes constantly. A notebook that ran fine six months ago may not import today if `pandas`, `scikit-learn`, or `numpy` have moved on. Pinning versions freezes a working combination in place.
- **Operating systems differ.** macOS (Intel vs. Apple Silicon), Linux, and Windows resolve binaries differently. A wheel that works on your laptop may not exist for a classmate's machine unless the environment manager knows how to solve per-platform.
- **Hardware differs.** CUDA vs. CPU builds, ARM vs. x86, AVX support — the same "package" is actually a family of builds. An environment manager picks the right one.

The goal is a **reproducible build**: given the same specification, anyone, anywhere, at any time gets the same working environment. This is the same principle Martin Kleppmann calls out in *Designing Data-Intensive Applications* — reproducibility is a system property you engineer for, not a happy accident.

:::{seealso}
For a broader take on why reproducibility, project layout, and automation matter in scientific work, see {cite}`wilson2017good` — "Good Enough Practices in Scientific Computing".
:::

This course uses Python packages (NumPy, pandas, scikit-learn, Jupyter, ...). To keep your setup **reliable** and **reproducible**, we recommend using a modern environment manager instead of installing everything globally.

This guide explains two good options:

- **micromamba**: a fast, minimal Conda-compatible package manager
- **pixi**: a modern, lockfile-first environment manager (recommended)

:::{note}
If you are new to environments: an environment is an isolated set of packages and a specific Python version.
This prevents "it works on my machine" problems and avoids conflicts between projects.
:::

## Day 1 Checklist

This is the **single source of truth** for getting set up before Lecture 1. Work through it top-to-bottom on your own laptop — you should finish in roughly **60–90 minutes** including downloads.

```{mermaid}
flowchart LR
    A[Install pixi<br/>10 min] --> B[Clone course repo<br/>5 min]
    B --> C[pixi install<br/>10 min]
    C --> D[Install VS Code<br/>+ extensions<br/>15 min]
    D --> E[Configure Git<br/>identity + auth<br/>15 min]
    E --> F[Install<br/>pre-commit hooks<br/>5 min]
    F --> G[Verify:<br/>pixi run pytest -q<br/>5 min]
```

| # | Step | Time | Where |
|---|------|------|-------|
| 1 | **Install pixi** | ~10 min | This guide, [Option B](#option-b-pixi-recommended) |
| 2 | **Clone the course repo** | ~5 min | [Git guide](git.md) |
| 3 | **Run `pixi install`** in the repo | ~10 min (depends on network) | This guide |
| 4 | **Install VS Code + core extensions** | ~15 min | [VS Code guide](vscode.md) |
| 5 | **Configure Git identity** | ~5 min | [Git guide](git.md) |
| 6 | **Set up GitHub authentication (SSH or PAT)** | ~10 min | [Git guide](git.md) |
| 7 | **Install pre-commit hooks** | ~5 min | [pre-commit guide](pre-commit-hooks.md) |
| 8 | **Verify your setup** | ~5 min | See below |

### Step 8: Verify your setup

From the root of the course repository, run:

```bash
pixi run pytest -q
```

If the test suite passes (or reports "no tests ran" cleanly, depending on the state of the repo), your environment is wired up correctly. As a secondary sanity check:

```bash
pixi list | head
pixi run python -c "import numpy; print(numpy.__version__)"
```

The first command shows the top of the resolved package list; the second confirms Python can import a core dependency and prints its version. If both work, you are done.

:::{tip}
If any step fails, jump to the [Troubleshooting](#day-1-troubleshooting-top-5-issues) section at the bottom of this page **before** asking on the forum — the fix is almost always there.
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

### Verifying your installation

Once `pixi install` finishes, sanity-check what actually got installed:

```bash
pixi list | head
```

This prints the resolved packages (name, version, build). If you see your dependencies with concrete version numbers, the environment is real.

Verify Python can import a core package:

```bash
pixi run python -c "import numpy; print(numpy.__version__)"
```

If this prints a version string, you are done. If it errors, your interpreter is probably pointing outside the pixi environment — always run through `pixi run ...` or from inside `pixi shell`.

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

## Day 1 Troubleshooting: Top 5 Issues

These are the problems most students hit. Try these fixes **before** posting on the forum — nine times out of ten one of them resolves the issue.

### `pixi: command not found` after installation

The installer put pixi in a directory (e.g. `~/.pixi/bin`) that isn't on your `PATH` yet, or your current shell is caching the old `PATH`.

**Fix:** Close the terminal and open a fresh one. If that still fails, add the pixi bin directory to your shell profile:

```bash
# ~/.zshrc or ~/.bashrc
export PATH="$HOME/.pixi/bin:$PATH"
```

Then `source` the file or open a new terminal.

### `pixi install` fails with SSL / certificate errors

Extremely common on university networks (Cambridge Wi-Fi included) and behind corporate proxies. The resolver can't verify the certificate chain when downloading from conda-forge.

**Fix, in order of preference:**

- Switch to a different network (mobile hotspot works as a diagnostic).
- Disable any active VPN and retry.
- Ask IT about the correct SSL/CA bundle for your machine and set `SSL_CERT_FILE` accordingly.

### VS Code doesn't see the pixi environment

The interpreter picker only lists environments it knows how to find, and `.pixi/envs/default/` is inside your project — not a global location.

**Fix:** Open the Command Palette → `Python: Select Interpreter` → **Enter interpreter path...**, and point it to:

```text
<project-root>/.pixi/envs/default/bin/python     (macOS/Linux)
<project-root>/.pixi/envs/default/python.exe     (Windows)
```

For notebooks, do the same via the kernel picker (top-right of the notebook). See the [VS Code guide](vscode.md) for details.

### Imports fail even though `pixi install` succeeded

Almost always means you ran `python` from **outside** the pixi environment — e.g. your terminal's default `python` is the system one.

**Fix:** Prefix every command with `pixi run`, or start an interactive session with `pixi shell`. To confirm which Python you are using:

```bash
pixi run python -c "import sys; print(sys.executable)"
```

The path should contain `.pixi/envs/default/`.

### Windows path or permission errors

Long paths (`> 260 chars`) and OneDrive-managed folders both cause pixi to fail in confusing ways.

**Fix:** Clone the course repo into a **short path** near the drive root (e.g. `C:\dev\fun_ds`), avoid OneDrive/Documents, and prefer **Windows Terminal + PowerShell** over `cmd.exe`.

:::{warning}
Avoid mixing tools for the same project (e.g., don't use pip globally and then expect your environment manager to "see" it).
Always install packages via your chosen tool to keep the environment consistent.
:::

### Other quick tips

- If the pixi environment is not visible in VS Code, see the [VS Code guide](vscode.md) for how to point the interpreter selector to `.pixi/envs/default/`.
- If you are on Windows, prefer PowerShell or Windows Terminal and keep paths short (avoid deeply nested folders).

---

**Next:** [VS Code](vscode.md)
