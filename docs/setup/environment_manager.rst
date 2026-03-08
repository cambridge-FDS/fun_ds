Environment Management: micromamba and pixi
=============================================

This course uses Python packages (NumPy, pandas, scikit-learn, Jupyter, …). To keep your setup **reliable** and **reproducible**, we recommend using a modern environment manager instead of installing everything globally.

This guide explains two good options:

* **micromamba**: a fast, minimal Conda-compatible package manager
* **pixi**: a modern, lockfile-first environment manager (recommended)

.. note::
   If you are new to environments: an environment is an isolated set of packages and a specific Python version.
   This prevents “it works on my machine” problems and avoids conflicts between projects.

------------------------------------------------------------
Option A: micromamba
------------------------------------------------------------

What is micromamba?
-------------------

**micromamba** is a lightweight alternative to conda/mamba:

* Very fast dependency resolution
* Small installer footprint
* Uses the **conda-forge** ecosystem (huge package availability)
* Works well when you want a simple “conda-style” workflow

When to use micromamba
----------------------

Choose micromamba if:

* you already know conda environments
* you want a minimal tool that behaves like conda
* you don’t need project-level lockfiles and tasks

Installation
------------

Install micromamba using your platform’s instructions.

.. tip::
   You can usually install micromamba in a user directory and avoid needing admin rights.

After installation, ensure it’s available in your shell:

.. code-block:: bash

   micromamba --version

Shell initialization
--------------------

micromamba needs shell integration so that activation works properly:

.. code-block:: bash

   micromamba shell init -s bash -p ~/micromamba
   # Restart your shell after this

For zsh:

.. code-block:: bash

   micromamba shell init -s zsh -p ~/micromamba
   # Restart your shell after this

Creating an environment
-----------------------

Create an environment with a fixed Python version and core packages:

.. code-block:: bash

   micromamba create -n ds101 -c conda-forge python=3.11 numpy pandas scikit-learn matplotlib jupyterlab

Activate it:

.. code-block:: bash

   micromamba activate ds101

Check Python:

.. code-block:: bash

   python --version

Installing additional packages
------------------------------

.. code-block:: bash

   micromamba install -n ds101 -c conda-forge seaborn scipy

Exporting the environment
-------------------------

You can export an environment file for sharing:

.. code-block:: bash

   micromamba env export -n ds101 > environment.yml

.. warning::
   An ``environment.yml`` is often **not fully reproducible** over time because it can allow version drift.
   Two students creating an environment months apart may end up with different dependency versions.

------------------------------------------------------------
Option B: pixi (recommended)
------------------------------------------------------------

What is pixi?
-------------

**pixi** is a modern environment and project manager designed around:

* **Project-based workflows** (your environment “lives with” your project)
* **Lockfiles** for reproducibility
* Simple cross-platform setup (same project works on Windows/macOS/Linux)
* Optional **tasks** (run scripts like ``pixi run test`` / ``pixi run lab``)

pixi uses the conda-forge ecosystem as well, so you still get the same broad package availability.

Why we recommend pixi for this course
-------------------------------------

pixi is the best default for a class because it makes setups predictable:

* Students get **the same dependency versions** via the lockfile.
* Instructors can provide a single project folder that “just works”.
* Running commands is consistent across platforms.

In short: fewer installation issues and fewer “dependency mismatch” problems.

Installation
------------

Install pixi using your platform’s instructions.

Verify it works:

.. code-block:: bash

   pixi --version

Core concepts
-------------

pixi is project-first. The project contains:

* ``pixi.toml``: high-level dependency specification
* ``pixi.lock``: exact resolved versions (reproducibility)

A typical workflow is:

1. clone/download a course repository (containing ``pixi.toml``)
2. run ``pixi install``
3. run tools via ``pixi run …`` or enter the environment

Create a new project (example)
------------------------------

If you are starting from scratch:

.. code-block:: bash

   mkdir ds101
   cd ds101
   pixi init

Add dependencies:

.. code-block:: bash

   pixi add python=3.11 numpy pandas scikit-learn matplotlib jupyterlab

Install (resolve + create environment):

.. code-block:: bash

   pixi install

Run Python inside the environment:

.. code-block:: bash

   pixi run python --version

Starting JupyterLab via pixi
----------------------------

You can run JupyterLab without manual activation:

.. code-block:: bash

   pixi run jupyter lab

.. tip::
   This is great for a course: you don’t need to teach shell activation first.
   Students can just run one command.

Optional: use tasks for common commands
---------------------------------------

pixi can define tasks in ``pixi.toml`` so everyone uses the same commands.

Example ``pixi.toml`` snippet:

.. code-block:: toml

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

Then students can run:

.. code-block:: bash

   pixi run lab

Updating dependencies
---------------------

To update (e.g., during development):

.. code-block:: bash

   pixi update

.. note::
   If you are teaching a course, you typically update dependencies only when you intend to.
   The lockfile ensures students stay consistent.

Using an instructor-provided repository
---------------------------------------

If your instructor provides a folder with ``pixi.toml``:

.. code-block:: bash

   # inside the course project folder
   pixi install
   pixi run jupyter lab

------------------------------------------------------------
micromamba vs pixi (quick comparison)
------------------------------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 22 39 39

   * - Feature
     - micromamba
     - pixi
   * - Primary style
     - environment-first (conda-like)
     - project-first
   * - Reproducibility
     - good with discipline, but YAML can drift
     - excellent via lockfile
   * - Best for courses
     - workable
     - best (fewer “it doesn’t work” issues)
   * - Commands
     - create/activate/install
     - add/install/run
   * - Typical artifacts
     - ``environment.yml``
     - ``pixi.toml`` + ``pixi.lock``

------------------------------------------------------------
Final recommendation for this course
------------------------------------------------------------

We recommend **pixi**.

* It gives each project a **portable, reproducible environment**
* It reduces student setup issues
* It enables consistent commands (e.g., ``pixi run jupyter lab``)
* The lockfile makes debugging and grading easier because everyone runs the same versions

If you already use conda/mamba and prefer that style, **micromamba is a solid alternative**—but for a course setting, pixi’s project + lockfile workflow is the most reliable.

------------------------------------------------------------
Troubleshooting tips
------------------------------------------------------------

* If commands are not found, restart your terminal or ensure the tool is on your PATH.
* If installation fails due to network restrictions, try again on a different connection (campus VPN/firewall issues are common).
* If you are on Windows, prefer PowerShell or Windows Terminal and keep paths short (avoid deeply nested folders).

.. warning::
   Avoid mixing tools for the same project (e.g., don’t use pip globally and then expect your environment manager to “see” it).
   Always install packages via your chosen tool to keep the environment consistent.
