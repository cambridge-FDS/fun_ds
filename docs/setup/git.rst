GitHub and Git — A Practical Introduction for Data Science Students
===================================================================

This guide introduces **Git** (version control) and **GitHub** (a hosting and collaboration platform) from a **data science perspective**.
It focuses on the commands and workflows you will use most often, plus common mistakes to avoid.

.. note::
   You do **not** need to memorize everything.
   What matters is understanding the *ideas* and knowing where things go wrong.

------------------------------------------------------------
What Are Git and GitHub?
------------------------------------------------------------

**Git**
   A *version control system* that tracks changes to files over time.
   It lets you go back to previous versions, compare changes, and work safely.

**GitHub**
   A platform that hosts Git repositories and adds:
   * collaboration tools
   * issue tracking
   * pull requests
   * code review
   * CI/CD integration

.. tip::
   Git is the *engine*; GitHub is the *platform* built on top of it.

------------------------------------------------------------
Why Data Scientists Need Git
------------------------------------------------------------

Git is essential in data science because:

* experiments change constantly
* results must be reproducible
* collaboration is the norm
* notebooks and scripts evolve together
* mistakes are inevitable

With Git you can:

* track experiments over time
* collaborate without overwriting work
* understand *why* results changed
* recover from mistakes

------------------------------------------------------------
Basic Concepts (Mental Model)
------------------------------------------------------------

Repository
----------

A **repository** (repo) is a project tracked by Git.

It contains:
* code
* notebooks
* configuration files
* documentation

Local vs Remote
---------------

**Local repository**
   The copy on your machine.

**Remote repository**
   The copy on GitHub.

Changes move between them via **push** and **pull**.

Commit
------

A **commit** is a snapshot of your files at a point in time.

Think of it as:
* “Save with history”
* atomic and descriptive

Branch
------

A **branch** is an independent line of development.

You usually:
* keep ``main`` clean
* do work on feature branches

------------------------------------------------------------
Getting Started
------------------------------------------------------------

Check that Git is installed:

.. code-block:: bash

   git --version

Configure your identity (do this once):

.. code-block:: bash

   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"

.. note::
   This information appears in commit history.
   Use a professional name/email.

------------------------------------------------------------
Creating or Cloning a Repository
------------------------------------------------------------

Clone an existing repository:

.. code-block:: bash

   git clone https://github.com/username/repository.git
   cd repository

Create a new repository locally:

.. code-block:: bash

   git init

------------------------------------------------------------
The Core Git Workflow
------------------------------------------------------------

The three most important commands:

.. code-block:: bash

   git status
   git add
   git commit

Check status
------------

.. code-block:: bash

   git status

Shows:
* modified files
* staged files
* untracked files

Add files (stage)
-----------------

.. code-block:: bash

   git add file.py
   git add notebook.ipynb
   git add .

.. tip::
   ``git add .`` stages *everything* in the current directory.
   Use it carefully.

Commit changes
--------------

.. code-block:: bash

   git commit -m "Describe what you changed"

Good commit messages:
* are short
* explain *why*, not just *what*

Bad: fix

Good: Add feature engineering for housing model

------------------------------------------------------------
Working with GitHub (Remote)
------------------------------------------------------------

Add a remote (if needed):

.. code-block:: bash

   git remote add origin https://github.com/username/repository.git

Push commits:

.. code-block:: bash

   git push origin main

Pull updates:

.. code-block:: bash

   git pull origin main

------------------------------------------------------------
Branching (Highly Recommended)
------------------------------------------------------------

Create and switch to a branch:

.. code-block:: bash

   git checkout -b feature-cleaning

Work, commit, then push:

.. code-block:: bash

   git push -u origin feature-cleaning

Open a **Pull Request** on GitHub to merge into ``main``.

.. note::
   Pull Requests are not just for teams — they are excellent for reviewing your own work.

------------------------------------------------------------
Handling Notebooks (Important!)
------------------------------------------------------------

Jupyter notebooks need special care.

Best practices:

* restart kernel and run all cells before committing
* keep notebooks small and focused
* move reusable code into ``.py`` files
* avoid large outputs

.. warning::
   Notebook merge conflicts are painful.
   Tools like ``nbstripout`` help prevent this.

------------------------------------------------------------
Common Commands You Will Use Often
------------------------------------------------------------

View commit history:

.. code-block:: bash

   git log --oneline

See differences:

.. code-block:: bash

   git diff
   git diff --staged

Undo local changes (careful!):

.. code-block:: bash

   git checkout -- file.py

Unstage a file:

.. code-block:: bash

   git restore --staged file.py

------------------------------------------------------------
Common Gotchas (Read This!)
------------------------------------------------------------

“I forgot to commit”
--------------------

Your work is usually still there.

Check:

.. code-block:: bash

   git status

Then commit.

------------------------------------------------------------

“I committed the wrong thing”
-----------------------------

If not pushed yet:

.. code-block:: bash

   git commit --amend

------------------------------------------------------------

“I pushed secrets or data”
--------------------------

**This is serious.**

* Remove immediately
* Rotate credentials
* Inform the instructor / team

.. warning::
   Never commit:
   * passwords
   * API keys
   * large datasets
   * personal data

------------------------------------------------------------

“My repo is full of data”
-------------------------

Data does **not** belong in Git.

Use:
* external storage
* data versioning tools
* download scripts

------------------------------------------------------------
What Git Is Not
------------------------------------------------------------

Git is **not**:

* a backup system for large files
* a database
* a substitute for documentation

------------------------------------------------------------
Recommended Workflow for This Course
------------------------------------------------------------

1. Clone the course repository
2. Create a feature branch for each task
3. Commit frequently
4. Push regularly
5. Open Pull Requests for review
6. Keep ``main`` clean and working

------------------------------------------------------------
Final Advice
------------------------------------------------------------

* Use Git early, not at the end
* Commit small, meaningful changes
* Write clear commit messages
* Treat Git history as part of your work

.. tip::
   If something goes wrong, **do not panic**.
   Git is designed to help you recover.

------------------------------------------------------------
Further Reading
------------------------------------------------------------

* Git documentation: https://git-scm.com/doc
* GitHub Docs: https://docs.github.com/
* Pro Git (free book): https://git-scm.com/book/en/v2
