IDE: Visual Studio Code for Data Science
=======================================================

This course uses **Visual Studio Code (VS Code)** as the recommended editor for data science work.
VS Code strikes a good balance between simplicity and power: it works well for beginners while scaling to professional workflows.

This guide explains:

* why VS Code is a good choice
* how to set it up correctly
* which extensions to install
* best practices for data science projects

.. note::
   VS Code is *not* an IDE in the traditional sense. Its functionality comes from extensions.
   A good setup makes a huge difference in productivity and reduces friction during the course.

------------------------------------------------------------
Why VS Code for Data Science?
------------------------------------------------------------

VS Code is a strong default for data science because it:

* works on **Windows, macOS, and Linux**
* integrates well with **Python, Jupyter, Git, and terminals**
* handles notebooks **and** scripts in one place
* supports modern workflows (virtual environments, linters, formatters)
* is widely used in industry and research

Compared to alternatives:

* **Jupyter-only** setups are great for exploration but weak for larger projects
* **Heavy IDEs** (e.g. PyCharm) can be overwhelming for beginners
* **Text editors** lack notebook and debugging support

VS Code sits in the middle and is ideal for a fundamentals course.

------------------------------------------------------------
Basic Installation
------------------------------------------------------------

1. Download VS Code from: https://code.visualstudio.com/
2. Install using default options
3. Start VS Code

After installation, open the **Command Palette**:

.. code-block:: text

   Ctrl + Shift + P   (Windows/Linux)
   Cmd  + Shift + P   (macOS)

You will use this frequently.

------------------------------------------------------------
Recommended Core Extensions
------------------------------------------------------------

The following extensions are **strongly recommended** for this course.

Python (mandatory)
------------------

**Extension name:** Python
**Publisher:** Microsoft

This is the most important extension. It provides:

* Python language support
* Code completion and type hints
* Debugging
* Test discovery
* Environment selection

Install it from the Extensions panel or via:

.. code-block:: text

   Extensions → search for "Python" (by Microsoft)

.. tip::
   This extension automatically installs other required components when needed.

Jupyter (mandatory)
-------------------

**Extension name:** Jupyter
**Publisher:** Microsoft

Provides:

* Native support for ``.ipynb`` notebooks
* Inline plots and outputs
* Variable explorer
* Notebook debugging

This allows you to work with notebooks **inside VS Code**, instead of switching to a browser.

------------------------------------------------------------
Environment & Reproducibility Support
------------------------------------------------------------

Environment Selector (important)
--------------------------------

The Python extension allows you to select the correct environment.

To select your environment:

.. code-block:: text

   Ctrl/Cmd + Shift + P
   → Python: Select Interpreter

Choose the environment created via **pixi** or **micromamba**.

.. warning::
   If the wrong interpreter is selected, imports may fail even though packages are installed.
   Always check the interpreter shown in the bottom status bar.

------------------------------------------------------------
Recommended Extensions for Code Quality
------------------------------------------------------------

These extensions help you write **clean, readable, and consistent code**.

Pylance (recommended)
---------------------

**Publisher:** Microsoft

Provides:

* fast type checking
* better autocomplete
* improved error messages

Usually installed automatically with the Python extension.

Black Formatter (recommended)
------------------------------

**Extension name:** Black Formatter
**Publisher:** Microsoft

Black is an opinionated code formatter that:

* enforces consistent formatting
* removes style debates
* is widely used in industry

After installing, enable format-on-save:

.. code-block:: text

   Settings → Format On Save → enabled

And set Black as the default formatter for Python.

.. tip::
   Consistent formatting makes collaboration and grading easier.

Ruff (optional but recommended)
-------------------------------

**Extension name:** Ruff
**Publisher:** Astral Software

Ruff is a very fast linter that replaces many older tools.

It detects:

* unused imports
* undefined variables
* common bugs
* style issues

Ruff works well alongside Black.

------------------------------------------------------------
Git & Version Control
------------------------------------------------------------

Git (built-in)
--------------

VS Code has Git support built in:

* file change tracking
* diffs
* commits
* branch management

You do **not** need a separate Git extension to start.

Recommended workflow:

* initialize Git once per project
* commit early and often
* commit notebooks only when they run top-to-bottom

GitLens (optional)
------------------

**Extension name:** GitLens

Adds:

* blame information
* commit history per line
* better repository insights

Useful, but optional for beginners.

------------------------------------------------------------
Notebook-Specific Best Practices
------------------------------------------------------------

VS Code notebooks support both exploration and structure.

Recommended habits:

* restart and run all cells before committing
* keep imports at the top
* avoid hidden state (cells that depend on execution order)
* prefer short, focused cells

.. warning::
   A notebook that only works after “magic clicking” cells is not reproducible.
   Always check ``Run All``.

------------------------------------------------------------
Terminal Usage Inside VS Code
------------------------------------------------------------

VS Code has an integrated terminal:

.. code-block:: text

   View → Terminal

Use it to:

* run ``pixi`` commands
* install dependencies
* run scripts
* start Jupyter

.. tip::
   Using the integrated terminal ensures you are operating in the same project context as your editor.

------------------------------------------------------------
Recommended Settings (Minimal)
------------------------------------------------------------

You do **not** need heavy customization. The following are helpful defaults:

* enable format on save
* show whitespace
* enable Python linting

Example minimal settings snippet:

.. code-block:: json

   {
     "editor.formatOnSave": true,
     "python.analysis.typeCheckingMode": "basic",
     "editor.renderWhitespace": "boundary"
   }

------------------------------------------------------------
What You Should Avoid
------------------------------------------------------------

* Installing Python packages globally
* Mixing ``pip`` installs with environment-managed installs
* Ignoring interpreter selection
* Using multiple editors for the same project
* Editing notebooks without re-running them

.. warning::
   Most “VS Code is broken” issues are actually **environment selection issues**.

------------------------------------------------------------
Recommended Workflow for This Course
------------------------------------------------------------

1. Install **VS Code**
2. Install extensions:
   * Python
   * Jupyter
   * Black Formatter
   * (Optional) Ruff
3. Clone or open the course project
4. Run ``pixi install``
5. Select the correct Python interpreter
6. Open notebooks or scripts and start working

------------------------------------------------------------
Final Recommendation
------------------------------------------------------------

Use **VS Code + Python + Jupyter + pixi** as a coherent stack:

* VS Code: editor and UI
* Python extension: language support
* Jupyter extension: notebooks
* pixi: environments and reproducibility

This setup mirrors modern professional data science workflows while remaining accessible for beginners.

------------------------------------------------------------
Further Reading
------------------------------------------------------------

* VS Code Python docs: https://code.visualstudio.com/docs/python/python-tutorial
* VS Code Jupyter docs: https://code.visualstudio.com/docs/datascience/jupyter-notebooks
* Black formatter: https://black.readthedocs.io/
* Ruff linter: https://docs.astral.sh/ruff/
