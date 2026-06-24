# Fundamentals of Data Science

Welcome to the online resource for **Fundamentals of Data Science**, part of the
MPhil in Economics and Data Science at the University of Cambridge.

This course introduces students to the fundamental concepts, techniques, and tools in data science. With a focus on end-to-end data science projects, the course is designed to equip students with the skills necessary for successful interviews and careers in the field. Students will learn to tackle real-world data problems, covering the entire spectrum from data acquisition and preprocessing to analysis, visualisation, statistical modelling, and considerations for moving models to production. As part of this course, students will also be equipped with valuable software engineering skills.

## Course Structure

The course is organised into three parts:

- **Getting Started** — Environment setup, Git, VS Code, and pre-commit hooks
- **Lectures** — Nine lectures covering the full data science lifecycle
- **Software Engineering** — Practical SWE skills for data scientists

## Lectures at a Glance

| # | Topic | Key Skills |
|---|-------|-----------|
| 1 | Data Science Workflow & Code Structure | Project organisation, modularity |
| 2 | Data Wrangling & Git | pandas, SQL, tidy data |
| 3 | Data Retrieval & Storage | File formats, databases, APIs |
| 4 | Data Visualisation | matplotlib, seaborn, plotly |
| 5 | Feature Engineering | Pipelines, custom transformers |
| 6 | Statistical Modelling | Cross-validation, hyperparameter tuning |
| 7 | Statistical Modelling (cont.) | Model composition, custom losses |
| 8 | Evaluation & Interpretability | SHAP, PDP, ALE |
| 9 | Model Tracking & Deployment | MLflow, ONNX, FastAPI |

:::{admonition} Running the notebooks
:class: tip
The best way to follow along is to clone the repository and run the notebooks in your IDE:

```bash
git clone https://github.com/cambridge-FDS/fun_ds.git
cd fun_ds
pixi install
pixi run install
```

Then open any notebook under `docs/lectures/` in VS Code and select the `pixi` environment as the kernel.
:::

## The `fun_ds` Package

Throughout the lectures we use a shared Python library,
[`fun_ds`](https://github.com/cambridge-FDS/fun_ds), to demonstrate how
notebook code evolves into a reusable, tested package. Install it with:

```bash
pixi install
pixi run install
```

## License

This material is licensed under
[CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/).
