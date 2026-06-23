# Fundamentals of Data Science

Welcome to the online resource for **Fundamentals of Data Science**, part of the
MPhil in Economics and Data Science at the University of Cambridge.

This course teaches end-to-end data science with a strong software engineering
foundation. By the end you will be able to develop, deploy, and maintain
professional-grade data science projects.

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
