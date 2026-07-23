# Memory Profiling in Python with Memray

This guide introduces **memory profiling** and shows how to use **Memray** (by Bloomberg) to find:

- memory leaks (objects or buffers that stay alive unexpectedly)
- excessive allocations (hotspots that waste RAM)
- regressions (changes that increase memory usage over time)

Memray is particularly useful because it tracks allocations at a low level and can generate rich reports such as **flame graphs** and **tables**.

:::{note}
Memory profiling is different from timing profiling:

- Timing profiling asks: _Where is my code slow?_
- Memory profiling asks: _Where is my code allocating, retaining, or leaking memory?_
  :::

---

## When Should You Profile Memory?

Profile memory when you see:

- RAM usage continuously increasing in long-running jobs/services
- sudden OOM (out-of-memory) errors in pipelines
- large batch jobs that become slower over time due to swapping
- unexpected performance regressions after "small" changes
- notebook sessions that become sluggish after repeated runs

:::{tip}
A common pattern is: _"The code runs fine once, but gets worse each time I run the pipeline."_
That's often a sign of retained objects, caches, global state, or leaks in extensions.
:::

---

## Installing Memray

Install from PyPI:

```bash
pip install memray
```

Memray provides a CLI called `memray` and can also be invoked as a Python module.

:::{note}
If your course uses environments (pixi/micromamba/conda), install Memray into that environment so students run it consistently.
:::

---

## Core Workflow

The Memray workflow is typically:

1. **Record** allocations while running your program (produces a `.bin` file)
2. **Report** results using a reporter (HTML or terminal output)

The manpages summarize it like this: run `memray run` then use a reporter like `flamegraph` or `table`.

---

## Step 1: Record a Profile

Record allocations while executing a script:

```bash
python -m memray run -o memray-output.bin my_script.py
```

or equivalently:

```bash
memray run -o memray-output.bin my_script.py
```

This creates a binary capture file that reporters can analyze.

:::{tip}
Use a naming convention that includes the command or git commit, e.g.
`memray-train_rf-<commit>.bin` so you can compare runs over time.
:::

---

## Step 2: Create a Report

### Flame graph (HTML)

```bash
memray flamegraph memray-output.bin
```

This generates an HTML flame graph you can open in a browser.

What you'll see in the flame graph:

- each bar is a stack frame
- width indicates how much memory is attributed to that code path
- you can inspect hotspots by drilling into the largest frames

### Table report (terminal or file)

Memray also provides a `table` reporter to get a more compact overview. The CLI supports multiple reporter subcommands (e.g., `table`, `tree`, `summary`).

```bash
memray table memray-output.bin
```

---

## A Minimal Example to Profile

Create a file `allocate_demo.py`:

```python
import numpy as np

def allocate():
    x = []
    for _ in range(2000):
        x.append(np.ones((1000,), dtype=np.float64))
    return x

if __name__ == "__main__":
    allocate()
```

Run Memray:

```bash
python -m memray run -o demo.bin allocate_demo.py
memray flamegraph demo.bin
```

Then open the generated HTML and look for the call stacks allocating the arrays.

---

## Understanding Python Allocation Behavior

Python does not always allocate memory by calling the system allocator directly.
It uses internal allocators and memory pools for many small objects, and only sometimes calls `malloc/free` underneath. Memray's documentation explains these Python allocator layers and why they matter when interpreting profiles.

:::{warning}
"High memory usage" can be caused by:

- many allocations that are later freed (high churn)
- or allocations that remain live (retained/leaked)
  You need to distinguish _allocation rate_ vs _retained memory_.
  :::

---

## Finding Leaks vs. Finding Allocation Hotspots

### Allocation hotspots (wasteful churn)

Symptoms:

- memory spikes during a phase
- but returns to baseline later
- performance suffers due to allocator overhead

Strategy:

- use a flame graph at peak usage to find where most allocations happen
- refactor to reduce intermediate objects (vectorize, reuse buffers, batch operations)

### Leak / retention (memory grows and never returns)

Symptoms:

- memory usage increases over time and does not drop
- long-running services or repeated notebook execution gets worse

Strategy:

- look for allocations that stay alive "too long"
- check global caches, module-level state, logging handlers, references captured by closures

:::{note}
Memray's flamegraph documentation also describes a **temporal flame graph** mode, which visualizes memory usage over time and lets you explore time windows.
:::

---

## Using Memray in Tests (Preventing Regressions)

A very practical approach in real projects is: **treat memory usage like a testable constraint**.

Memray integrates well with pytest via the `pytest-memray` plugin:

```bash
pip install pytest-memray
pytest --memray tests/
```

This runs tests with Memray enabled and prints a memory report per test suite run.

### Leak-focused testing

pytest-memray can analyze allocations made during a test that are not freed by the end of the test body and fail if a threshold is exceeded.

:::{tip}
This is one of the cleanest ways to stop memory regressions early:

- add the plugin
- run it in CI
- set sensible thresholds for critical pipelines
  :::

---

## Practical Tips and Best Practices

1. Profile the smallest reproducible scenario

   - isolate one pipeline stage or one function
   - reduce dataset size while preserving behavior

2. Always save the `.bin` artifacts

   - they are useful for comparisons
   - store them with run metadata (command, commit hash, dataset slice)

3. Compare changes

   - run Memray before and after a refactor
   - confirm the hotspot actually moved or shrank

4. Don't optimize blindly

   - the biggest bar in a flame graph is your best first target

5. Be mindful of notebooks
   - re-running cells can retain references in hidden state
   - restart the kernel to check whether "leaks" persist

---

## Troubleshooting

### "Memray sees less than I expected"

That may be normal due to Python's allocator pooling of small objects. Understanding Python allocators helps interpret results correctly.

### "My report shows a lot of allocations in libraries"

Often true in data science (NumPy, pandas, BLAS, etc.).
The key question is: _why is your code calling those libraries that way?_

Try:

- reducing copies (avoid `df.copy()` unless needed)
- minimizing conversions between pandas/numpy
- reusing arrays/buffers where possible

---

## Further Reading

- Memray documentation: https://bloomberg.github.io/memray/
- Getting started guide: https://bloomberg.github.io/memray/getting_started.html
- Flame graph reporter (including temporal mode): https://bloomberg.github.io/memray/flamegraph.html
- Memray GitHub repository: https://github.com/bloomberg/memray
- pytest-memray: https://github.com/bloomberg/pytest-memray
