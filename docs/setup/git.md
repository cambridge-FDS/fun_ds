# GitHub and Git — A Practical Introduction for Data Science Students

**Previous:** [VS Code](vscode.md) | **Next:** [Pre-commit Hooks](pre-commit-hooks.md)

---

This guide introduces **Git** (version control) and **GitHub** (a hosting and collaboration platform) from a **data science perspective**.
It focuses on the commands and workflows you will use most often, plus common mistakes to avoid.

:::{note}
You do **not** need to memorize everything.
What matters is understanding the _ideas_ and knowing where things go wrong.
:::

---

## What Are Git and GitHub?

**Git**
: A _version control system_ that tracks changes to files over time.
It lets you go back to previous versions, compare changes, and work safely.

**GitHub**
: A platform that hosts Git repositories and adds collaboration tools: issue
tracking, pull requests, code review and CI/CD integration.

:::{tip}
Git is the _engine_; GitHub is the _platform_ built on top of it.
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
- understand _why_ results changed
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
: The copy on your machine.

**Remote repository**
: The copy on GitHub.

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

If it isn't, [Day 1 Setup → Step 1](quickstart.md#step-1-install-git) shows how
to install it on macOS, Windows and Linux.

Configure your identity (do this once):

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

:::{note}
This information appears in commit history.
Use a professional name/email, and use the same email as your GitHub account
so that GitHub links your commits to your profile.
:::

---

## Creating or Cloning a Repository

There are three ways to get a repository onto your machine, and they fit
different situations:

| You want to…                                              | Do this                                                            |
| --------------------------------------------------------- | ------------------------------------------------------------------ |
| **Follow along** with someone else's repo (e.g. `fun_ds`) | **Clone** it                                                       |
| **Build on** someone else's repo and push your changes    | **Fork** it on GitHub, then clone _your fork_                      |
| **Start** a new project                                   | Create an empty repo on GitHub and clone it, or `git init` locally |

```{figure} figures/github_clone.png
:alt: A GitHub repository page with the green Code button opened, showing the Local tab, the Clone section and the HTTPS URL. The Fork button at the top right is also highlighted.
:width: 80%

**Code → Local → HTTPS** gives you the URL to clone. **Fork** (top right)
creates a copy under your own GitHub account that you can push to.
```

Clone an existing repository:

```bash
git clone https://github.com/username/repository.git
cd repository
```

Create a new repository locally:

```bash
git init
```

You can also clone from inside VS Code: Command Palette → **Git: Clone**, paste
the URL, choose a folder.

---

## Ignoring Files: `.gitignore`

Not everything belongs in Git. A `.gitignore` file tells Git which files to ignore.

Create one in the root of your repository:

```bash
# in the project root
touch .gitignore
```

A sensible default for data science projects (GitHub also offers a
ready-made `Python` template when you create a repository):

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

Cloning and pulling a **public** repository needs no login. To **push** (or to
access a private repository) you need to authenticate. There are two main
approaches; pick one.

:::{tip}
If you use VS Code's **Source Control** panel or Git for Windows, you will often
get a browser pop-up asking you to sign in to GitHub the first time you push.
Accepting it sets up HTTPS authentication for you (Option 2), and you can skip
the rest of this section.
:::

### Option 1: SSH Key

Generate a key (if you don't have one). Accept the default file location and
choose a passphrase:

```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
```

Copy the public key to your clipboard:

```bash
# macOS
cat ~/.ssh/id_ed25519.pub | pbcopy

# Linux (or anywhere: print it and copy by hand)
cat ~/.ssh/id_ed25519.pub

# Windows (PowerShell)
Get-Content ~/.ssh/id_ed25519.pub | Set-Clipboard
```

Then add it to GitHub: **Settings → SSH and GPG keys → New SSH key**.

Test the connection:

```bash
ssh -T git@github.com
```

The first time, answer `yes` to the host-authenticity question. Success looks
like `Hi <username>! You've successfully authenticated…`.

When cloning with SSH, use the SSH URL:

```bash
git clone git@github.com:username/repository.git
```

### Option 2: HTTPS with a Personal Access Token

GitHub no longer accepts your password over HTTPS. Instead, create a **Personal Access Token (PAT)**:

1. Go to **GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens**
2. Generate a token with access to the repositories you need and **Contents: Read and write** permission
3. Use the token as your password when Git prompts you

:::{tip}
Git for Windows ships the Git Credential Manager, which stores the token (or
does a browser login) for you. On macOS the built-in keychain helper remembers
it after the first use. Either way you only type it once.
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
`git add .` stages _everything_ in the current directory.
Use it carefully.
:::

### Commit changes

```bash
git commit -m "Describe what you changed"
```

Good commit messages:

- are short
- explain _why_, not just _what_

Bad:

```text
fix
```

Good:

```text
Add feature engineering for housing model
```

### Conventional Commits

A widely used convention in professional teams is **Conventional Commits** (Angular style): prefix the commit subject with a _type_ that describes the kind of change. This turns your Git history into a machine-readable changelog and lets tools automatically generate release notes.

The full form is:

```text
<type>(<optional scope>): <short description>
```

Common types:

| Prefix      | Use for                                     |
| ----------- | ------------------------------------------- |
| `feat:`     | A new feature or capability                 |
| `fix:`      | A bug fix                                   |
| `docs:`     | Documentation-only changes                  |
| `refactor:` | Code restructuring with no behaviour change |
| `test:`     | Adding or updating tests                    |
| `chore:`    | Build tooling, dependency bumps, config     |
| `style:`    | Formatting only (whitespace, semicolons)    |
| `perf:`     | Performance improvements                    |

Examples:

```text
feat: add k-fold cross-validation to housing model
fix: correct off-by-one index in feature scaler
docs: expand Day 1 checklist with troubleshooting
refactor(model): extract training loop into utils.py
```

You do not need to use conventional commits religiously in this course, but adopting the habit early makes your work look more professional and prepares you for teams that mandate it.

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

(In practice you rarely push to `main` directly. See
[Branching](#branching-highly-recommended) below.)

Pull updates:

```bash
git pull origin main
```

---

## Branching (Highly Recommended)

The idea: `main` is always in a working state. All new work happens on a _branch_, gets reviewed via a Pull Request, and only merges back to `main` once it passes checks.

```{mermaid}
gitGraph
    commit id: "initial"
    commit id: "add data loader"
    branch feature-cleaning
    checkout feature-cleaning
    commit id: "drop NaNs"
    commit id: "encode categoricals"
    checkout main
    commit id: "hotfix: typo"
    merge feature-cleaning id: "PR merged"
    commit id: "next work"
```

Create and switch to a branch:

```bash
git switch -c feature-cleaning
```

Work, commit, then push:

```bash
git push -u origin feature-cleaning
```

Open a **Pull Request** on GitHub to merge into `main`. After a push, GitHub
shows a yellow banner with a **Compare & pull request** button on the
repository page.

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

## Git Blame and Code Archaeology

One of the most underused professional habits is **git archaeology**: using Git's history not just to look back at your own recent commits, but to answer questions like _"why is this line here?"_ or _"when did this test start being skipped?"_.

The workhorse command is `git blame`:

```bash
git blame src/features.py
```

For every line it shows the commit hash, author, date, and message that introduced it. From there you can jump to the full commit:

```bash
git show <commit-hash>
```

Combined with `git log -S "search string"` (which finds every commit where a given string was added or removed), you can trace the full evolution of a function or a bug. This is invaluable when inheriting a codebase — including the course repository.

:::{tip}
In VS Code, the **GitLens** extension makes blame inline: it shows the last-modified author and commit for every line right in the editor. If you take one optional extension, take that one.
:::

Treat Git history as _documentation_. A well-written commit message is a note to your future self explaining a decision you no longer remember making.

---

## Finding Regressions with `git bisect`

A **regression** is when something that used to work stops working. `git bisect` finds the exact commit that introduced it — using binary search, so even hundreds of commits between "known good" and "known bad" only take ~10 steps.

```bash
git bisect start
git bisect bad                   # current commit is broken
git bisect good <old-commit>     # this commit was fine
```

Git checks out a commit halfway between the two; you test it, run `git bisect good` or `git bisect bad`, and it narrows the range. When it lands on the culprit, run `git bisect reset` to return to your branch. Learning `bisect` once and using it twice in your career pays for the fifteen minutes it takes to read the docs.

---

## `.gitattributes` for Notebooks

Notebooks store execution outputs, cell IDs, and metadata inside the `.ipynb` JSON. If you commit these, every re-run produces a huge diff and merge conflicts become almost impossible to resolve.

The clean solution is a **`nbstripout` Git filter**, configured via `.gitattributes` at the repository root:

```text
# .gitattributes
*.ipynb filter=nbstripout
*.ipynb diff=ipynb
```

Then, once per clone:

```bash
pip install nbstripout   # or: pixi add nbstripout
nbstripout --install
```

From then on, Git automatically strips outputs from notebooks _on the way into the repo_ while leaving them intact in your working copy. Your local runs keep their plots and results; the committed version stays clean. This is a good default for **your own** repositories (problem sets, project).

:::{note}
The course repository deliberately does **not** strip outputs. It is a book, and
the committed outputs let you read every result on GitHub without running
anything. The trade-off is that re-running a lecture notebook changes tracked
files. See [Day 1 Setup → Experiment in your own files](quickstart.md#experiment-in-your-own-files)
for how to handle that.
:::

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

If not pushed yet, fix the files, `git add` them, then:

```bash
git commit --amend
```

This replaces the last commit. Don't amend commits you've already pushed to a
shared branch.

---

### "I have a merge conflict"

Two branches changed the same lines, and Git needs you to decide which version
wins. VS Code highlights the conflicting blocks and offers one-click options
above each one:

```{figure} figures/merge_conflict.png
:alt: VS Code showing a Python file with a merge conflict. The HEAD (current change) block is highlighted green and the incoming change from main blue, with "Accept Current Change | Accept Incoming Change | Accept Both Changes | Compare Changes" links above. The terminal below shows the git merge main command reporting the conflict.
:width: 90%

A merge conflict in VS Code after `git merge main`. Choose **Accept Current**,
**Accept Incoming** or **Accept Both**, or edit the block by hand. Then save
the file.
```

Once every conflict is resolved:

```bash
git add <resolved-file>
git commit
```

[Lecture 2](../lectures/lecture_2.ipynb) discusses why notebook conflicts are
particularly painful.

---

### "`git pull` says my local changes would be overwritten"

You have uncommitted edits to files that the pull wants to update, which in the
course repository usually means a lecture notebook you re-ran. Either discard
them (`git restore <file>`), or park them with `git stash`, pull, and
`git stash pop`. See also
[Day 1 Setup → Getting updates](quickstart.md#getting-updates-to-the-course-material).

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

**The course repository (`fun_ds`)** is read-only for you:

1. Clone it once
2. `git pull` regularly to get updates
3. Experiment in `private_*` copies, which git ignores

**Your own and your group's repositories** (problem sets, project) are where
you practise the professional workflow:

1. Create a feature branch for each task
2. Commit small, focused changes frequently
3. Push regularly
4. Open Pull Requests and review each other's work
5. Keep `main` clean and working

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
