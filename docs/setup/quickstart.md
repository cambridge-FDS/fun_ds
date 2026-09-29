# Day 1 Setup: From Zero to a Running Notebook

This page is the **single source of truth** for getting your laptop ready before
Lecture 1. Work through it top to bottom — every step ends with a check you can
run, so you know it worked before moving on. Allow **60–90 minutes**, most of it
waiting for downloads: the course environment is a download of 0.5–1 GB (depending on your
operating system) and takes up to 3 GB of disk space once unpacked.

By the end you will have:

- `git`, `pixi` and VS Code installed;
- your own copy of the course repository;
- the course environment installed, with the shared `fun_ds` package;
- a lecture notebook running inside VS Code.

```{mermaid}
flowchart LR
    A[1. Install git] --> B[2. Install pixi]
    B --> C[3. Install VS Code<br/>+ extensions]
    C --> D[4. Clone the<br/>course repo]
    D --> E[5. pixi install]
    E --> F[6. Open a notebook<br/>+ pick the kernel]
    F --> G[7. Verify]
```

The other pages in _Getting Started_ explain the _why_ behind each tool and
serve as a reference: [Environments](environment_manager.md),
[VS Code](vscode.md), [Git](git.md) and [Pre-commit Hooks](pre-commit-hooks.md).

:::{note}
All commands go into a **terminal**: _Terminal_ on macOS, your usual shell on
Linux, and **PowerShell** (ideally inside _Windows Terminal_) on Windows. Once
VS Code is installed you can use its built-in terminal instead
(`` Ctrl+` `` / `` Cmd+` ``).
:::

---

## Step 1: Install git

Check whether git is already there:

```bash
git --version
```

If that prints a version number, skip ahead to _Tell git who you are_.
Otherwise:

- **macOS:** run `xcode-select --install` and accept the dialog. This installs
  Apple's command-line developer tools, which include git.
- **Windows:** download and install [Git for Windows](https://git-scm.com/download/win).
  The default options are fine; it also installs the Git Credential Manager,
  which remembers your GitHub login.
- **Linux (Debian/Ubuntu):** `sudo apt install git`.

Open a **new** terminal and re-run `git --version`.

**Tell git who you are** (once per laptop). This name and email appear on every
commit you make, so use the email address linked to your GitHub account:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

If you do not yet have a GitHub account, create one at
[github.com](https://github.com/signup) now — you will need it for the problem
sets and the project.

✅ **Check:** `git config --global user.name` prints your name.

---

## Step 2: Install pixi

pixi installs Python and every package the course needs into a folder _inside_
the project, so nothing clashes with other software on your laptop.
[Environments](environment_manager.md) explains why this matters.

**macOS / Linux:**

```bash
curl -fsSL https://pixi.sh/install.sh | sh
```

**Windows (PowerShell):**

```powershell
winget install prefix-dev.pixi
```

Close the terminal and open a **new** one (the installer changes your `PATH`,
and running terminals don't pick that up).

✅ **Check:** `pixi --version` prints a version number. If you get
`command not found`, see [Troubleshooting](#troubleshooting).

:::{tip}
If you already had pixi installed, update it with `pixi self-update`. The course
lockfile needs a recent version.
:::

---

## Step 3: Install VS Code and two extensions

1. Download and install VS Code from
   [code.visualstudio.com](https://code.visualstudio.com/).
2. Open it, click the **Extensions** icon in the left sidebar (four small
   squares), search for **Python** and install the extension published by
   **Microsoft** (`ms-python`). Then search for and install **Jupyter**, also by
   Microsoft.

```{figure} figures/install_python_extension.png
:alt: The Extensions panel with "python" typed into the search box; the first result is the Python extension by ms-python with an Install button.
:width: 100%

Installing the Python extension. Pick the one published by **ms-python**, not
one of the look-alikes. The Jupyter extension is installed the same way.
```

:::{admonition} Using Cursor instead?
:class: note
In the lectures we sometimes show [Cursor](https://cursor.com/), an editor built
on VS Code with extra AI features. It has the same layout, extensions and
settings, so everything on these pages applies to Cursor unchanged. Use
whichever you prefer.
:::

✅ **Check:** both _Python_ and _Jupyter_ show up under **Extensions →
Installed**.

---

## Step 4: Clone the course repository

"Cloning" downloads a full copy of the repository, including its history, so
that you can later pull in updates with a single command.

Pick a folder with a **short path that isn't synced to the cloud**, such as
`~/code` on macOS/Linux or `C:\dev` on Windows. Folders synced by OneDrive,
iCloud or Dropbox cause random file-locking and path-length errors. Then run:

```bash
cd ~/code            # or: cd C:\dev   (create the folder first if needed)
git clone https://github.com/cambridge-FDS/fun_ds.git
cd fun_ds
```

```{figure} figures/github_clone.png
:alt: A GitHub repository page with the green Code button opened, showing the Local tab, the Clone section and the HTTPS URL with a copy icon. The Fork button at the top right is also highlighted.
:width: 80%

Where to find the clone URL on any GitHub repository: the green **Code** button
→ _Local_ → _HTTPS_. The **Fork** button (top right) makes a copy under your
own account instead. You will need that for your own work later, but not for
following the lectures.
```

✅ **Check:** `git status` (run inside `fun_ds`) prints
`On branch main … nothing to commit, working tree clean`.

---

## Step 5: Install the course environment

Still inside the `fun_ds` folder:

```bash
pixi install          # downloads Python + all packages into .pixi/  (0.5–1 GB download, up to 3 GB on disk, 5–15 min)
pixi run install      # installs the course's own fun_ds package in editable mode
```

What just happened:

- `pixi install` read `pixi.toml` (the list of packages we asked for) and
  `pixi.lock` (the exact versions that were tested) and built an environment in
  `fun_ds/.pixi/envs/default/`. Everyone in the class gets the same versions.
- `pixi run install` makes `import fun_ds` work. The lecture notebooks use this
  small package for shared helpers such as `load_california_housing()`.
  "Editable" means that if you change code in `src/fun_ds/`, the notebooks see
  the change immediately, without reinstalling.

✅ **Check:**

```bash
pixi run python -c "from fun_ds import load_california_housing; print(load_california_housing().shape)"
```

This should print `(20640, 9)`. The first run downloads the California Housing
dataset (~0.4 MB) into `~/scikit_learn_data/`, so it needs an internet
connection once.

---

## Step 6: Open a lecture notebook in VS Code

1. In VS Code choose **File → Open Folder…** and select the **`fun_ds`** folder
   itself, not `docs/` or `docs/lectures/`. VS Code treats the folder you open
   as "the project", and that is where it looks for the pixi environment.
2. In the Explorer on the left, open `docs/lectures/lecture_2.ipynb`.

```{figure} figures/editor_layout.png
:alt: An annotated editor window: repository file tree on the left, open files and code editor in the middle, terminal at the bottom, and an AI agent panel on the right.
:width: 100%

The main areas of the editor. The screenshot shows Cursor with a different
example repository; VS Code looks the same apart from the AI panel on the
right.
```

3. **Pick the kernel.** A notebook runs its code in a _kernel_, which is a
   Python process. Click **Select Kernel** in the top-right corner of the
   notebook → **Python Environments…** → choose the entry whose path contains
   **`fun_ds/.pixi/envs/default`** (it may be labelled `default` or
   `Pixi`).

```{figure} figures/select_interpreter.png
:alt: The VS Code command palette with "Python: Select Interpreter" searched, followed by the interpreter list showing several environments with their paths.
:width: 90%

Choosing a Python environment. For `.py` scripts you use _Cmd/Ctrl+Shift+P →
Python: Select Interpreter_, as shown here; for notebooks you use the **Select
Kernel** button, which opens the same list. The screenshot shows conda
environments. In your list, pick the one whose path ends in
`.pixi/envs/default/bin/python` (Windows: `.pixi\envs\default\python.exe`).
```

If the pixi environment isn't listed, run **Developer: Reload Window** from the
Command Palette (`Cmd/Ctrl+Shift+P`) and try again. If it still isn't listed,
choose **Enter interpreter path…** and paste the full path to
`.pixi/envs/default/bin/python` (Windows: `.pixi\envs\default\python.exe`).

4. Click **Run All** at the top of the notebook.

✅ **Check:** the cells run without errors and you see tables and plots appear
under the cells. The kernel name in the top-right corner shows the pixi
environment.

---

## Step 7: Verify everything

Run the course's test suite from the `fun_ds` folder:

```bash
pixi run test
```

You should see a line ending in `passed` (warnings are fine). This confirms that
the environment, the `fun_ds` package and `pytest` are all wired up correctly.
**You are ready for Lecture 1.** 🎉

---

## Before you start working: two habits

### Experiment in your own files

You _will_ want to change the lecture code and try things out, which is the
point of the notebooks. The catch is that your edits (and even just re-running
a notebook and saving it) change files that git tracks. The next time you
update the course material with `git pull`, git will refuse to overwrite your
changes.

The simplest habit: **before experimenting, make a copy whose name starts with
`private_`**, for example `docs/lectures/private_lecture_5.ipynb`. The course
repository's `.gitignore` ignores every file starting with `private_`, so git
leaves your copies alone. They run exactly like the originals.

### Getting updates to the course material

We will push fixes and new material during term. To get them:

```bash
cd fun_ds
git status                  # anything listed as "modified"?
git restore docs/           # discard your changes to the lecture files (keeps private_* copies)
git pull
pixi install                # only does work if pixi.lock changed
```

:::{warning}
`git restore docs/` throws away your uncommitted changes to tracked files
under `docs/`. If you want to keep them, rename the file to a `private_…` copy
first, or use `git stash` (see [Git](git.md#common-commands-you-will-use-often)).
:::

### Pre-commit hooks (when you start committing)

For following the lectures you never need to commit anything. Once you start
committing to your own repositories (problem sets and the project), install the
pre-commit hooks in each repository once:

```bash
pixi run pre-commit install
```

[Pre-commit Hooks](pre-commit-hooks.md) explains what they check.

### Connecting to GitHub for pushing

Cloning a public repository needs no login. To **push** to your own
repositories you need to authenticate: either through the browser pop-up from
Git Credential Manager (the default on Windows and in VS Code) or with an SSH
key. See [GitHub Authentication](git.md#github-authentication).

---

## Troubleshooting

These are the problems most students hit, and the fix is almost always here.
Try it **before** posting on the forum, and when you do post, include the
exact command you ran and the full error message.

### `pixi: command not found` after installation

Your terminal is still using the old `PATH`. Close **all** terminals (and VS
Code) and open a fresh one. If that doesn't help, add pixi's folder to your shell
profile:

```bash
# macOS (zsh): ~/.zshrc     Linux (bash): ~/.bashrc
export PATH="$HOME/.pixi/bin:$PATH"
```

then open a new terminal. On Windows, sign out and back in.

### `pixi install` fails with SSL / certificate / timeout errors

This is common on university Wi-Fi (eduroam included), VPNs and corporate
networks. Try, in this order:

- switch to a different network (a phone hotspot is a good test);
- disconnect any VPN;
- re-run `pixi install`, since it resumes where it stopped.

### `ModuleNotFoundError: No module named 'fun_ds'`

You skipped `pixi run install` (Step 5), or the notebook is using the wrong
kernel (next item).

### Imports fail in the notebook but work with `pixi run python`

The notebook is running on a different Python, usually a system or conda one.
Check the kernel name in the top-right corner of the notebook and re-select the
pixi environment (Step 6). To see which Python a notebook uses, run this in a
cell:

```python
import sys; print(sys.executable)
```

The path should contain `.pixi/envs/default`.

### VS Code doesn't list the pixi environment

Make sure you opened the `fun_ds` folder itself (**File → Open Folder**), that
`pixi install` finished, and then run **Developer: Reload Window**. As a last
resort, use **Enter interpreter path…** (Step 6).

### Windows: long-path or permission errors

Clone into a short path such as `C:\dev\fun_ds`, outside OneDrive and
`Documents`, and use PowerShell in Windows Terminal rather than `cmd.exe`.

### `git pull` says "Your local changes would be overwritten"

You edited or re-ran and saved a lecture notebook. See
[Getting updates to the course material](#getting-updates-to-the-course-material).

---

**Next:** [Environments — the why behind pixi](environment_manager.md)
