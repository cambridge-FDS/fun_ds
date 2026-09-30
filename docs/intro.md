# Fundamentals of Data Science

Welcome to the online resource for **Fundamentals of Data Science**, the D100
module of the [MPhil in Economics and Data Science](https://www.econ.cam.ac.uk/apply/postgraduate/courses/mphil-data)
at the University of Cambridge.

The course introduces students to the fundamental concepts, techniques, and tools in data science. With a focus on end-to-end data science projects, the course is designed to equip students with the skills necessary for successful interviews and careers in the field. Students will learn to tackle real-world data problems, covering the entire spectrum from data acquisition and preprocessing to analysis, visualisation, statistical modelling, and considerations for moving models into production. As part of this course, students will also be equipped with valuable software engineering skills.

:::{note} About this book
This book grew out of the D100 lectures given in Michaelmas 2024 and 2025 and was set up
with the help of AI tools. It is meant to **complement the lectures, not
replace them**: the lectures, slides and problem sets remain the primary
course material (for now). If you spot an error, please let us know.
:::

---

## How to Use This Book

The material is organised as a **Jupyter Book**: every lecture is either a
Markdown page (Lecture 1) or a runnable Jupyter notebook (Lectures 2–9).
Read it in three complementary ways:

1. **Browse online.** Click through the sidebar; every internal reference,
   external URL, and citation is hyperlinked.
2. **Run locally.** Clone the repository and execute the notebooks in VS Code
   with the `pixi` environment (instructions below).
3. **Extend.** Complete the _Exercises_ at the end of each notebook and
   integrate them into your own portfolio repository.

:::{admonition} Where theory lives in this programme
:class: seealso
This course is **deliberately applied**. We build, evaluate, and deploy models —
but we defer formal statistical theory (convergence guarantees, asymptotic
distributions, causal identification) to D200 and D300 in Lent Term. If you find
yourself wanting the "why does this estimator work?" proof, that is by design:
this module gives you the practical intuition and working code, so the theory
lands when you encounter it next term.
:::

:::{admonition} Running the notebooks locally
:class: tip

```bash
git clone https://github.com/cambridge-FDS/fun_ds.git
cd fun_ds
pixi install   # environment + the fun_ds package (editable)
```

Open the `fun_ds` folder in VS Code, open any notebook under `docs/lectures/`
and select the pixi environment (`.pixi/envs/default`) as the kernel. New to
git, pixi or VS Code? The step-by-step [Day 1 Setup](setup/quickstart.md) takes
you from an empty laptop to a running notebook, with a check after every step.
:::

---

## Course Structure

The book is organised into two parts, each accessible from the sidebar:

| Part                                       | Content                                                   |
| ------------------------------------------ | --------------------------------------------------------- |
| **[Getting Started](setup/quickstart.md)** | Day 1 setup, environments, VS Code, Git, pre-commit hooks |
| **[Lectures 1–9](lectures/lecture_1.md)**  | The end-to-end data science lifecycle                     |

---

## Lectures at a Glance

Each lecture stands alone but the arc is cumulative: we build a single
housing-price regression model from data acquisition (L2) to deployment (L9).

| #                             | Topic                         | Key Concepts                          | Key Libraries                             |
| ----------------------------- | ----------------------------- | ------------------------------------- | ----------------------------------------- |
| [1](lectures/lecture_1.md)    | Workflow & Code Structure     | End-to-end pipeline, modular code     | `git`, `pyproject.toml`                   |
| [2](lectures/lecture_2.ipynb) | Data Wrangling                | Tidy data, joins, missing values      | `pandas`, `sqlite3`                       |
| [3](lectures/lecture_3.ipynb) | Data Retrieval & Storage      | File formats, databases, scale        | `polars`, `duckdb`, Parquet               |
| [4](lectures/lecture_4.ipynb) | Data Visualisation            | Grammar of graphics, EDA              | `matplotlib`, `seaborn`, `plotly`         |
| [5](lectures/lecture_5.ipynb) | Feature Engineering           | Pipelines, leakage, transformers      | `scikit-learn`, `ColumnTransformer`       |
| [6](lectures/lecture_6.ipynb) | Statistical Modelling I       | GLMs, cross-validation, CV strategies | `scikit-learn`                            |
| [7](lectures/lecture_7.ipynb) | Statistical Modelling II      | Regularisation, tuning, tabular FMs   | `scikit-learn`, `lightgbm`, `tabicl`      |
| [8](lectures/lecture_8.ipynb) | Evaluation & Interpretability | PDP, ALE, SHAP, EBM                   | `sklearn.inspection`, `shap`, `interpret` |
| [9](lectures/lecture_9.ipynb) | Deployment & Monitoring       | MLflow, ONNX, FastAPI, drift, CI/CD   | `mlflow`, `onnx`, `fastapi`               |

---

## The `fun_ds` Package

Throughout the lectures we use a shared Python library,
[`fun_ds`](https://github.com/cambridge-FDS/fun_ds), to demonstrate how
notebook code evolves into a reusable, tested package. All lectures import
helpers such as `fun_ds.data.load_california_housing()` and
`fun_ds.plotting.set_lecture_style()` so that setup boilerplate is
identical across notebooks.

It is installed in editable mode by `pixi install` (see
[Day 1 Setup, Step 5](setup/quickstart.md#step-5-install-the-course-environment)),
so any change you make under `src/fun_ds/` is picked up by the notebooks
immediately.

---

## Programme Context

Fundamentals of Data Science is taught in **Michaelmas Term** and precedes
D200 (_Machine Learning in Economics_) and D300 (_Causal Inference and
Machine Learning_) in Lent Term. This book emphasises the **applied
groundwork** that students need before those courses: how to build,
evaluate, and deploy a model, and how cross-validation and regularisation
work in practice. D200 and D300 supply the theoretical deepening.

## License

The book content is licensed under
[CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/). The `fun_ds`
Python package is released under the MIT license.
