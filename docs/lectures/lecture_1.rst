Lecture 1: Data Science Workflow, Tech Setup, and Code Structure
================================================================

This lecture introduces the **end-to-end data science workflow**, the **technical setup** used throughout the course, and **best practices for structuring data science code**.

The emphasis is on **applied data science** with strong **software engineering discipline**. The goal is not only to build models, but to build **reliable, readable, reproducible systems**.

------------------------------------------------------------
Course Philosophy and Objectives
------------------------------------------------------------

This course is highly applied and builds on concepts from other modules
(econometrics, statistics, machine learning, research computing).

By the end of the course, you should be able to:

* develop and maintain a **professional-grade data science code base**
* work **collaboratively** on shared repositories
* turn theoretical ideas into **working, testable code**
* structure projects for **reproducibility**
* build a **data science portfolio** suitable for interviews
* approach real-world data science tasks with confidence

.. note::
   Applied does **not** mean superficial.
   You will implement concepts deeply, but always with practical purpose.

------------------------------------------------------------
Why Economists Make Strong Data Scientists
------------------------------------------------------------

Economics training provides **crucial intuition** that transfers directly to
modern machine learning and data science.

Data Models vs. Black Boxes
---------------------------

In traditional econometrics:

* we assume a **data-generating process**
* models are interpretable by construction
* evaluation focuses on goodness-of-fit and inference

In modern data science:

* models are often **black boxes**
* evaluation focuses on **predictive accuracy**
* causal interpretation is often secondary
* **software engineering skills** become critical

.. note::
   This distinction was famously articulated by Leo Breiman (2001) as
   *data modeling* vs *algorithmic modeling*.

Why Economic Intuition Matters
------------------------------

Economic intuition helps detect **invalid modeling assumptions**.

Example (out-of-sample reasoning):

* training data: housing prices in New York City
* target task: predict prices in Albany

An economist immediately recognizes:

* the markets are structurally different
* the data is **out of sample**
* predictions are unreliable, regardless of model accuracy

Another example:

* predicting crop loss in Colombia using historical weather data
* weather patterns are highly homogeneous
* there may be **no signal** to learn from

.. tip::
   Many ML failures are not algorithmic — they are **conceptual data mistakes**.

------------------------------------------------------------
What Do Data Scientists Do?
------------------------------------------------------------

Data scientists typically work on the following tasks:

* answering questions with data
* tracking and defining metrics
* automating business processes
* predicting outcomes
* running experiments (A/B tests)

In this course, we focus primarily on:

* **automation**
* **prediction**

------------------------------------------------------------
The Data Science Workflow
------------------------------------------------------------

A typical data science pipeline consists of:

1. evaluate the business question
2. find appropriate data
3. understand the data (EDA)
4. clean and transform the data
5. choose a model
6. engineer features
7. tune hyperparameters
8. evaluate the model
9. deploy the model

The pipeline is **iterative**, not linear.

.. note::
   Most real-world time is spent on **data**, not modeling.

------------------------------------------------------------
Why Code Structure Matters
------------------------------------------------------------

Your **code base should mirror the data science pipeline**.

Well-structured projects:

* are easier to understand
* are easier to debug
* are easier to extend
* are easier to collaborate on

------------------------------------------------------------
The Technology Stack
------------------------------------------------------------

This course uses the following core tools:

* **Python** — primary programming language
* **Jupyter Notebooks** — exploration and communication
* **Visual Studio Code** — development environment
* **Conda-style environments** — dependency management
* **Git & GitHub** — collaboration and version control

------------------------------------------------------------
Why Python?
------------------------------------------------------------

Python is used because:

* it is the dominant language in machine learning
* it has a vast ecosystem (NumPy, pandas, scikit-learn, PyTorch, etc.)
* it is a general-purpose language (not limited to analysis)
* it integrates well with production systems

.. note::
   The course focuses on **concepts**, not specific packages.
   Libraries change; principles persist.

------------------------------------------------------------
Ways to Execute Python Code
------------------------------------------------------------

Python can be executed in several ways:

* interactively in the terminal
* by running scripts
* via an interactive kernel (Jupyter)

Each has its place.

------------------------------------------------------------
Jupyter Notebooks — Strengths and Limitations
------------------------------------------------------------

Jupyter notebooks are excellent for:

* exploration
* visualization
* explanation

However, they are **not ideal** for building large, maintainable systems.

Common problems:

* hidden state (execution order matters)
* very long files
* poor integration with testing
* difficult code reviews
* hard-coded parameters
* missing environment specifications

.. warning::
   A notebook that only works after clicking cells in a specific order
   is **not reproducible**.

------------------------------------------------------------
The Case for Modular Code
------------------------------------------------------------

To solve these issues, we move from:

* monolithic notebooks

to:

* **modular Python packages**
* small, focused functions
* orchestration scripts

Benefits of functions:

1. reusability
2. modularity
3. readability
4. maintainability
5. testability
6. abstraction
7. collaboration

------------------------------------------------------------
From Notebook to Package
------------------------------------------------------------

A typical transformation:

* notebook → functions
* functions → modules
* modules → package
* package → orchestration script

To make this work, you need:

1. a ``__init__.py`` file in your source directory
2. a ``pyproject.toml`` file at the project root
3. to install your project as a package:

.. code-block:: bash

   pip install -e .

------------------------------------------------------------
Orchestration Scripts
------------------------------------------------------------

An orchestration script:

* runs the pipeline in the correct order
* separates *what runs often* from *one-off analysis*
* eliminates hidden notebook state

This solves many of the core notebook problems.

------------------------------------------------------------
Clean Code and Trust
------------------------------------------------------------

Good data science requires **trust in your code**.

Clean code:

* makes experiments meaningful
* reduces silent bugs
* allows confident refactoring
* supports collaboration

.. note::
   Experimentation is still science — but science requires reliability.

------------------------------------------------------------
Collaboration with Git and GitHub
------------------------------------------------------------

Data science is almost never done alone.

Git provides:

* version control
* history
* branching

GitHub provides:

* remote repositories
* collaboration
* pull requests
* code review

Typical workflow:

1. clone or fork a repository
2. create a branch
3. commit frequently
4. open a pull request
5. review and merge

.. tip::
   Version control is “undo” with memory.

------------------------------------------------------------
Key Takeaways
------------------------------------------------------------

* data science is an **engineering discipline**
* structure matters as much as models
* notebooks are a tool, not a foundation
* modular code enables trust and collaboration
* strong SWE skills amplify data science impact

------------------------------------------------------------
Looking Ahead
------------------------------------------------------------

Each lecture in this course dives deeply into **one part of the pipeline**.
Over time, we will build toward a repository structure that mirrors
professional, real-world data science systems.

You are not expected to master everything immediately —
the goal is **progressive refinement**.
