# Lecture 1: The Data Science Workflow and Code Structure

:::{admonition} Learning Objectives
:class: tip
After this lecture, you will be able to:

- Describe the end-to-end data science workflow and its iterative nature
- Explain why software engineering discipline is critical for reliable data science
- Distinguish Breiman's _data modelling_ and _algorithmic modelling_ cultures
- Transition from monolithic notebook code to modular Python packages
- Use Git and GitHub for collaborative, reproducible data science
  :::

This lecture sets the intellectual and technical foundation for the rest of
the course. Before we touch a dataset, we introduce the **end-to-end data
science workflow**, the **technology stack** used throughout the course, and
the **software engineering principles** that separate research code from
research infrastructure.

The overarching philosophy: the goal is not merely to _build models_ but to
build **reliable, readable, reproducible systems** in which models are one
component. This mirrors the perspective in
{cite:t}`huyen2022designing` and {cite:t}`sculley2015hidden`.

---

## Course Philosophy

This course is highly applied and builds on concepts introduced elsewhere in
the MPhil EDS programme (econometrics, statistics, research computing). Its
distinctive contribution is **turning theoretical ideas into working,
testable code** — the engineering skin around the statistical skeleton.

By the end of the course you should be able to:

- develop and maintain a **professional-grade data science code base**
- collaborate on shared repositories through Git and pull requests
- structure projects for **reproducibility** and **experimentation**
- deploy a trained model to a REST API and monitor it in production
- populate a **portfolio** suitable for interviews and internships

:::{note}
Applied does **not** mean superficial. You will implement concepts deeply,
but always with practical purpose. Where a theoretical result matters, we
cite the primary source.
:::

---

## Two Cultures of Statistical Modelling

Economics training equips you with sharp intuition about **when models
should be trusted**. The tension between econometric and machine-learning
worldviews was formalised by {cite:t}`breiman2001statistical` in his
famous "Two Cultures" essay.

### The data-modelling culture

- assumes a **data-generating process** ($Y = f(X, \varepsilon)$)
- estimates parameters that have **causal or structural** meaning
- evaluates via goodness-of-fit and inference (t-tests, confidence intervals)
- dominant in econometrics, biostatistics, and psychometrics

### The algorithmic-modelling culture

- treats $f$ as an **unknown black box** to be approximated
- evaluates via **out-of-sample predictive accuracy**
- makes weaker assumptions in exchange for weaker causal interpretation
- dominant in machine learning

Both cultures have their place. The prediction–causation distinction returns
throughout the MPhil EDS programme — D300 will re-open this discussion in
depth {cite}`breiman2001statistical`.

### Prediction, inference, and causation

For MPhil EDS students, the two-cultures framing has a sharper edge:
economists must simultaneously care about **prediction** ("what will $Y$
be?"), **inference** ("how confident are we in $\hat{\beta}$?"), and
**causation** ("what happens to $Y$ if we intervene on $X$?"). These are
distinct estimands with distinct requirements. {cite:t}`varian2014bigdata`
argues that machine-learning tools — regularisation, cross-validation,
ensembling — extend the econometrician's toolkit precisely because they
handle high-dimensional prediction problems where classical inference is
poorly conditioned. {cite:t}`mullainathan2017machine` sharpen the point by
distinguishing $\hat{Y}$-problems (prediction, where ML shines) from
$\hat{\beta}$-problems (causal inference, where identification strategies
still dominate). {cite:t}`athey2019machine` survey the resulting synthesis:
double/debiased machine learning, causal forests, and heterogeneous
treatment-effect estimators use ML for nuisance-parameter estimation while
preserving valid inference for the parameter of interest. Understanding
which estimand your project targets is a prerequisite to choosing an
appropriate method — a diagnostic that no cross-validation score can
substitute for.

:::{tip}
**Economic intuition catches conceptual failures early.** If your training
data is New York housing but you deploy the model in Albany, no
cross-validation score will save you — the deployment is _out of sample_.
Many ML failures are conceptual, not algorithmic.
:::

---

## What Data Scientists Actually Do

Data-science work typically spans:

- **Answering questions with data** — quick analyses that inform decisions
- **Tracking and defining metrics** — what does "success" mean here?
- **Automating business processes** — decisions that were previously manual
- **Predicting outcomes** — supervised learning in production
- **Running experiments** — A/B tests, causal identification of treatment effects

This course focuses on **automation** and **prediction**, which most
directly demand the engineering discipline we teach.

---

## The Data Science Workflow

A typical project passes through these stages:

```{mermaid}
flowchart LR
    A[Business question] --> B[Data acquisition]
    B --> C[EDA]
    C --> D[Cleaning & wrangling]
    D --> E[Feature engineering]
    E --> F[Model selection]
    F --> G[Hyperparameter tuning]
    G --> H[Evaluation]
    H --> I[Deployment]
    I --> J[Monitoring]
    J -.-> C
    H -.-> E
    F -.-> D
```

The pipeline is **iterative**, not linear: evaluation results reshape
feature engineering; monitoring reveals data drift and triggers a return to
cleaning. Each lecture in this course zooms into one stage of the pipeline
in depth.

:::{note}
Empirically, most real-world project time is spent on **data**, not on
modelling {cite}`kuhn2019feature`. Feature engineering (Lecture 5) is
therefore where much of the intellectual leverage lives.
:::

### The iterative nature of the workflow

The linear presentation above is a pedagogical convenience, not a
description of practice. Every mature process framework recognises that
data projects loop. The **CRISP-DM** process model (Cross-Industry Standard
Process for Data Mining, 1999) codifies six phases — business
understanding, data understanding, data preparation, modelling, evaluation,
deployment — connected by explicit backward arrows: evaluation feeds back
into business understanding, deployment feeds back into data understanding
when drift appears. Twenty-five years on, CRISP-DM remains the most widely
cited framework in industrial data-mining surveys, and its central insight
— that data projects _never terminate cleanly_ — is now embedded in the
MLOps literature. {cite:t}`huyen2022designing` argues that the design of an
ML system is dominated by the feedback loops between its stages: the
faster you can iterate from a monitoring signal back to a retrained model,
the more value the system creates. Treat the diagram in §4 as a _state
machine_ rather than a pipeline; the transitions you cannot short-circuit
in production determine your architecture.

### Reproducibility as an epistemological principle

Reproducibility is not a hygiene requirement bolted onto research — it is
constitutive of the knowledge claim. {cite:t}`wilson2017good` articulate a
set of "good enough" practices (version control, plain-text data,
scripted analyses, code review) that operationalise this principle for
working scientists; each practice makes it possible for a stranger, or
your future self, to arrive at the same conclusion from the same starting
point. The deeper argument goes back to Peter Naur's 1985 essay
[_Programming as Theory Building_](https://pages.cs.wisc.edu/~remzi/Naur.pdf).
Naur argues that a working program is only the visible surface of a
**theory** held in the minds of its authors — a mental model of the
problem domain, the design decisions taken, and the ones deliberately
rejected. When that theory is lost (the author leaves, the notes are
mislaid, the notebook is not runnable), the program becomes uninhabitable
even if it still executes: nobody can extend it without regressing to
guesswork. For data science this is doubly true, because the artefact is
not just code but the _joint state_ of code, data, and environment. A
reproducible project preserves the theory, not merely the outputs. This is
why we insist on version control, environment specification, and
tests-as-documentation from the first commit: they are the medium in which
scientific claims survive.

---

## Why Code Structure Matters as Much as Models

A well-structured code base is easier to understand, debug, extend, and
collaborate on. In practical terms this means the file layout **mirrors the
pipeline**:

```text
project/
├── data/               # raw and processed data (git-ignored if large)
├── notebooks/          # exploration and communication
├── src/mypkg/          # importable, testable Python package
│   ├── data.py         # loading & wrangling
│   ├── features.py     # feature engineering transformers
│   ├── models.py       # estimators and training loops
│   └── evaluation.py   # metrics and plots
├── scripts/            # orchestration entry points
├── tests/              # pytest test suite
├── pyproject.toml      # dependencies and package metadata
└── README.md
```

This structure is exactly how the `fun_ds` package accompanying this book
is organised. Compare with the "good enough practices"
of {cite:t}`wilson2017good` and the maxims of
{cite:t}`kernighan1999practice`.

---

## Technology Stack

| Tool                                                          | Role                                                                            |
| ------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| [Python](https://docs.python.org/3/)                          | Primary programming language                                                    |
| [Jupyter](https://jupyter.org/)                               | Exploratory analysis and communication                                          |
| [VS Code](https://code.visualstudio.com/)                     | Development environment (see [setup guide](../setup/vscode.md))                 |
| [Pixi](https://pixi.sh/) / conda                              | Reproducible environments (see [setup guide](../setup/environment_manager.md))  |
| [Git](https://git-scm.com/) and [GitHub](https://github.com/) | Version control and collaboration (see [setup guide](../setup/git.md))          |
| [pre-commit](https://pre-commit.com/)                         | Automated code quality checks (see [setup guide](../setup/pre-commit-hooks.md)) |

Python is the dominant language for machine learning because of its
ecosystem — NumPy {cite}`harris2020numpy`, pandas {cite}`mckinney2010pandas`,
scikit-learn {cite}`pedregosa2011scikit`, matplotlib {cite}`hunter2007matplotlib`,
and PyTorch — and its ability to bridge exploration and production.

:::{note}
The course focuses on **concepts**, not specific packages. Libraries change;
principles persist.
:::

---

## Jupyter Notebooks: Strengths and Limitations

Notebooks excel at **exploration, visualisation, and explanation**. They are
poor at building large, maintainable systems.

### Common failure modes

- **Hidden state** — cell order matters; the same notebook can produce
  different results depending on the sequence of executions
- **Very long files** with dozens of cells become unreviewable
- **Poor testing integration** — you cannot run `pytest` on a notebook
  cleanly
- **Hard-coded parameters** scattered throughout the file
- **Missing environment specification** — "it works on my machine"

:::{warning}
A notebook that only works after clicking cells in a specific order is
**not reproducible**.
:::

The remedy is **modular code**: notebooks call functions from an installed
package, rather than defining logic inline.

---

## From Notebook to Package

The transition is progressive:

```{mermaid}
flowchart LR
    N[Ad-hoc notebook] --> F[Extract functions]
    F --> M[Group into modules]
    M --> P[Package with pyproject.toml]
    P --> S[Orchestration script + tests]
```

### Benefits of functions

1. **Reusability** — call from any notebook or script
2. **Modularity** — one clear responsibility per function
3. **Readability** — named units are easier to reason about
4. **Testability** — pure functions can be tested in isolation
5. **Maintainability** — bug fixes propagate to every caller
6. **Abstraction** — hide implementation details behind an interface
7. **Collaboration** — clear seams reduce merge conflicts

### Making it a real package

Three ingredients:

1. an `__init__.py` in your source directory
2. a `pyproject.toml` at the project root
3. an editable install so imports resolve to your working copy:

```bash
pip install -e .
```

Once installed, any notebook can import your code:

```python
from mypkg.data import load_dataset
from mypkg.features import build_pipeline
```

:::{seealso}
See the [`fun_ds` package on GitHub](https://github.com/cambridge-FDS/fun_ds/tree/main/src/fun_ds)
for a minimal, working example. Notebooks in later lectures import from it directly.
:::

---

## Orchestration Scripts

An orchestration script (or _entry point_):

- runs the pipeline in the correct order (data → features → train → evaluate)
- separates **operational** logic (what runs on a schedule) from **exploratory**
  logic (what happens once during EDA)
- eliminates hidden notebook state

A typical `pyproject.toml` exposes it as a CLI command:

```toml
[project.scripts]
train = "mypkg.scripts.train:main"
```

Then anyone can run:

```bash
train --config configs/experiment_a.yaml
```

This is the seed of the deployment pipeline you will build in
[Lecture 9](lecture_9.ipynb).

---

## Clean Code and Trust

Good data science requires **trust in your code**:

- experiments must be **meaningful** — a bug can silently invalidate weeks of work
- refactoring must be **safe** — tests give you confidence to change
- collaborators must be able to read and extend your work

:::{note}
Experimentation is science — and science requires _reliability_. Half the
value of a test suite is that it lets you make bold changes without fear.
:::

---

## Collaboration with Git and GitHub

Data science is almost never done alone. Git provides local version control;
GitHub adds remote hosting, pull requests, and code review.

### The minimal workflow

```{mermaid}
flowchart LR
    C[Clone repo] --> B[Create branch]
    B --> W[Work & commit]
    W --> P[Push branch]
    P --> R[Open PR]
    R --> V[Code review]
    V --> M[Merge to main]
```

1. **Clone** or **fork** a repository
2. **Create a branch** for each unit of work (`git checkout -b feature/xyz`)
3. **Commit frequently** with descriptive messages
4. **Push** the branch and **open a pull request**
5. Iterate on **code review**, then merge

:::{tip}
Version control is "undo" with memory. The real value is not what it
prevents — it is the _confidence to experiment_ it enables.
:::

For an in-depth walkthrough, see [Lecture 2, §1](lecture_2.ipynb) and the
[Git setup guide](../setup/git.md).

### Code review as a social process

The pull request is a technical artefact, but the practice around it is a
**social** one. {cite:t}`kernighan1999practice` observe that programming is
fundamentally a communication act — first with the machine, and then, more
importantly, with the humans who will read the code afterwards. Code
review is where that second audience actually shows up. A good review
serves three overlapping purposes: it _catches bugs_ the author cannot see
because they wrote the code; it _transfers knowledge_ about the codebase
across the team, spreading the "theory of the program" more widely; and
it _establishes norms_ — how we name things, how we handle errors, what
counts as done. In a research group the payoff is compounded: reviewers
often catch statistical or scientific errors that would never be flagged
by automated tests. Ask for reviews early, keep pull requests small (a few
hundred lines is easier to reason about than a few thousand), and treat
review comments as questions about a shared object rather than judgements
of the author.

---

## FAIR Data Principles

The FAIR principles {cite}`wilkinson2016fair` — **Findable, Accessible,
Interoperable, Reusable** — provide a widely adopted rubric for the
stewardship of scientific data. Originally articulated for the life
sciences, they have been adopted by funding agencies, journals, and
research infrastructures across disciplines, including in economics and
the social sciences. For an MPhil project, the principles translate into
concrete decisions about how you name files, document schemas, and share
outputs:

- **Findable** — datasets carry globally unique, persistent identifiers
  (e.g. a DOI), and are indexed in a searchable resource with rich
  metadata.
- **Accessible** — the data (or an authenticated route to it) can be
  retrieved using a standardised, open protocol; metadata remain
  accessible even when the underlying data are restricted.
- **Interoperable** — data and metadata use formal, shared vocabularies
  and open formats (CSV, Parquet, JSON-LD) so that different tools can
  consume them without bespoke adapters.
- **Reusable** — data are richly described with provenance and released
  under a clear licence, so that others can legitimately build on the
  work.

FAIR is complementary to reproducibility: reproducibility asks whether
_your_ analysis can be re-executed; FAIR asks whether _others_ can build
on the resources your project produced. Applying both raises the marginal
value of every dataset your project curates.

---

## Try It Yourself

:::{admonition} Exercise 1.1 — Convert a notebook to a package
:class: tip
Take any notebook you have written previously (or a sample from
[Kaggle](https://www.kaggle.com/)). Refactor it as follows:

1. Move every function into a file `src/mypkg/utils.py`.
2. Add a `pyproject.toml` at the project root (use the `fun_ds` one as a template).
3. `pip install -e .`
4. Confirm you can `from mypkg.utils import <your function>` from a fresh notebook.
   Compare notebook length before and after: what has been simplified?
   :::

:::{admonition} Exercise 1.2 — Practice Git workflow
:class: tip

1. Fork the [`fun_ds` repository](https://github.com/cambridge-FDS/fun_ds).
2. Create a branch `feature/typos-<yourname>`.
3. Fix a typo you find (there will be some — send a PR!) and commit.
4. Push and open a pull request against `main`.
   This is the exact workflow used by every project in the course.
   :::

:::{admonition} Exercise 1.3 — Diagnose the pipeline
:class: tip
For each stage of the data-science workflow (§4), name **one thing** that
could go wrong and describe how you would notice. Focus on failures that
would not be caught by a passing test on training data.
:::

---

## Key Takeaways

:::{admonition} Key Takeaways
:class: important

- Data science is an **engineering discipline** as much as a statistical one.
- The **two cultures** {cite}`breiman2001statistical` frame the tension
  between causal econometrics and predictive ML; both matter.
- **Structure matters as much as models**: mirror the pipeline in the codebase.
- Notebooks are a **tool**, not a foundation — extract logic into a package.
- **Git and pull requests** are the operating system of collaboration.
- Strong SWE skills amplify data-science impact and make experiments trustworthy.
  :::

---

## Further Reading

- {cite:t}`breiman2001statistical` — The Two Cultures essay.
- {cite:t}`hastie2009elements` — canonical statistical learning textbook.
- {cite:t}`james2021introduction` — accessible companion to Hastie et al.
- {cite:t}`huyen2022designing` — end-to-end ML system design.
- {cite:t}`wilson2017good` — Good Enough Practices in Scientific Computing.
- Peter Naur, _[Programming as Theory Building](https://pages.cs.wisc.edu/~remzi/Naur.pdf)_ (1985).

## Looking Ahead

Each remaining lecture zooms into one stage of the pipeline. Over time, we
will build toward a full repository that mirrors a professional data-science
system — from data ingestion ([Lecture 2](lecture_2.ipynb)) to deployment
([Lecture 9](lecture_9.ipynb)). You are not expected to master everything
immediately; the goal is **progressive refinement**.
