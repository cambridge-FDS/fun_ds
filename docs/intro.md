# Fundamentals of Data Science

Welcome to the online resource for **Fundamentals of Data Science**, the D100
module of the [MPhil in Economics and Data Science](https://www.econ.cam.ac.uk/apply/postgraduate/courses/mphil-data)
at the University of Cambridge.

The course equips students with the concepts, techniques, and engineering
skills required to run a data-science project from end to end. The emphasis
is applied — every lecture ties a statistical or computational idea to a
piece of working, testable code — while remaining academically rigorous
about the underlying theory {cite}`hastie2009elements,james2021introduction`.

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

:::{admonition} Running the notebooks locally
:class: tip

```bash
git clone https://github.com/cambridge-FDS/fun_ds.git
cd fun_ds
pixi install
pixi run install
```

Open any notebook under `docs/lectures/` in VS Code and select the `pixi`
Python environment as the kernel. See the [Getting Started](setup/environment_manager.md)
section for a full walkthrough.
:::

---

## Course Structure

The book is organised into three parts, each accessible from the sidebar:

| Part                                                | Content                                                    |
| --------------------------------------------------- | ---------------------------------------------------------- |
| **[Getting Started](setup/environment_manager.md)** | Environment management, Git, VS Code, and pre-commit hooks |
| **[Lectures 1–9](lectures/lecture_1.md)**           | The end-to-end data science lifecycle                      |
| **[Software Engineering](swe/memory_profiling.md)** | Practical SWE tooling for data scientists                  |

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
| [7](lectures/lecture_7.ipynb) | Statistical Modelling II      | Regularisation, tuning, tabular FMs   | `scikit-learn`, `lightgbm`, `tabpfn`      |
| [8](lectures/lecture_8.ipynb) | Evaluation & Interpretability | PDP, ALE, SHAP, EBM                   | `sklearn.inspection`, `shap`, `interpret` |
| [9](lectures/lecture_9.ipynb) | Deployment & Monitoring       | MLflow, ONNX, FastAPI, drift, CI/CD   | `mlflow`, `onnx`, `fastapi`               |

---

## The `fun_ds` Package

Throughout the lectures we use a shared Python library,
[`fun_ds`](https://github.com/cambridge-FDS/fun_ds), to demonstrate how
notebook code evolves into a reusable, tested package. All lectures import
helpers such as {py:func}`fun_ds.data.load_california_housing` and
{py:func}`fun_ds.plotting.set_lecture_style` so that setup boilerplate is
identical across notebooks.

Install it in editable mode:

```bash
pixi install
pixi run install
```

---

## Programme Context

Fundamentals of Data Science is taught in **Michaelmas Term** and precedes
D200 (_Machine Learning in Economics_) and D300 (_Causal Inference and
Machine Learning_) in Lent Term. This book emphasises the **applied
groundwork** that students need before those courses: how to build,
evaluate, and deploy a model, and how cross-validation and regularisation
work in practice. D200 and D300 supply the theoretical deepening.

## Citing this Book

If you refer to this book in your work, please cite it as:

> Ochs, A. and Roerig, C. (2024–2025). _Fundamentals of Data Science_.
> University of Cambridge, MPhil in Economics and Data Science.
> [https://github.com/cambridge-FDS/fun_ds](https://github.com/cambridge-FDS/fun_ds)

## License

This material is licensed under
[CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/). The `fun_ds`
Python package is released under the MIT license.
