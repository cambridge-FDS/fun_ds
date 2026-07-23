# IDE: Visual Studio Code for Data Science

**Previous:** [Environments](environment_manager.md) | **Next:** [Git](git.md)

---

This course uses **Visual Studio Code (VS Code)** as the recommended editor for data science work.
VS Code strikes a good balance between simplicity and power: it works well for beginners while scaling to professional workflows.

This guide explains:

- why VS Code is a good choice
- how to set it up correctly
- which extensions to install
- best practices for data science projects

:::{note}
VS Code is _not_ an IDE in the traditional sense. Its functionality comes from extensions.
A good setup makes a huge difference in productivity and reduces friction during the course.
:::

---

## Why VS Code for Data Science?

VS Code is a strong default for data science because it:

- works on **Windows, macOS, and Linux**
- integrates well with **Python, Jupyter, Git, and terminals**
- handles notebooks **and** scripts in one place
- supports modern workflows (virtual environments, linters, formatters)
- is widely used in industry and research

Compared to alternatives:

- **Jupyter-only** setups are great for exploration but weak for larger projects
- **Heavy IDEs** (e.g. PyCharm) can be overwhelming for beginners
- **Text editors** lack notebook and debugging support

VS Code sits in the middle and is ideal for a fundamentals course.

---

## Basic Installation

1. Download VS Code from: https://code.visualstudio.com/
2. Install using default options
3. Start VS Code

After installation, open the **Command Palette**:

```text
Ctrl + Shift + P   (Windows/Linux)
Cmd  + Shift + P   (macOS)
```

You will use this frequently.

Extensions can also be installed from the terminal:

```bash
code --install-extension ms-python.python
code --install-extension ms-toolsai.jupyter
```

---

## Recommended Core Extensions

The following extensions are **strongly recommended** for this course.

### Python (mandatory)

**Extension name:** Python
**Publisher:** Microsoft

This is the most important extension. It provides:

- Python language support
- Code completion and type hints
- Debugging
- Test discovery
- Environment selection

Install it from the Extensions panel or via:

```text
Extensions → search for "Python" (by Microsoft)
```

:::{tip}
This extension automatically installs other required components when needed.
:::

### Jupyter (mandatory)

**Extension name:** Jupyter
**Publisher:** Microsoft

Provides:

- Native support for `.ipynb` notebooks
- Inline plots and outputs
- Variable explorer
- Notebook debugging

This allows you to work with notebooks **inside VS Code**, instead of switching to a browser.

---

## Environment & Reproducibility Support

### Selecting the Python Interpreter (for `.py` scripts)

The Python extension allows you to select the correct environment for scripts.

To select your environment:

```text
Ctrl/Cmd + Shift + P
→ Python: Select Interpreter
```

Choose the environment created via **pixi** or **micromamba**.

If the pixi environment is not listed, enter the path manually. It is located at:

```text
<project-root>/.pixi/envs/default/bin/python     (macOS/Linux)
<project-root>/.pixi/envs/default/python.exe     (Windows)
```

:::{warning}
If the wrong interpreter is selected, imports may fail even though packages are installed.
Always check the interpreter shown in the bottom status bar.
:::

### Selecting the Jupyter Kernel (for `.ipynb` notebooks)

Notebooks use a **kernel**, which is set separately from the script interpreter.

To select the kernel for a notebook:

1. Open a `.ipynb` file
2. Click the kernel selector in the **top-right corner** of the notebook (it shows the current kernel name, e.g. `Python 3`)
3. Choose **Select Another Kernel → Python Environments**
4. Pick the environment under `.pixi/envs/default/`

:::{tip}
The kernel selector and the interpreter selector are independent settings.
If your notebook imports fail, check the kernel — not just the interpreter.
:::

---

## Recommended Extensions for Code Quality

These extensions help you write **clean, readable, and consistent code**.

### Pylance (recommended)

**Publisher:** Microsoft

Provides:

- fast type checking
- better autocomplete
- improved error messages

Usually installed automatically with the Python extension.

### Black Formatter (recommended)

**Extension name:** Black Formatter
**Publisher:** Microsoft

Black is an opinionated code formatter that:

- enforces consistent formatting
- removes style debates
- is widely used in industry

After installing, enable format-on-save:

```text
Settings → Format On Save → enabled
```

And set Black as the default formatter for Python.

:::{tip}
Consistent formatting makes collaboration and grading easier.
:::

### Ruff (optional but recommended)

**Extension name:** Ruff
**Publisher:** Astral Software

Ruff is a very fast linter that replaces many older tools.

It detects:

- unused imports
- undefined variables
- common bugs
- style issues

Ruff works well alongside Black.

---

## Git & Version Control

### Git (built-in)

VS Code has Git support built in:

- file change tracking
- diffs
- commits
- branch management

You do **not** need a separate Git extension to start.

Recommended workflow:

- initialize Git once per project
- commit early and often
- commit notebooks only when they run top-to-bottom

### GitLens (optional)

**Extension name:** GitLens

Adds:

- blame information
- commit history per line
- better repository insights

Useful, but optional for beginners.

---

## Notebook-Specific Best Practices

VS Code notebooks support both exploration and structure.

Recommended habits:

- restart and run all cells before committing
- keep imports at the top
- avoid hidden state (cells that depend on execution order)
- prefer short, focused cells

:::{warning}
A notebook that only works after "magic clicking" cells is not reproducible.
Always check `Run All`.
:::

---

## Terminal Usage Inside VS Code

VS Code has an integrated terminal:

```text
View → Terminal
```

Use it to:

- run `pixi` commands
- install dependencies
- run scripts
- start Jupyter

:::{tip}
Using the integrated terminal ensures you are operating in the same project context as your editor.
:::

---

## Keyboard shortcuts that will save your life

Learning a handful of shortcuts pays for itself within a week. These are the ones every VS Code user should have in muscle memory:

| Shortcut (macOS)  | Shortcut (Windows/Linux) | What it does                              |
| ----------------- | ------------------------ | ----------------------------------------- |
| `Cmd + P`         | `Ctrl + P`               | Quick open — jump to any file by name     |
| `Cmd + Shift + P` | `Ctrl + Shift + P`       | Command Palette — run any VS Code command |
| `Cmd + B`         | `Ctrl + B`               | Toggle the sidebar                        |
| `Cmd + /`         | `Ctrl + /`               | Toggle line comment                       |
| `Cmd + D`         | `Ctrl + D`               | Select next occurrence (multi-cursor)     |
| `F2`              | `F2`                     | Rename symbol (across the whole project)  |
| `Cmd + .`         | `Ctrl + .`               | Quick fix / show code actions             |
| `Cmd + Shift + F` | `Ctrl + Shift + F`       | Search across all files                   |
| `Cmd + \``        | `Ctrl + \``              | Toggle the integrated terminal            |
| `Cmd + Shift + O` | `Ctrl + Shift + O`       | Go to symbol in file                      |

:::{tip}
Do **not** try to memorise these all at once. Learn `Cmd+P` and `Cmd+Shift+P` first — from there you can invoke everything else without memorising it.
:::

---

## AI inline suggestions (Claude / Copilot)

If you use an inline AI assistant such as **GitHub Copilot** or **Claude for VS Code**, you will see grey "ghost text" completions as you type. Accepting them is `Tab`. Used well, these tools speed up boilerplate significantly — repetitive plotting code, docstring stubs, unit-test scaffolding — and free you to think about _what_ your model does rather than the mechanics of typing it.

Used badly, they will confidently produce plausible-looking code that is subtly wrong. In a data science context that is _especially_ dangerous: a wrong plot type, a mis-aligned join, or an off-by-one index will not raise an error but will quietly corrupt your analysis.

The discipline is simple: **read every line of suggested code before you accept it**. Treat AI completions as suggestions from a fast but junior collaborator, not as ground truth. If you would not sign off on the code coming from a peer, do not sign off on it from an LLM.

---

## Debugger Basics

Most data science students never learn to use a real debugger and rely on `print()` forever. This works, until it doesn't. The moment your notebook has a bug three function calls deep inside a `pandas` `apply`, `print`-debugging becomes miserable. Learn the VS Code debugger — even a shallow familiarity pays huge dividends.

### Breakpoints

Click in the gutter to the left of a line number. A red dot appears — execution will pause there when you run in debug mode.

- **Run with debugger:** `F5` (or the "Run and Debug" panel on the left).
- **Continue to next breakpoint:** `F5` again.

### Stepping

Once paused, you have three fundamental controls:

- **Step Over (`F10`)** — run the current line, then pause on the next line in the same function. Use this most of the time.
- **Step Into (`F11`)** — descend into the function call on the current line. Use this when you suspect a bug lives _inside_ the function you are about to call.
- **Step Out (`Shift + F11`)** — finish the current function and pause at the caller. Use this when you've stepped into something and realised the bug is elsewhere.

### Watch variables

The **Variables** panel shows all locals at the current frame. To track a specific expression (say, `df["age"].isna().sum()`), add it to the **Watch** panel — it re-evaluates every time execution pauses. This is often faster than typing `print()` after each change.

### Conditional breakpoints

Right-click a breakpoint → **Edit Breakpoint** → set a condition, e.g. `i == 42` or `row["price"] < 0`. Execution only pauses when the condition is true. Indispensable for bugs that only manifest for a single row out of millions.

### Debugging notebooks

Jupyter notebooks in VS Code support the same debugger. Click the debug icon next to a cell, or use `Debug Cell` from the cell menu. Breakpoints work identically.

:::{tip}
The first hour you spend learning the debugger feels slow. Every hour after that, it saves you time. Do it in the first two weeks of the course.
:::

---

## Recommended Settings (Minimal)

You do **not** need heavy customization. The following are helpful defaults:

- enable format on save
- show whitespace
- enable Python linting

Example minimal settings snippet:

```json
{
  "editor.formatOnSave": true,
  "python.analysis.typeCheckingMode": "basic",
  "editor.renderWhitespace": "boundary"
}
```

### Project-level settings (`.vscode/settings.json`)

You can commit a `.vscode/settings.json` file to a project so all contributors share the same editor settings.
The course repository ships one — when you open the project in VS Code, these settings activate automatically.

This is how the course enforces consistent formatting and interpreter behaviour across everyone's machines.

---

## What You Should Avoid

- Installing Python packages globally
- Mixing `pip` installs with environment-managed installs
- Ignoring interpreter selection
- Using multiple editors for the same project
- Editing notebooks without re-running them

:::{warning}
Most "VS Code is broken" issues are actually **environment selection issues**.
Check the interpreter (bottom status bar) and the notebook kernel (top-right picker) before troubleshooting anything else.
:::

---

## Recommended Workflow for This Course

1. Install **VS Code**
2. Install extensions:
   - Python
   - Jupyter
   - Black Formatter
   - (Optional) Ruff
3. Clone or open the course project
4. Run `pixi install`
5. Select the correct Python interpreter (`.pixi/envs/default/`)
6. Select the correct Jupyter kernel when opening notebooks
7. Open notebooks or scripts and start working

---

## Final Recommendation

Use **VS Code + Python + Jupyter + pixi** as a coherent stack:

- VS Code: editor and UI
- Python extension: language support
- Jupyter extension: notebooks
- pixi: environments and reproducibility

This setup mirrors modern professional data science workflows while remaining accessible for beginners.

---

## Further Reading

- VS Code Python docs: https://code.visualstudio.com/docs/python/python-tutorial
- VS Code Jupyter docs: https://code.visualstudio.com/docs/datascience/jupyter-notebooks
- Black formatter: https://black.readthedocs.io/
- Ruff linter: https://docs.astral.sh/ruff/
