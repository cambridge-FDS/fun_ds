# Feature-engineering playground (Lecture 5)

A Streamlit app to try feature-engineering recipes on California Housing and see
their effect on 5-fold cross-validated RMSE, for a Ridge regression.
It uses the same recipes as the scoreboard in Lecture 5
(`fun_ds.features.build_fe_pipeline`), so numbers match the lecture.

```bash
pixi run fe-app          # opens http://localhost:8501
```

What it shows:

- **CV RMSE** of the current recipe, compared with the raw-column baseline.
- **What the model sees**: the eight raw columns, the steps in your recipe, and
  every column Ridge is fitted on, with its weight.
- **What a transformation does**: before/after histograms, spline bases and the
  learned curve, and maps of the geographic features.
- **Residual map** of out-of-fold errors: where the model still misses.
- **Attempt history**: every tweak is another look at the same folds.
- **Test set**: rationed to three submissions per session, to make the cost of
  peeking at test data tangible.

The challenge is Exercise 5.3 in Lecture 5.

Optional: to share it without a local environment, deploy to
[Streamlit Community Cloud](https://streamlit.io/cloud) from the GitHub
repository. Set the entry point to `apps/fe_playground/app.py` and add a
`requirements.txt` next to it containing `streamlit` and the package itself
(e.g. `fun_ds @ git+https://github.com/<org>/fun_ds`). This is not set up yet.
