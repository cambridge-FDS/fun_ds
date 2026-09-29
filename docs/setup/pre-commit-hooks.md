# Pre-commit Hooks for Data Science Projects

**Previous:** [Git](git.md) | **Next:** [Lecture 1](../lectures/lecture_1.md)

---

This guide explains how to set up **pre-commit hooks** for data science projects and why they are an important part of a professional workflow.

:::{important}
**The course repository already ships a `.pre-commit-config.yaml`, and `pre-commit` is already in the pixi environment.** You don't need to write or install anything. Run `pixi run pre-commit install` once inside the repository and you are done. The configuration below is the one the course uses; it is documented here so you understand _what_ is running and _why_, and so you can reuse it in your own projects.
:::

We focus on a **popular, battle-tested default configuration** that works well for:

- Python scripts
- Jupyter notebooks
- Data science repositories
- Student projects and team collaboration

:::{note}
Pre-commit hooks are **not about policing you**.
They are about catching small issues _early_, automatically, before they turn into bugs, style debates, or broken submissions.
:::

---

## What Are Pre-commit Hooks?

A _pre-commit hook_ is a script that runs **automatically before a Git commit is created**.

Typical tasks include:

- formatting code
- checking for syntax errors
- removing trailing whitespace
- preventing large or sensitive files from being committed
- enforcing consistent style

If a hook fails, the commit is **blocked** until the issue is fixed.

---

## Why Use Pre-commit in This Course?

Using pre-commit helps with:

**Code Quality**
: Ensures clean, readable code without relying on manual checks.

**Reproducibility**
: Reduces hidden formatting and syntax issues that break notebooks or scripts.

**Collaboration**
: Everyone follows the same rules automatically.

**Reduced Friction**
: No arguments about formatting or style—tools decide.

**Industry Practice**
: Pre-commit is widely used in professional Python projects. The same `pre-commit run --all-files` command also runs in CI pipelines, so passing it locally means passing it remotely.

:::{tip}
Think of pre-commit as an automated "last sanity check" before code leaves your machine.
:::

---

## Installing pre-commit

**In the course repository** it is already part of the environment:

```bash
pixi run pre-commit --version
```

**In your own pixi project**, add it like any other package:

```bash
pixi add pre-commit
```

---

## Basic Setup

The hooks are configured in a file named `.pre-commit-config.yaml` in the root
of the repository. For your own projects, copy the course's file (shown below)
as a starting point.

Then install the hooks **once per clone**:

```bash
pixi run pre-commit install
```

This writes a small script into `.git/hooks/`, so that Git runs the hooks
automatically on every `git commit`, including commits made from VS Code's
Source Control panel.

:::{note}
The first run takes a minute or two: pre-commit downloads and caches each tool
in its own isolated environment (under `~/.cache/pre-commit`). Later runs take
seconds.
:::

---

## The Course Configuration

This is the course repository's `.pre-commit-config.yaml`:

```yaml
repos:
  # Python linting and formatting (fast, modern)
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.8.6
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  # Static type checking
  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.13.0
    hooks:
      - id: mypy
        additional_dependencies: [types-setuptools]
        args: [--ignore-missing-imports]

  # General hygiene checks
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
        args: [--maxkb=500]

  # Consistent Markdown formatting
  - repo: https://github.com/pre-commit/mirrors-prettier
    rev: v3.1.0
    hooks:
      - id: prettier
        files: "\\.md$"
```

Ruff's settings (which rules, line length) live in `pyproject.toml` under
`[tool.ruff]`, so the editor extension, `pixi run check` and the hook all
agree.

:::{note}
The version numbers above (e.g. `rev: v0.8.6`) are illustrative and **will drift** as upstream projects release. Do not copy them blindly — instead, run:

```bash
pre-commit autoupdate
```

This walks your `.pre-commit-config.yaml` and rewrites every `rev:` field to the latest stable release. Re-run it every few months, commit the change, and CI will pick it up automatically.

The course repository's `.pre-commit-config.yaml` is the canonical reference — reuse it rather than authoring a new one from scratch.
:::

---

## What Each Hook Does (Important!)

### General Hygiene Hooks

These come from `pre-commit-hooks` and are extremely common.

#### `trailing-whitespace`

- Removes extra spaces at the end of lines
- Prevents noisy diffs and formatting clutter

Why it matters:
Trailing whitespace causes meaningless Git diffs and makes reviews harder.

#### `end-of-file-fixer`

- Ensures files end with a single newline

Why it matters:
Many tools expect this. Missing newlines can break POSIX tooling.

#### `check-yaml` / `check-json`

- Verifies that YAML/JSON files are valid

Why it matters:
Configuration files fail silently when malformed.

#### `check-merge-conflict`

- Fails if Git conflict markers are present:

```text
<<<<<<< HEAD
=======
>>>>>>>
```

Why it matters:
This prevents committing broken files by accident.

#### `check-added-large-files`

- Blocks committing large files (default 500 kB; the course sets it explicitly
  with `--maxkb=500`)

Why it matters:
Large datasets and binaries **do not belong in Git**.
They should be stored externally or via data versioning tools.

---

## Python Linting and Formatting: Ruff

#### `ruff-format`

- Formats Python code (and notebook cells) automatically
- Enforces a single, consistent style. It is a faster drop-in replacement for
  the _Black_ formatter you may see in older projects
- No configuration debates

Why it matters:
Formatting differences should never distract from logic or learning.

:::{tip}
If the formatter changes your code, **just accept it**.
It is intentionally opinionated.
:::

#### `ruff`

- Extremely fast Python linter
- Replaces many older tools (flake8, pyflakes, isort)
- Catches:
  - unused imports
  - undefined variables
  - common bugs
  - style issues

With `--fix`:

- Automatically fixes safe issues (e.g. unused imports)

Why it matters:
Ruff catches mistakes that otherwise show up at runtime or grading time.

---

## Type Checking: mypy

#### `mypy`

- Reads your type hints (`def load(path: Path) -> pd.DataFrame:`) and checks
  that the code is consistent with them, without running it
- Catches e.g. passing a `str` where a `Path` was expected, or forgetting that a
  function can return `None`

Why it matters:
Type errors are a large class of bugs that otherwise only appear when a rarely
used code path finally runs. The course's `fun_ds` package is type-checked; see
the `[tool.mypy]` section in `pyproject.toml`.

---

## Markdown: prettier

#### `prettier`

- Reformats Markdown files (tables, lists, line breaks) consistently

Why it matters:
Documentation is part of the codebase and deserves the same consistency.

---

## Optional for Your Own Repos: nbstripout

The course repository keeps notebook outputs, because it doubles as this book.
For problem-set and project repositories, stripping outputs is usually the
better choice. Add this block to your `.pre-commit-config.yaml`:

```yaml
- repo: https://github.com/kynan/nbstripout
  rev: 0.8.1
  hooks:
    - id: nbstripout
```

#### `nbstripout`

- Removes execution outputs from notebooks before committing
- Keeps:
  - code
  - markdown
- Removes:
  - cell outputs
  - large embedded data
  - execution counts

Why it matters:
Notebook outputs:

- bloat Git history
- cause merge conflicts
- make diffs unreadable

:::{note}
You can still see outputs locally.
They just won't be committed to Git.
:::

---

## Using pre-commit in Practice

Normal workflow:

```bash
git add .
git commit -m "My changes"
```

If hooks fail:

- Read the error message
- Fix the issue (often automatic)
- Re-run `git commit`

:::{important}
When a hook **modifies** a file (e.g. the formatter rewrote it), the commit is
aborted and the fixed file is left _unstaged_. This is the most common source
of confusion. Just `git add` the file again and re-run `git commit`; the second
attempt passes.

```text
ruff format..............................................................Failed
- hook id: ruff-format
- files were modified by this hook
```

:::

Run hooks manually on all files:

```bash
pixi run lint            # the course task; equivalent to: pixi run pre-commit run --all-files
```

:::{tip}
This is useful before pushing or submitting assignments.
It is also the command that runs in CI — so if it passes locally, it will pass remotely.
:::

Keep hook versions up to date:

```bash
pre-commit autoupdate
```

This updates all `rev:` values in your `.pre-commit-config.yaml` to the latest stable releases.

---

## CI Integration

Running pre-commit locally is only half the story. In professional projects the **exact same hooks run in Continuous Integration** — every Pull Request is automatically checked, and the merge is blocked until the hooks pass.

This matters because:

- A student (or teammate) can _bypass_ local hooks with `git commit --no-verify`. CI cannot be bypassed.
- Fresh clones, forks, and reviewers all get the same guarantee: **everything on `main` passed the checks.**
- It removes the "did you run the formatter?" step from every code review.

Below is a minimal GitHub Actions workflow that runs pre-commit on every push and pull request. Save it as `.github/workflows/pre-commit.yml`:

```yaml
name: pre-commit

on:
  push:
    branches: [main]
  pull_request:

jobs:
  pre-commit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - uses: pre-commit/action@v3.0.1
```

This is the same command (`pre-commit run --all-files`) that you run locally, executed on GitHub's runners. If your local commit passes, the CI check will pass.

:::{seealso}
The course repository already wires this up. See [`.github/workflows/ci.yml`](https://github.com/cambridge-FDS/fun_ds/blob/main/.github/workflows/ci.yml) for the concrete workflow used in class: it installs the pixi environment with `prefix-dev/setup-pixi` and runs `pixi run lint`, `pixi run test` and a full book build on every pull request. Read it; it is short and shows the pattern above with a real environment.
:::

---

## Common Questions

### "Can I bypass pre-commit?"

Yes (but avoid it):

```bash
git commit --no-verify
```

Use this **only** if you know what you're doing.

---

### "Will this slow me down?"

No, in practice:

- Hooks run only on changed files
- Tools like Ruff are extremely fast
- You save time by avoiding later fixes

---

### "What if I disagree with a rule?"

In this course:

- Use the defaults
- Focus on learning, not style debates

In real projects:

- Teams agree on rules **once**
- Automation enforces them consistently

---

## Recommended Workflow for This Course

1. In the course repo: `pixi run pre-commit install` (once)
2. In your own repos: copy the course's `.pre-commit-config.yaml`, add
   `pre-commit` to the environment, run `pixi run pre-commit install`
3. Commit normally
4. If a hook rewrites files, `git add` them and commit again

---

## Final Recommendation

For this course, we recommend:

- **pre-commit** for automation
- **Ruff** for linting and formatting
- **mypy** for type checking your package code
- **pre-commit-hooks** for basic hygiene
- **nbstripout** for notebooks in your own repositories

This setup reflects **modern professional data science practice** while remaining beginner-friendly.

---

## Further Reading

- pre-commit documentation: https://pre-commit.com/
- mypy: https://mypy.readthedocs.io/
- Ruff linter: https://docs.astral.sh/ruff/
- nbstripout: https://github.com/kynan/nbstripout
