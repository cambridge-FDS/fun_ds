Pre-commit Hooks for Data Science Projects
========================================================

This guide explains how to set up **pre-commit hooks** for data science projects and why they are an important part of a professional workflow.

We focus on a **popular, battle-tested default configuration** that works well for:

* Python scripts
* Jupyter notebooks
* Data science repositories
* Student projects and team collaboration

.. note::
   Pre-commit hooks are **not about policing you**.
   They are about catching small issues *early*, automatically, before they turn into bugs, style debates, or broken submissions.

------------------------------------------------------------
What Are Pre-commit Hooks?
------------------------------------------------------------

A *pre-commit hook* is a script that runs **automatically before a Git commit is created**.

Typical tasks include:

* formatting code
* checking for syntax errors
* removing trailing whitespace
* preventing large or sensitive files from being committed
* enforcing consistent style

If a hook fails, the commit is **blocked** until the issue is fixed.

------------------------------------------------------------
Why Use Pre-commit in This Course?
------------------------------------------------------------

Using pre-commit helps with:

**Code Quality**
   Ensures clean, readable code without relying on manual checks.

**Reproducibility**
   Reduces hidden formatting and syntax issues that break notebooks or scripts.

**Collaboration**
   Everyone follows the same rules automatically.

**Reduced Friction**
   No arguments about formatting or style—tools decide.

**Industry Practice**
   Pre-commit is widely used in professional Python projects.

.. tip::
   Think of pre-commit as an automated “last sanity check” before code leaves your machine.

------------------------------------------------------------
Installing pre-commit
------------------------------------------------------------

Install pre-commit **inside your project environment** (recommended):

.. code-block:: bash

   pixi add pre-commit
   # or, if you are not using pixi:
   pip install pre-commit

Verify installation:

.. code-block:: bash

   pre-commit --version

------------------------------------------------------------
Basic Setup
------------------------------------------------------------

In the root of your Git repository, create a file named:

.. code-block:: text

   .pre-commit-config.yaml

This file defines which hooks run and how.

Then install the hooks:

.. code-block:: bash

   pre-commit install

This sets up Git so hooks run automatically on every commit.

------------------------------------------------------------
Recommended Default Configuration
------------------------------------------------------------

Below is a **popular, sensible default** for Python + data science projects.

It uses widely adopted tools and avoids overly strict rules.

.. code-block:: yaml

   repos:
     # General hygiene checks
     - repo: https://github.com/pre-commit/pre-commit-hooks
       rev: v4.6.0
       hooks:
         - id: trailing-whitespace
         - id: end-of-file-fixer
         - id: check-yaml
         - id: check-json
         - id: check-merge-conflict
         - id: check-added-large-files

     # Python code formatting
     - repo: https://github.com/psf/black
       rev: 24.8.0
       hooks:
         - id: black
           language_version: python3

     # Python linting (fast, modern)
     - repo: https://github.com/astral-sh/ruff-pre-commit
       rev: v0.6.3
       hooks:
         - id: ruff
           args: [--fix]

     # Jupyter notebook cleanup
     - repo: https://github.com/kynan/nbstripout
       rev: 0.7.1
       hooks:
         - id: nbstripout

------------------------------------------------------------
What Each Hook Does (Important!)
------------------------------------------------------------

General Hygiene Hooks
---------------------

These come from ``pre-commit-hooks`` and are extremely common.

``trailing-whitespace``
^^^^^^^^^^^^^^^^^^^^^^^

* Removes extra spaces at the end of lines
* Prevents noisy diffs and formatting clutter

Why it matters:
Trailing whitespace causes meaningless Git diffs and makes reviews harder.

``end-of-file-fixer``
^^^^^^^^^^^^^^^^^^^^^

* Ensures files end with a single newline

Why it matters:
Many tools expect this. Missing newlines can break POSIX tooling.

``check-yaml`` / ``check-json``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Verifies that YAML/JSON files are valid

Why it matters:
Configuration files fail silently when malformed.

``check-merge-conflict``
^^^^^^^^^^^^^^^^^^^^^^^^

* Fails if Git conflict markers are present:

.. code-block:: text

   <<<<<<< HEAD
   =======
   >>>>>>>

Why it matters:
This prevents committing broken files by accident.

``check-added-large-files``
^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Blocks committing very large files (default ~5MB)

Why it matters:
Large datasets and binaries **do not belong in Git**.
They should be stored externally or via data versioning tools.

------------------------------------------------------------
Python Formatting: Black
------------------------------------------------------------

``black``
^^^^^^^^^

* Formats Python code automatically
* Enforces a single, consistent style
* No configuration debates

Why it matters:
Formatting differences should never distract from logic or learning.

.. tip::
   If Black changes your code, **just accept it**.
   It is intentionally opinionated.

------------------------------------------------------------
Python Linting: Ruff
------------------------------------------------------------

``ruff``
^^^^^^^^

* Extremely fast Python linter
* Replaces many older tools (flake8, pyflakes, isort)
* Catches:
  - unused imports
  - undefined variables
  - common bugs
  - style issues

With ``--fix``:
* Automatically fixes safe issues (e.g. unused imports)

Why it matters:
Ruff catches mistakes that otherwise show up at runtime or grading time.

------------------------------------------------------------
Jupyter Notebooks: nbstripout
------------------------------------------------------------

``nbstripout``
^^^^^^^^^^^^^^

* Removes execution outputs from notebooks before committing
* Keeps:
  - code
  - markdown
* Removes:
  - cell outputs
  - large embedded data
  - execution counts

Why it matters:
Notebook outputs:
* bloat Git history
* cause merge conflicts
* make diffs unreadable

.. note::
   You can still see outputs locally.
   They just won’t be committed to Git.

------------------------------------------------------------
Using pre-commit in Practice
------------------------------------------------------------

Normal workflow:

.. code-block:: bash

   git add .
   git commit -m "My changes"

If hooks fail:

* Read the error message
* Fix the issue (often automatic)
* Re-run ``git commit``

Run hooks manually on all files:

.. code-block:: bash

   pre-commit run --all-files

.. tip::
   This is useful before pushing or submitting assignments.

------------------------------------------------------------
Common Questions
------------------------------------------------------------

“Can I bypass pre-commit?”
--------------------------

Yes (but avoid it):

.. code-block:: bash

   git commit --no-verify

Use this **only** if you know what you’re doing.

------------------------------------------------------------

“Will this slow me down?”
------------------------

No, in practice:

* Hooks run only on changed files
* Tools like Ruff are extremely fast
* You save time by avoiding later fixes

------------------------------------------------------------

“What if I disagree with a rule?”
---------------------------------

In this course:
* Use the defaults
* Focus on learning, not style debates

In real projects:
* Teams agree on rules **once**
* Automation enforces them consistently

------------------------------------------------------------
Recommended Workflow for This Course
------------------------------------------------------------

1. Install **pre-commit**
2. Add ``.pre-commit-config.yaml``
3. Run ``pre-commit install``
4. Commit normally
5. Let automation handle formatting and checks

------------------------------------------------------------
Final Recommendation
------------------------------------------------------------

For this course, we recommend:

* **pre-commit** for automation
* **Black** for formatting
* **Ruff** for linting
* **nbstripout** for notebooks
* **pre-commit-hooks** for basic hygiene

This setup reflects **modern professional data science practice** while remaining beginner-friendly.

------------------------------------------------------------
Further Reading
------------------------------------------------------------

* pre-commit documentation: https://pre-commit.com/
* Black formatter: https://black.readthedocs.io/
* Ruff linter: https://docs.astral.sh/ruff/
* nbstripout: https://github.com/kynan/nbstripout
