# GitHub and Git — A Practical Introduction for Data Science Students

This guide introduces **Git** (version control) and **GitHub** (a hosting and collaboration platform) from a **data science perspective**.
It focuses on the commands and workflows you will use most often, plus common mistakes to avoid.

:::{note}
You do **not** need to memorize everything.
What matters is understanding the *ideas* and knowing where things go wrong.
:::

---

## What Are Git and GitHub?

**Git**
:   A *version control system* that tracks changes to files over time.
    It lets you go back to previous versions, compare changes, and work safely.

**GitHub**
:   A platform that hosts Git repositories and adds:
    - collaboration tools
    - issue tracking
    - pull requests
    - code review
    - CI/CD integration

:::{tip}
Git is the *engine*; GitHub is the *platform* built on top of it.
:::

---

## Why Data Scientists Need Git

Git is essential in data science because:

- experiments change constantly
- results must be reproducible
- collaboration is the norm
- notebooks and scripts evolve together
- mistakes are inevitable

With Git you can:

- track experiments over time
- collaborate without overwriting work
- understand *why* results changed
- recover from mistakes

---

## Basic Concepts (Mental Model)

### Repository

A **repository** (repo) is a project tracked by Git.

It contains:
- code
- notebooks
- configuration files
- documentation

### Local vs Remote

**Local repository**
:   The copy on your machine.

**Remote repository**
:   The copy on GitHub.

Changes move between them via **push** and **pull**.

### Commit

A **commit** is a snapshot of your files at a point in time.

Think of it as:
- "Save with history"
- atomic and descriptive

### Branch

A **branch** is an independent line of development.

You usually:
- keep `main` clean
- do work on feature branches

---

## Getting Started

Check that Git is installed:

```bash
git --version
```

Configure your identity (do this once):

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

:::{note}
This information appears in commit history.
Use a professional name/email.
:::

---

## Creating or Cloning a Repository

Clone an existing repository:

```bash
git clone https://github.com/username/repository.git
cd repository
```

Create a new repository locally:

```bash
git init
```

---

## Ignoring Files: `.gitignore`

Not everything belongs in Git. A `.gitignore` file tells Git which files to ignore.

Create one in the root of your repository:

```bash
# in the project root
touch .gitignore
```

A sensible default for data science projects:

```text
# Python
__pycache__/
*.pyc
*.pyo
.Python

# Environments
.env
.venv/
.pixi/

# Jupyter
.ipynb_checkpoints/

# Data (store externally)
data/
*.csv
*.parquet
*.h5

# OS files
.DS_Store
Thumbs.db
```

Add and commit it:

```bash
git add .gitignore
git commit -m "Add .gitignore"
```

:::{warning}
Once a file is tracked by Git, adding it to `.gitignore` does **not** remove it from history.
Set up `.gitignore` **before** your first commit, or use `git rm --cached <file>` to untrack a file later.
:::

---

## GitHub Authentication

To push and pull from GitHub, you need to authenticate. There are two main approaches:

### Option 1: SSH Key (recommended)

Generate a key (if you don't have one):

```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
```

Copy the public key to your clipboard:

```bash
# macOS
cat ~/.ssh/id_ed25519.pub | pbcopy

# Linux
cat ~/.ssh/id_ed25519.pub | xclip -selection clipboard

# Windows (PowerShell)
Get-Content ~/.ssh/id_ed25519.pub | Set-Clipboard
```

Then add it to GitHub: **Settings → SSH and GPG keys → New SSH key**.

Test the connection:

```bash
ssh -T git@github.com
```

When cloning with SSH, use the SSH URL:

```bash
git clone git@github.com:username/repository.git
```

### Option 2: HTTPS with a Personal Access Token

GitHub no longer accepts your password over HTTPS. Instead, create a **Personal Access Token (PAT)**:

1. Go to **GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)**
2. Generate a token with `repo` scope
3. Use the token as your password when Git prompts you

:::{tip}
On macOS, Git Credential Manager can cache your token automatically.
On Windows, Git for Windows includes the credential manager by default.
:::

See the [GitHub authentication docs](https://docs.github.com/en/authentication) for full details.

---

## The Core Git Workflow

The three most important commands:

```bash
git status
git add
git commit
```

### Check status

```bash
git status
```

Shows:
- modified files
- staged files
- untracked files

### Add files (stage)

```bash
git add file.py
git add notebook.ipynb
git add .
```

:::{tip}
`git add .` stages *everything* in the current directory.
Use it carefully.
:::

### Commit changes

```bash
git commit -m "Describe what you changed"
```

Good commit messages:
- are short
- explain *why*, not just *what*

Bad: fix

Good: Add feature engineering for housing model

---

## Working with GitHub (Remote)

Add a remote (if needed):

```bash
git remote add origin https://github.com/username/repository.git
```

Push commits:

```bash
git push origin main
```

Pull updates:

```bash
git pull origin main
```

---

## Branching (Highly Recommended)

Create and switch to a branch:

```bash
git switch -c feature-cleaning
```

Work, commit, then push:

```bash
git push -u origin feature-cleaning
```

Open a **Pull Request** on GitHub to merge into `main`.

:::{note}
Pull Requests are not just for teams — they are excellent for reviewing your own work.
:::

---

## Handling Notebooks (Important!)

Jupyter notebooks need special care.

Best practices:

- restart kernel and run all cells before committing
- keep notebooks small and focused
- move reusable code into `.py` files
- avoid large outputs

:::{warning}
Notebook merge conflicts are painful.
Tools like `nbstripout` help prevent this.
:::

---

## Common Commands You Will Use Often

View commit history:

```bash
git log --oneline
```

See differences:

```bash
git diff
git diff --staged
```

Undo local changes (careful!):

```bash
git restore file.py
```

Unstage a file:

```bash
git restore --staged file.py
```

Park in-progress work temporarily:

```bash
git stash        # save current changes
git stash pop    # restore them later
```

---

## Common Gotchas (Read This!)

### "I forgot to commit"

Your work is usually still there.

Check:

```bash
git status
```

Then commit.

---

### "I committed the wrong thing"

If not pushed yet:

```bash
git commit --amend
```

---

### "I pushed secrets or data"

**This is serious.**

- Remove immediately
- Rotate credentials
- Inform the instructor / team

:::{warning}
Never commit:
- passwords
- API keys
- large datasets
- personal data
:::

---

### "My repo is full of data"

Data does **not** belong in Git.

Use:
- external storage
- data versioning tools
- download scripts

---

## What Git Is Not

Git is **not**:

- a backup system for large files
- a database
- a substitute for documentation

---

## Recommended Workflow for This Course

1. Clone the course repository
2. Create a feature branch for each task
3. Commit frequently
4. Push regularly
5. Open Pull Requests for review
6. Keep `main` clean and working

---

## Final Advice

- Use Git early, not at the end
- Commit small, meaningful changes
- Write clear commit messages
- Treat Git history as part of your work

:::{tip}
If something goes wrong, **do not panic**.
Git is designed to help you recover.
:::

---

## Further Reading

- Git documentation: https://git-scm.com/doc
- GitHub Docs: https://docs.github.com/
- GitHub authentication: https://docs.github.com/en/authentication
- Pro Git (free book): https://git-scm.com/book/en/v2
