Lecture 9: Model Tracking, Reproducibility and Deployment
=========================================================

In this lecture, we'll cover the essential steps that come after training a machine learning model: tracking experiments, ensuring reproducibility, and deploying models to production. These practices are crucial for transitioning from experimental notebooks to production-ready systems.


Model Tracking with MLFlow
--------------------------

Keeping Track of Your Models
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note::
    Keeping track of our models helps us in various aspects of our work as data scientists:

    **Reproducibility**
        Captures precise experiment details for reconstruction. You can return to any experiment weeks or months later and understand exactly what was done.

    **Performance Monitoring**
        Tracks model performance and drift over time. Essential for maintaining production systems.

    **Collaboration**
        Enables transparent, shareable model development. Team members can see what approaches have been tried and what worked best.

    **Experiment Management**
        Structures complex ML workflows systematically. No more "model_final_v3_actually_final.pkl" files scattered across your filesystem.

    **Deployment Governance**
        Maintains model lineage for auditing. Know exactly which model version is running in production and how it was trained.

    **Optimization**
        Provides empirical insights for rapid improvement. Compare different approaches systematically rather than relying on memory.

What is MLFlow?
^^^^^^^^^^^^^^^

MLFlow is an open-source platform that offers a backend and frontend for model storing and tracking. It provides:

* A central place to log experiments, parameters, and metrics
* Storage for trained models and their artifacts
* A user interface to visualize and compare experiments
* Tools for model versioning and deployment

While MLFlow offers support for deploying models, most corporate environments have custom deployment processes and quality gates. However, its tracking and storage capabilities are widely adopted across the industry.

MLFlow allows us to:

* Store runs with all their artifacts and metadata
* Keep track of different model runs and reproduce them
* Compare metrics between different model runs to have a clear improvement path

How to Log a Model to MLFlow
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Here's a complete example of training and logging a model with MLFlow:

.. code-block:: python

    import mlflow
    import mlflow.sklearn
    from sklearn.ensemble import RandomForestClassifier
    from sklearn.datasets import load_iris
    from sklearn.model_selection import train_test_split
    from sklearn.metrics import accuracy_score, f1_score, classification_report

    # Load and prepare data
    X, y = load_iris(return_X_y=True)
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    # Start an MLFlow run
    with mlflow.start_run(run_name="iris_random_forest_baseline"):
        # Log parameters
        n_estimators = 100
        max_depth = 5
        mlflow.log_param("n_estimators", n_estimators)
        mlflow.log_param("max_depth", max_depth)
        mlflow.log_param("random_state", 42)

        # Train the model
        model = RandomForestClassifier(
            n_estimators=n_estimators,
            max_depth=max_depth,
            random_state=42
        )
        model.fit(X_train, y_train)

        # Make predictions
        y_pred = model.predict(X_test)

        # Calculate and log metrics
        accuracy = accuracy_score(y_test, y_pred)
        f1 = f1_score(y_test, y_pred, average='weighted')

        mlflow.log_metric("accuracy", accuracy)
        mlflow.log_metric("f1_score", f1)

        # Log the trained model
        mlflow.sklearn.log_model(model, "model")

        print(f"Model logged with accuracy: {accuracy:.4f}")
        print(f"F1 Score: {f1:.4f}")

The ``mlflow.start_run()`` context manager creates a new run. Everything logged within this context is associated with that run. Key components:

* **Parameters** (``log_param``): Hyperparameters and configuration values used during training
* **Metrics** (``log_metric``): Performance measures like accuracy, F1 score, or loss
* **Models** (``log_model``): The trained model itself, stored in MLFlow's format

How to Store Generic Artifacts to MLFlow
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Beyond models and metrics, we often want to store additional artifacts like plots, confusion matrices, or feature importance rankings. MLFlow makes this easy with ``log_artifact`` and related functions:

.. code-block:: python

    import matplotlib.pyplot as plt
    from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay
    import tempfile
    import os

    with mlflow.start_run(run_name="iris_with_visualizations"):
        # ... train model as before ...

        # Create confusion matrix plot
        cm = confusion_matrix(y_test, y_pred)
        disp = ConfusionMatrixDisplay(confusion_matrix=cm,
                                      display_labels=["setosa", "versicolor", "virginica"])
        disp.plot(cmap='Blues')
        plt.title('Confusion Matrix')

        # Save plot to temporary file and log it
        with tempfile.TemporaryDirectory() as tmpdir:
            plot_path = os.path.join(tmpdir, "confusion_matrix.png")
            plt.savefig(plot_path, dpi=150, bbox_inches='tight')
            mlflow.log_artifact(plot_path, "plots")

        plt.close()

        # Log feature importances as JSON
        feature_names = load_iris().feature_names
        importances = model.feature_importances_
        importance_dict = {name: float(imp) for name, imp in zip(feature_names, importances)}
        mlflow.log_dict(importance_dict, "feature_importance.json")

        # Log classification report as text
        report = classification_report(y_test, y_pred,
                                      target_names=["setosa", "versicolor", "virginica"])
        mlflow.log_text(report, "classification_report.txt")

This example demonstrates:

* **``log_artifact``**: Logs a file (like a plot) to MLFlow
* **``log_dict``**: Logs a Python dictionary as JSON
* **``log_text``**: Logs text content directly

Artifacts are organized in folders within the run directory, making it easy to store and retrieve related files.

Running MLFlow Locally
^^^^^^^^^^^^^^^^^^^^^^^

MLFlow saves models by default in a local ``mlruns`` folder in your current working directory. To start the MLFlow UI:

.. code-block:: bash

    # Start UI in the same directory as your mlruns folder
    mlflow ui

    # Or specify a custom tracking URI
    mlflow ui --backend-store-uri /path/to/mlruns

    # Use a different port
    mlflow ui --port 5001

By default, the UI runs on ``http://localhost:5000``. Open this URL in your browser to explore your experiments.

If you saved runs somewhere else, provide the path:

.. code-block:: bash

    mlflow ui --backend-store-uri /path/to/model/folder

The MLFlow UI
^^^^^^^^^^^^^

The MLFlow UI provides a comprehensive interface for exploring your experiments:

**Main View**
    * Lists all experiments and their runs
    * Shows key metrics and parameters at a glance
    * Allows filtering and searching runs
    * Provides comparison tools for multiple runs

**Run Details Page**
    * Complete parameter list
    * All logged metrics with visualizations
    * Artifacts browser showing all stored files
    * Model information and metadata
    * System information (Python version, user, execution time)

**Comparison View**
    * Side-by-side comparison of multiple runs
    * Parallel coordinates plot for parameters
    * Scatter plots of metric relationships
    * Easy identification of best-performing configurations

Key features of the UI:

* **Search and Filter**: Find runs by name, parameter values, or metrics
* **Sorting**: Order runs by any metric or parameter
* **Tagging**: Add tags to organize runs (e.g., "baseline", "production", "experiment")
* **Notes**: Add markdown notes to document insights
* **Charts**: Visualize metrics over training steps or compare across runs

Predict from Stored Model
^^^^^^^^^^^^^^^^^^^^^^^^^^

Loading and using a logged model is straightforward. The MLFlow UI provides instructions under each model's artifacts section, but here's a complete example:

.. code-block:: python

    import mlflow
    import mlflow.sklearn
    from sklearn.datasets import load_iris

    # Load the iris dataset for testing
    X, y = load_iris(return_X_y=True)

    # Method 1: Load by run ID (get this from MLFlow UI)
    run_id = "a1b2c3d4e5f6g7h8i9j0"  # Replace with actual run ID
    model = mlflow.sklearn.load_model(f"runs:/{run_id}/model")

    # Method 2: Load from local file path
    model = mlflow.sklearn.load_model("mlruns/0/a1b2c3d4e5f6g7h8i9j0/artifacts/model")

    # Method 3: Load from Model Registry (if using registry)
    model = mlflow.sklearn.load_model("models:/iris_classifier/Production")

    # Make predictions
    predictions = model.predict(X[:5])
    print(f"Predictions: {predictions}")

    # Get prediction probabilities
    probabilities = model.predict_proba(X[:5])
    print(f"Probabilities:\n{probabilities}")

The loaded model is a fully functional scikit-learn model with all its methods available (``predict``, ``predict_proba``, etc.).

Common MLFlow Setups
^^^^^^^^^^^^^^^^^^^^

MLFlow supports various deployment scenarios, from individual development to enterprise production:

**Scenario 1: Local Development**
    * **Tracking**: Local filesystem (``mlruns/`` folder)
    * **Artifacts**: Local filesystem
    * **Use case**: Individual experimentation, prototyping
    * **Setup**: No configuration needed, works out of the box

**Scenario 2: Shared Team Server**
    * **Tracking**: Remote database (PostgreSQL, MySQL)
    * **Artifacts**: Cloud storage (S3, Azure Blob, GCS) or network storage
    * **Use case**: Team collaboration, shared experiments
    * **Setup**:

      .. code-block:: python

          import mlflow
          mlflow.set_tracking_uri("http://mlflow-server:5000")
          mlflow.set_experiment("team_experiments")

**Scenario 3: Production Environment**
    * **Tracking**: Remote database with authentication and encryption
    * **Artifacts**: Cloud storage with versioning and backup
    * **Model Registry**: Enabled with stage transitions (Staging → Production)
    * **Use case**: Enterprise deployment, compliance, auditing
    * **Features**: Role-based access control, audit logs, model lineage

Example configuration for remote tracking:

.. code-block:: python

    import mlflow
    import os

    # Set remote tracking server
    mlflow.set_tracking_uri("https://mlflow.company.com")

    # Set experiment (creates if doesn't exist)
    mlflow.set_experiment("fraud_detection_models")

    # Optional: Set credentials via environment variables
    os.environ["MLFLOW_TRACKING_USERNAME"] = "your_username"
    os.environ["MLFLOW_TRACKING_PASSWORD"] = "your_password"

    # Now all logging goes to the remote server
    with mlflow.start_run():
        mlflow.log_param("model_type", "xgboost")
        # ... rest of your code ...

Reproducibility
---------------

The Importance of Reproducibility
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note::
    Reproducibility of our trained models is crucial for several reasons:

    **Collaboration**
        Colleagues need to be able to reproduce your results. When someone says "I got 95% accuracy," others should be able to verify this claim.

    **Debugging**
        Being able to reproduce results helps with debugging as it establishes a ground truth. If results change unexpectedly, you know something has gone wrong.

    **Production**
        Models are often running in production for years and are expected to work consistently. A model that produces different results in different environments is unreliable.

    **Scientific Integrity**
        Reproducibility is fundamental to the scientific method. Your findings should be verifiable by others.

    Consider this scenario: You train a model in January, it performs well, and it's deployed to production. In June, you need to retrain it with new data. If you can't reproduce the original training process, you won't know if differences in performance are due to the new data, changes in your environment, or something else entirely.

Why Your Code Alone Does Not Guarantee Reproducibility
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Although active projects try to minimize breaking changes, they are a reality of software development. Even with identical code, results can differ due to:

.. warning::
    **Package Version Changes**
        Libraries update with breaking changes. A function that worked one way in version 1.0 might behave differently in version 2.0.

    **Dependency Updates**
        Indirect dependencies can change. Your code uses library A, which depends on library B. When B updates, your results might change.

    **Operating System Differences**
        Some operations have OS-specific implementations that can produce slightly different numerical results.

    **Hardware Differences**
        Different CPUs or GPUs can produce slightly different floating-point results due to different instruction sets.

    **Non-Deterministic Algorithms**
        Some algorithms have inherent randomness. Without proper seed setting, results vary between runs.

    **Data Mutations**
        If the underlying data has been modified, results will differ even with identical code.

Example of a real-world issue:

.. code-block:: python

    # This code worked perfectly in scikit-learn 0.24
    from sklearn.ensemble import RandomForestClassifier

    model = RandomForestClassifier(n_estimators=100, random_state=42)
    # ... training code ...

    # But in scikit-learn 1.0, the random number generation changed
    # Even with the same random_state, you get different results!
    # This is documented, but easy to miss

Ways to Persist Your Model
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Once we have a trained model, we typically want to persist it so that others, including our future self, can use it. We can split the options into environment-dependent and environment-independent approaches:

Environment-Dependent Formats
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Pickle and cloudpickle**

These are Python-specific serialization formats:

.. code-block:: python

    import pickle
    from sklearn.ensemble import RandomForestClassifier

    # Train a model
    model = RandomForestClassifier(n_estimators=100)
    model.fit(X_train, y_train)

    # Save with pickle
    with open('model.pkl', 'wb') as f:
        pickle.dump(model, f)

    # Load the model
    with open('model.pkl', 'rb') as f:
        loaded_model = pickle.load(f)

    # Make predictions
    predictions = loaded_model.predict(X_test)

**Advantages:**

* Simple and straightforward
* Fast serialization and deserialization
* Preserves complete Python object state
* Works with complex nested objects

**Disadvantages:**

* Requires Python environment
* No guarantee that model works as expected with different package versions
* Security risk: pickle can execute arbitrary code when loading
* Not portable across Python versions (Python 3.8 pickle may not work in Python 3.11)

To ensure reproducibility with pickle, you must use the exact same environment as during training. This is where conda-lock becomes essential.

Environment-Independent Formats
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**ONNX (Open Neural Network Exchange)**

ONNX is a binary serialization format that makes the model independent of any specific framework or package versions:

.. code-block:: python

    from skl2onnx import convert_sklearn
    from skl2onnx.common.data_types import FloatTensorType

    # Train a model
    model = RandomForestClassifier(n_estimators=100)
    model.fit(X_train, y_train)

    # Convert to ONNX
    initial_type = [('float_input', FloatTensorType([None, X_train.shape[1]]))]
    onnx_model = convert_sklearn(model, initial_types=initial_type)

    # Save ONNX model
    with open("model.onnx", "wb") as f:
        f.write(onnx_model.SerializeToString())

**Advantages:**

* No need for Python runtime
* Independent of package versions
* Can be used in different programming languages (C++, Java, JavaScript)
* Often more efficient for inference
* Industry standard for model exchange

**Disadvantages:**

* Not all model types are supported
* Conversion can sometimes fail or be complex
* Debugging is harder (no Python stack traces)
* May require additional configuration for complex models

Reproduce Your Model Training Environment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Compare the information in the following two environment files:

**environment.yml (Loose specification)**

.. code-block:: yaml

    name: datascience
    channels:
      - conda-forge
      - defaults
    dependencies:
      - python=3.9
      - scikit-learn
      - pandas
      - numpy
      - matplotlib
      - jupyter

This file specifies the packages you need but allows flexibility in versions. When someone creates an environment from this file, they might get different versions than you have, especially if time has passed.

**conda-lock.yml (Pinned specification)**

.. code-block:: yaml

    name: datascience
    channels:
      - conda-forge
      - defaults
    dependencies:
      - python=3.9.13
      - scikit-learn=1.1.2
      - pandas=1.4.3
      - numpy=1.23.1
      - matplotlib=3.5.2
      - jupyter=1.0.0
      - scipy=1.9.0
      - joblib=1.1.0
      - threadpoolctl=3.1.0
      # ... many more dependencies ...

This file pins every single package to a specific version, including all indirect dependencies. This ensures that everyone gets exactly the same environment.

To create a locked environment file:

.. code-block:: bash

    # Install conda-lock
    conda install -c conda-forge conda-lock

    # Generate lock file from environment.yml
    conda-lock -f environment.yml -p linux-64

    # This creates conda-lock.yml

    # To create environment from lock file:
    conda create -n myenv --file conda-lock.yml

MLFlow Stores a Pinned environment.yml for Us
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When logging a model, MLFlow automatically stores the specific environment used for training, so we can reproduce the model later on. This is one of MLFlow's most valuable features for reproducibility.

.. code-block:: python

    import mlflow
    import mlflow.sklearn
    from sklearn.ensemble import RandomForestClassifier

    with mlflow.start_run():
        model = RandomForestClassifier(n_estimators=100)
        model.fit(X_train, y_train)

        # MLFlow automatically captures:
        # - Python version
        # - All installed packages and their versions
        # - The model's dependencies
        mlflow.sklearn.log_model(model, "model")

After logging, navigate to your MLFlow run directory (e.g., ``mlruns/0/<run_id>/artifacts/model/``) and you'll find several files:

* ``MLmodel``: Metadata about the model
* ``model.pkl``: The pickled model
* ``conda.yaml``: Complete environment specification
* ``requirements.txt``: Pip requirements
* ``python_env.yaml``: Python version info

The ``conda.yaml`` file looks like this:

.. code-block:: yaml

    channels:
    - conda-forge
    - defaults
    dependencies:
    - python=3.9.13
    - pip<=23.1.2
    - pip:
      - mlflow==2.3.0
      - cloudpickle==2.2.1
      - scikit-learn==1.1.2
      - numpy==1.23.1
      - scipy==1.9.0
    name: mlflow-env

To recreate this exact environment:

.. code-block:: bash

    # Navigate to model directory
    cd mlruns/0/<run_id>/artifacts/model

    # Create environment from MLFlow's conda.yaml
    conda env create -f conda.yaml -n reproduced_env

    # Activate the environment
    conda activate reproduced_env

    # Now you can load and use the model with the exact same dependencies

What is ONNX?
^^^^^^^^^^^^^

Instead of keeping track of Python environments, we can convert the model to the ONNX format, which provides version independence.

**Definition:**

* Open-source file format for ML models
* Enables cross-framework interoperability (train in PyTorch, deploy in TensorFlow)
* Supports model transfer between frameworks
* Industry-standard format backed by Microsoft, Facebook, Amazon, and others

**Key Benefits:**

* **Simplifies model deployment**: No need to install heavy ML frameworks in production
* **Reduces framework lock-in**: Switch frameworks without retraining models
* **Optimizes model performance**: ONNX Runtime is highly optimized for inference
* **Language agnostic**: Use models in Python, C++, C#, Java, JavaScript, and more
* **Version independence**: Model works regardless of scikit-learn or TensorFlow version

Example use case: You train a model in Python with scikit-learn, convert it to ONNX, and deploy it in a C++ microservice for low-latency predictions. No Python runtime needed in production!

Key Concepts of ONNX
^^^^^^^^^^^^^^^^^^^^^

ONNX can be compared to a programming language specialized in mathematical functions. It defines all the necessary operations a machine learning model needs to implement its inference function with this language.

**Core Concepts:**

**Operators**
    Mathematical operations like MatMul (matrix multiplication), Add, Relu, Softmax, Conv (convolution), etc. These are the building blocks of ML models.

**Tensors**
    Multi-dimensional arrays that flow through the computation graph. These represent data, weights, and intermediate results.

**Nodes**
    Individual operations in the graph. Each node applies an operator to input tensors and produces output tensors.

**Graph**
    The complete computational graph representing the model. It's a directed acyclic graph (DAG) where nodes are operations and edges are tensors.

**Initializers**
    Constant tensors representing trained weights and biases. These are the learned parameters of your model.

Think of it like this: If Python is a general-purpose programming language, ONNX is a domain-specific language for describing mathematical computations in ML models.

The Graph Structure of ONNX
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

An ONNX model is represented as a computational graph. Here's what this means:

**Nodes (Operations)**
    Each node represents a mathematical operation:

    * ``MatMul``: Matrix multiplication
    * ``Add``: Element-wise addition
    * ``Relu``: Rectified Linear Unit activation
    * ``Softmax``: Softmax function for classification
    * ``Conv``: Convolution for image processing

**Edges (Tensors)**
    Edges connect nodes and represent data flowing through the model. Each edge carries a tensor (multi-dimensional array).

**Inputs**
    The entry points of the graph where input data enters.

**Outputs**
    The exit points where predictions emerge.

**Initializers**
    The weights and biases learned during training, stored as constant tensors.

Example: A simple neural network with one hidden layer would have:

.. code-block:: text

    Input (features)
      ↓
    MatMul (weights_1) → Add (bias_1) → Relu
      ↓
    MatMul (weights_2) → Add (bias_2) → Softmax
      ↓
    Output (predictions)

Each operation is a node, arrows are tensor edges, and ``weights_1``, ``weights_2``, ``bias_1``, ``bias_2`` are initializers.

Building an ONNX Graph - Example
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Let's build a simple ONNX model from scratch to understand the structure. We'll create a linear regression model: **y = 2x + 1**

.. code-block:: python

    import onnx
    from onnx import helper, TensorProto
    import numpy as np

    # Step 1: Define the input
    # Shape [None, 1] means batch size can vary, with 1 feature
    X = helper.make_tensor_value_info('X', TensorProto.FLOAT, [None, 1])

    # Step 2: Define the output
    Y = helper.make_tensor_value_info('Y', TensorProto.FLOAT, [None, 1])

    # Step 3: Define weights and bias as constant tensors (initializers)
    # Weight: 2.0
    W = helper.make_tensor(
        name='W',
        data_type=TensorProto.FLOAT,
        dims=[1, 1],
        vals=[2.0]
    )

    # Bias: 1.0
    b = helper.make_tensor(
        name='b',
        data_type=TensorProto.FLOAT,
        dims=[1],
        vals=[1.0]
    )

    # Step 4: Create computation nodes
    # Node 1: Matrix multiplication X * W
    matmul_node = helper.make_node(
        'MatMul',
        inputs=['X', 'W'],
        outputs=['XW'],
        name='matmul'
    )

    # Node 2: Add bias (XW + b)
    add_node = helper.make_node(
        'Add',
        inputs=['XW', 'b'],
        outputs=['Y'],
        name='add'
    )

    # Step 5: Create the graph
    graph = helper.make_graph(
        nodes=[matmul_node, add_node],
        name='LinearRegression',
        inputs=[X],
        outputs=[Y],
        initializer=[W, b]
    )

    # Step 6: Create the model
    model = helper.make_model(graph, producer_name='onnx-example')

    # Step 7: Check that the model is valid
    onnx.checker.check_model(model)

    # Step 8: Save the model
    onnx.save(model, 'linear_model.onnx')

    print("Model created and saved successfully!")

Now let's use this model for inference:

.. code-block:: python

    import onnxruntime as ort
    import numpy as np

    # Load the ONNX model
    session = ort.InferenceSession('linear_model.onnx')

    # Prepare input data
    X_test = np.array([[1.0], [2.0], [3.0], [4.0]], dtype=np.float32)

    # Get input name (must match what we defined)
    input_name = session.get_inputs()[0].name

    # Run inference
    outputs = session.run(None, {input_name: X_test})

    print("Input:")
    print(X_test)
    print("\nPredictions (y = 2x + 1):")
    print(outputs[0])

    # Expected output:
    # [[3.0], [5.0], [7.0], [9.0]]

This example demonstrates:

1. Creating an ONNX graph from scratch
2. Defining inputs, outputs, and parameters
3. Building computation nodes
4. Running inference with ONNX Runtime

Conversion of Scikit-Learn Model to ONNX
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Rather than building ONNX graphs manually, we typically convert existing models. Here's a complete workflow for converting a scikit-learn model:

**Step 1: Train a scikit-learn model**

.. code-block:: python

    from sklearn.datasets import load_iris
    from sklearn.model_selection import train_test_split
    from sklearn.ensemble import RandomForestClassifier
    import numpy as np

    # Load dataset
    X, y = load_iris(return_X_y=True)
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    # Train a Random Forest model
    model = RandomForestClassifier(
        n_estimators=10,
        max_depth=5,
        random_state=42
    )
    model.fit(X_train, y_train)

    # Get baseline predictions for comparison
    sklearn_predictions = model.predict(X_test)
    sklearn_probabilities = model.predict_proba(X_test)

    print(f"Sklearn accuracy: {model.score(X_test, y_test):.4f}")

**Step 2: Convert to ONNX**

.. code-block:: python

    from skl2onnx import convert_sklearn
    from skl2onnx.common.data_types import FloatTensorType

    # Define the input type
    # [None, 4] means batch size can vary, with 4 features (iris dataset)
    initial_type = [('float_input', FloatTensorType([None, X.shape[1]]))]

    # Convert the model to ONNX format
    onnx_model = convert_sklearn(
        model,
        initial_types=initial_type,
        target_opset=12  # ONNX opset version
    )

    # Save the ONNX model
    with open("iris_rf_model.onnx", "wb") as f:
        f.write(onnx_model.SerializeToString())

    print("Model converted and saved to iris_rf_model.onnx")

**Step 3: Load and use the ONNX model**

.. code-block:: python

    import onnxruntime as ort

    # Load the ONNX model
    session = ort.InferenceSession("iris_rf_model.onnx")

    # Get input and output names
    input_name = session.get_inputs()[0].name
    output_names = [output.name for output in session.get_outputs()]

    print(f"Input name: {input_name}")
    print(f"Output names: {output_names}")

    # ONNX requires float32 input
    X_test_float32 = X_test.astype(np.float32)

    # Run inference
    onnx_outputs = session.run(output_names, {input_name: X_test_float32})

    # onnx_outputs[0] contains class predictions
    # onnx_outputs[1] contains class probabilities
    onnx_predictions = onnx_outputs[0]
    onnx_probabilities = onnx_outputs[1]

    print(f"\nONNX predictions match sklearn: {np.array_equal(sklearn_predictions, onnx_predictions)}")
    print(f"ONNX probabilities match sklearn: {np.allclose(sklearn_probabilities, onnx_probabilities, rtol=1e-5)}")

**Step 4: Verify equivalence (important!)**

.. code-block:: python

    def verify_model_equivalence(sklearn_model, onnx_path, X_test):
        """
        Verify that ONNX model produces identical results to sklearn model
        """
        # Get sklearn predictions
        sklearn_pred = sklearn_model.predict(X_test)
        sklearn_proba = sklearn_model.predict_proba(X_test)

        # Get ONNX predictions
        session = ort.InferenceSession(onnx_path)
        input_name = session.get_inputs()[0].name
        X_test_float32 = X_test.astype(np.float32)
        onnx_outputs = session.run(None, {input_name: X_test_float32})
        onnx_pred = onnx_outputs[0]
        onnx_proba = onnx_outputs[1]

        # Check predictions
        pred_match = np.array_equal(sklearn_pred, onnx_pred)
        proba_match = np.allclose(sklearn_proba, onnx_proba, rtol=1e-5, atol=1e-8)

        print(f"✓ Predictions match: {pred_match}")
        print(f"✓ Probabilities match (within tolerance): {proba_match}")

        if not pred_match or not proba_match:
            print("❌ Warning: Models produce different results!")
            # Show first few differences
            if not pred_match:
                diff_idx = np.where(sklearn_pred != onnx_pred)[0][:5]
                print(f"Prediction differences at indices: {diff_idx}")
            if not proba_match:
                max_diff = np.max(np.abs(sklearn_proba - onnx_proba))
                print(f"Maximum probability difference: {max_diff}")

        return pred_match and proba_match

    # Run verification
    is_equivalent = verify_model_equivalence(model, "iris_rf_model.onnx", X_test)

**Step 5: Handle pipelines**

ONNX can also convert scikit-learn pipelines, which is very useful for production:

.. code-block:: python

    from sklearn.pipeline import Pipeline
    from sklearn.preprocessing import StandardScaler
    from sklearn.linear_model import LogisticRegression

    # Create a pipeline with preprocessing
    pipeline = Pipeline([
        ('scaler', StandardScaler()),
        ('classifier', LogisticRegression(max_iter=1000, random_state=42))
    ])

    # Train the pipeline
    pipeline.fit(X_train, y_train)

    # Convert entire pipeline to ONNX
    initial_type = [('float_input', FloatTensorType([None, X.shape[1]]))]
    onnx_pipeline = convert_sklearn(pipeline, initial_types=initial_type)

    # Save
    with open("iris_pipeline.onnx", "wb") as f:
        f.write(onnx_pipeline.SerializeToString())

    # Now both preprocessing and prediction happen in ONNX
    # No need to separately handle scaling in production!

The key advantages of ONNX conversion:

* **Version independence**: Works regardless of scikit-learn version
* **Performance**: ONNX Runtime is highly optimized
* **Portability**: Can be used in non-Python environments
* **Simplification**: Entire pipeline in one file

Deploying a Model
-----------------

Considerations for Production
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When deploying machine learning models to production, we must consider several critical factors beyond just model accuracy.

Performance and Accuracy
~~~~~~~~~~~~~~~~~~~~~~~~

**Validate Model on Unseen Data**

Before deployment, thoroughly test your model:

.. code-block:: python

    from sklearn.metrics import classification_report, confusion_matrix
    import numpy as np

    def validate_before_deployment(model, X_val, y_val):
        """
        Comprehensive validation before production deployment
        """
        predictions = model.predict(X_val)

        # Overall performance
        print("Classification Report:")
        print(classification_report(y_val, predictions))

        # Confusion matrix
        print("\nConfusion Matrix:")
        print(confusion_matrix(y_val, predictions))

        # Check prediction distribution
        unique, counts = np.unique(predictions, return_counts=True)
        pred_dist = dict(zip(unique, counts))
        true_dist = dict(zip(*np.unique(y_val, return_counts=True)))

        print("\nPrediction distribution:", pred_dist)
        print("True distribution:", true_dist)

        # Flag if prediction distribution is very different from training
        if len(pred_dist) < len(true_dist):
            print("⚠️  Warning: Model not predicting all classes!")

        # Check for worst-performing samples
        from sklearn.metrics import accuracy_score
        # Sample-wise accuracy (for classification)
        correct = predictions == y_val
        worst_idx = np.where(~correct)[0]
        print(f"\nMisclassified {len(worst_idx)} out of {len(y_val)} samples")

        return predictions

    # Use before deployment
    validate_before_deployment(model, X_test, y_test)

**Ensure Consistent Accuracy Across Scenarios**

Test edge cases and different data distributions:

.. code-block:: python

    def test_edge_cases(model, feature_ranges):
        """
        Test model behavior at feature boundaries
        """
        # Test with minimum values
        X_min = np.array([[r[0] for r in feature_ranges]])
        pred_min = model.predict(X_min)

        # Test with maximum values
        X_max = np.array([[r[1] for r in feature_ranges]])
        pred_max = model.predict(X_max)

        # Test with zeros
        X_zero = np.zeros((1, len(feature_ranges)))
        pred_zero = model.predict(X_zero)

        print(f"Prediction at min values: {pred_min}")
        print(f"Prediction at max values: {pred_max}")
        print(f"Prediction at zero: {pred_zero}")

        # Test with extreme values (potential adversarial)
        X_extreme = np.array([[r[1] * 10 for r in feature_ranges]])
        try:
            pred_extreme = model.predict(X_extreme)
            print(f"⚠️  Model accepts extreme values: {pred_extreme}")
        except:
            print("✓ Model rejects extreme values")

Scalability and Infrastructure
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Design Robust Computational Setup**

Consider your infrastructure needs:

* **CPU vs GPU**: Most scikit-learn models work well on CPU. Deep learning models may need GPU.
* **Memory requirements**: Large models or batch predictions need more RAM
* **Concurrent requests**: How many simultaneous users will you have?
* **Autoscaling**: Can your infrastructure scale up/down based on load?

**Optimize for Latency and Throughput**

Understanding the trade-offs:

* **Latency**: Time to process a single request (important for user-facing apps)
* **Throughput**: Number of requests processed per second (important for batch processing)
* **Trade-off**: Batch processing increases throughput but increases latency for individual requests

.. code-block:: python

    import time
    import numpy as np
    from sklearn.ensemble import RandomForestClassifier

    def benchmark_model(model, X_test, batch_sizes=[1, 10, 100]):
        """
        Benchmark model performance with different batch sizes
        """
        results = {}

        for batch_size in batch_sizes:
            latencies = []
            n_iterations = min(100, len(X_test) // batch_size)

            for i in range(n_iterations):
                # Get batch
                start_idx = (i * batch_size) % len(X_test)
                end_idx = start_idx + batch_size
                X_batch = X_test[start_idx:end_idx]

                # Measure time
                start = time.time()
                _ = model.predict(X_batch)
                elapsed = time.time() - start

                latencies.append(elapsed)

            mean_latency = np.mean(latencies)
            p95_latency = np.percentile(latencies, 95)
            throughput = batch_size / mean_latency

            results[batch_size] = {
                'mean_latency_ms': mean_latency * 1000,
                'p95_latency_ms': p95_latency * 1000,
                'throughput_per_sec': throughput
            }

            print(f"\nBatch size: {batch_size}")
            print(f"  Mean latency: {mean_latency*1000:.2f}ms")
            print(f"  95th percentile: {p95_latency*1000:.2f}ms")
            print(f"  Throughput: {throughput:.2f} predictions/second")

        return results

    # Example usage
    model = RandomForestClassifier(n_estimators=100)
    model.fit(X_train, y_train)
    benchmark_results = benchmark_model(model, X_test)

**ONNX Runtime Performance Benefits**

ONNX Runtime is often faster than native frameworks:

.. code-block:: python

    import time
    import onnxruntime as ort

    def compare_inference_speed(sklearn_model, onnx_path, X_test, n_runs=100):
        """
        Compare inference speed between sklearn and ONNX
        """
        X_test_float32 = X_test.astype(np.float32)

        # Benchmark sklearn
        sklearn_times = []
        for _ in range(n_runs):
            start = time.time()
            _ = sklearn_model.predict(X_test)
            sklearn_times.append(time.time() - start)

        # Benchmark ONNX
        session = ort.InferenceSession(onnx_path)
        input_name = session.get_inputs()[0].name
        onnx_times = []
        for _ in range(n_runs):
            start = time.time()
            _ = session.run(None, {input_name: X_test_float32})
            onnx_times.append(time.time() - start)

        sklearn_mean = np.mean(sklearn_times) * 1000
        onnx_mean = np.mean(onnx_times) * 1000
        speedup = sklearn_mean / onnx_mean

        print(f"Sklearn mean inference time: {sklearn_mean:.2f}ms")
        print(f"ONNX mean inference time: {onnx_mean:.2f}ms")
        print(f"ONNX is {speedup:.2f}x faster")

        return sklearn_mean, onnx_mean

Monitoring and Maintenance
~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Implement Real-Time Performance Tracking**

Production models need continuous monitoring:

.. code-block:: python

    import logging
    from datetime import datetime

    class ModelMonitor:
        """
        Simple monitoring for production models
        """
        def __init__(self, model_name):
            self.model_name = model_name
            self.predictions = []
            self.timestamps = []

            # Setup logging
            logging.basicConfig(
                filename=f'{model_name}_predictions.log',
                level=logging.INFO,
                format='%(asctime)s - %(message)s'
            )

        def log_prediction(self, input_data, prediction, confidence=None):
            """Log each prediction for monitoring"""
            timestamp = datetime.now()

            log_entry = {
                'timestamp': timestamp.isoformat(),
                'input': input_data.tolist() if hasattr(input_data, 'tolist') else input_data,
                'prediction': int(prediction) if hasattr(prediction, 'item') else prediction,
                'confidence': float(confidence) if confidence is not None else None
            }

            logging.info(log_entry)

            self.predictions.append(prediction)
            self.timestamps.append(timestamp)

        def get_prediction_distribution(self, last_n=1000):
            """Get distribution of recent predictions"""
            recent_preds = self.predictions[-last_n:]
            unique, counts = np.unique(recent_preds, return_counts=True)
            return dict(zip(unique, counts))

    # Usage
    monitor = ModelMonitor("iris_classifier")

    # When making predictions
    prediction = model.predict(X_test[:1])[0]
    proba = model.predict_proba(X_test[:1])[0]
    confidence = np.max(proba)

    monitor.log_prediction(X_test[0], prediction, confidence)

**Detect Data Drift and Model Degradation**

Data drift occurs when the production data distribution differs from training data:

.. code-block:: python

    from scipy.stats import ks_2samp
    import warnings

    def detect_data_drift(X_train, X_production, feature_names=None, threshold=0.05):
        """
        Detect if production data has drifted from training data using
        Kolmogorov-Smirnov test
        """
        n_features = X_train.shape[1]
        if feature_names is None:
            feature_names = [f'feature_{i}' for i in range(n_features)]

        drifted_features = []

        print("Data Drift Detection Report")
        print("=" * 60)

        for i in range(n_features):
            # Perform KS test
            statistic, pvalue = ks_2samp(X_train[:, i], X_production[:, i])

            drifted = pvalue < threshold
            if drifted:
                drifted_features.append(feature_names[i])

            status = "⚠️  DRIFT" if drifted else "✓ OK"
            print(f"{feature_names[i]:20s}: p-value={pvalue:.4f} {status}")

        print("=" * 60)
        if drifted_features:
            print(f"❌ Drift detected in {len(drifted_features)} features: {drifted_features}")
            print("   Consider retraining the model!")
        else:
            print("✓ No significant drift detected")

        return drifted_features

    # Usage - compare training data with recent production data
    # Assuming you've collected recent production inputs
    X_recent_production = np.array([...])  # Recent production data
    drifted = detect_data_drift(X_train, X_recent_production,
                               feature_names=['sepal_length', 'sepal_width',
                                            'petal_length', 'petal_width'])

**Monitor Model Performance**

If you have ground truth labels (eventually), track actual performance:

.. code-block:: python

    from sklearn.metrics import accuracy_score, f1_score
    from collections import deque

    class PerformanceMonitor:
        """
        Monitor model performance over time
        """
        def __init__(self, window_size=1000):
            self.window_size = window_size
            self.predictions = deque(maxlen=window_size)
            self.actuals = deque(maxlen=window_size)

        def add_result(self, prediction, actual):
            """Add a prediction-actual pair"""
            self.predictions.append(prediction)
            self.actuals.append(actual)

        def get_current_performance(self):
            """Calculate current performance metrics"""
            if len(self.predictions) < 10:
                return None

            accuracy = accuracy_score(self.actuals, self.predictions)
            f1 = f1_score(self.actuals, self.predictions, average='weighted')

            return {
                'accuracy': accuracy,
                'f1_score': f1,
                'n_samples': len(self.predictions)
            }

        def check_degradation(self, baseline_accuracy, threshold=0.05):
            """Alert if performance drops below threshold"""
            current = self.get_current_performance()
            if current is None:
                return False

            if current['accuracy'] < baseline_accuracy - threshold:
                print(f"⚠️  ALERT: Performance degradation detected!")
                print(f"   Baseline accuracy: {baseline_accuracy:.4f}")
                print(f"   Current accuracy: {current['accuracy']:.4f}")
                print(f"   Drop: {(baseline_accuracy - current['accuracy']):.4f}")
                return True

            return False

    # Usage
    perf_monitor = PerformanceMonitor()

    # As you get ground truth labels
    for pred, actual in zip(production_predictions, ground_truth_labels):
        perf_monitor.add_result(pred, actual)

        # Check every 100 samples
        if len(perf_monitor.predictions) % 100 == 0:
            perf_monitor.check_degradation(baseline_accuracy=0.95)

Test That Your Model Behavior Is the Same in Production
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Before deploying, it's critical to verify that your model behaves identically in the production environment as it did during development:

.. code-block:: python

    import numpy as np
    import pickle
    import onnxruntime as ort
    from skl2onnx import convert_sklearn
    from skl2onnx.common.data_types import FloatTensorType

    def comprehensive_production_test(model, X_test, y_test):
        """
        Test model equivalence across different serialization formats
        and ensure production-ready behavior
        """
        print("Production Readiness Test")
        print("=" * 60)

        # 1. Get baseline predictions
        sklearn_pred = model.predict(X_test)
        sklearn_proba = model.predict_proba(X_test)
        sklearn_accuracy = np.mean(sklearn_pred == y_test)

        print(f"✓ Baseline sklearn accuracy: {sklearn_accuracy:.4f}")

        # 2. Test pickle serialization
        with open('temp_model.pkl', 'wb') as f:
            pickle.dump(model, f)

        with open('temp_model.pkl', 'rb') as f:
            pickled_model = pickle.load(f)

        pickle_pred = pickled_model.predict(X_test)
        pickle_match = np.array_equal(sklearn_pred, pickle_pred)

        print(f"{'✓' if pickle_match else '❌'} Pickle predictions match: {pickle_match}")

        if not pickle_match:
            diff_count = np.sum(sklearn_pred != pickle_pred)
            print(f"   {diff_count} predictions differ!")
            return False

        # 3. Test ONNX conversion
        try:
            initial_type = [('float_input', FloatTensorType([None, X_test.shape[1]]))]
            onnx_model = convert_sklearn(model, initial_types=initial_type)

            with open('temp_model.onnx', 'wb') as f:
                f.write(onnx_model.SerializeToString())

            # Run ONNX inference
            session = ort.InferenceSession('temp_model.onnx')
            input_name = session.get_inputs()[0].name
            X_test_float32 = X_test.astype(np.float32)

            onnx_outputs = session.run(None, {input_name: X_test_float32})
            onnx_pred = onnx_outputs[0]
            onnx_proba = onnx_outputs[1]

            onnx_pred_match = np.array_equal(sklearn_pred, onnx_pred)
            onnx_proba_match = np.allclose(sklearn_proba, onnx_proba, rtol=1e-5, atol=1e-8)

            print(f"{'✓' if onnx_pred_match else '❌'} ONNX predictions match: {onnx_pred_match}")
            print(f"{'✓' if onnx_proba_match else '❌'} ONNX probabilities match: {onnx_proba_match}")

            if not onnx_pred_match:
                diff_count = np.sum(sklearn_pred != onnx_pred)
                print(f"   {diff_count} predictions differ!")
                return False

        except Exception as e:
            print(f"❌ ONNX conversion failed: {e}")
            print(f"   Model may not be suitable for ONNX deployment")

        # 4. Test with edge cases
        print("\nEdge Case Testing:")

        # Test with single sample
        single_pred = model.predict(X_test[:1])
        print(f"✓ Single sample prediction works: {single_pred[0]}")

        # Test with different batch sizes
        for batch_size in [1, 10, len(X_test)]:
            batch_pred = model.predict(X_test[:batch_size])
            print(f"✓ Batch size {batch_size} works: {len(batch_pred)} predictions")

        # 5. Clean up
        import os
        try:
            os.remove('temp_model.pkl')
            os.remove('temp_model.onnx')
        except:
            pass

        print("=" * 60)
        print("✓ All production tests passed!")
        return True

    # Run before deployment
    is_production_ready = comprehensive_production_test(model, X_test, y_test)

Simple Model Deployment Example
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To illustrate how a very simplistic model deployment could look like, we'll go through a complete example with five steps:

1. Build a simple linear regression model
2. Convert the model to ONNX
3. Create validation classes for Input and Output
4. Set up API for inference
5. Send a request and get a prediction

Step 1: Build Model
~~~~~~~~~~~~~~~~~~~~

First, let's create and train a simple linear regression model:

.. code-block:: python

    import numpy as np
    from sklearn.linear_model import LinearRegression
    from sklearn.model_selection import train_test_split
    from sklearn.metrics import mean_squared_error, r2_score

    # Generate synthetic dataset
    # y = 2*x1 + 3*x2 - 1*x3 + 0.5*x4 + 1*x5 + noise
    np.random.seed(42)
    n_samples = 1000
    n_features = 5

    X = np.random.rand(n_samples, n_features)
    true_coefficients = np.array([2.0, 3.0, -1.0, 0.5, 1.0])
    y = X @ true_coefficients + np.random.randn(n_samples) * 0.1

    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    # Train model
    model = LinearRegression()
    model.fit(X_train, y_train)

    # Evaluate
    y_pred = model.predict(X_test)
    mse = mean_squared_error(y_test, y_pred)
    r2 = r2_score(y_test, y_pred)

    print(f"Model trained successfully!")
    print(f"R² Score: {r2:.4f}")
    print(f"MSE: {mse:.4f}")
    print(f"\nLearned coefficients: {model.coef_}")
    print(f"True coefficients: {true_coefficients}")

Step 2: Convert Model to ONNX
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Convert the trained model to ONNX format for production deployment:

.. code-block:: python

    from skl2onnx import convert_sklearn
    from skl2onnx.common.data_types import FloatTensorType
    import onnxruntime as ort

    # Define input type
    initial_type = [('float_input', FloatTensorType([None, n_features]))]

    # Convert to ONNX
    onnx_model = convert_sklearn(model, initial_types=initial_type, target_opset=12)

    # Save ONNX model
    onnx_model_path = "linear_regression_model.onnx"
    with open(onnx_model_path, "wb") as f:
        f.write(onnx_model.SerializeToString())

    print(f"✓ Model converted to ONNX and saved to {onnx_model_path}")

    # Verify ONNX model works
    session = ort.InferenceSession(onnx_model_path)
    input_name = session.get_inputs()[0].name

    # Test prediction
    X_test_sample = X_test[:5].astype(np.float32)
    onnx_pred = session.run(None, {input_name: X_test_sample})[0]
    sklearn_pred = model.predict(X_test[:5])

    print(f"✓ ONNX predictions match sklearn: {np.allclose(onnx_pred.flatten(), sklearn_pred)}")

Step 3: Validate Input and Model Predictions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create Pydantic models to validate API inputs and outputs. This ensures type safety and provides automatic API documentation:

.. code-block:: python

    from pydantic import BaseModel, Field, validator
    from typing import List

    class PredictionInput(BaseModel):
        """
        Input data for prediction.
        Expects a list of 5 numerical features.
        """
        features: List[float] = Field(
            ...,
            min_items=5,
            max_items=5,
            description="List of 5 numerical features for prediction"
        )

        @validator('features')
        def validate_features(cls, v):
            """Validate that all features are valid numbers"""
            if len(v) != 5:
                raise ValueError(f"Expected 5 features, got {len(v)}")

            # Check for invalid values
            if any(np.isnan(x) or np.isinf(x) for x in v):
                raise ValueError("Features cannot contain NaN or Inf values")

            # Optional: Check reasonable ranges (domain-specific)
            if any(x < 0 or x > 1 for x in v):
                raise ValueError("Features should be in range [0, 1]")

            return v

        class Config:
            schema_extra = {
                "example": {
                    "features": [0.5, 0.3, 0.8, 0.2, 0.6]
                }
            }


    class PredictionOutput(BaseModel):
        """
        Prediction output from the model
        """
        prediction: float = Field(
            ...,
            description="Model prediction value"
        )
        model_version: str = Field(
            default="1.0.0",
            description="Version of the model used for prediction"
        )

        class Config:
            schema_extra = {
                "example": {
                    "prediction": 3.42,
                    "model_version": "1.0.0"
                }
            }


    class HealthCheck(BaseModel):
        """
        Health check response
        """
        status: str
        model_loaded: bool
        model_path: str

Step 4: Set Up API for Inference
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create a FastAPI application to serve the model:

.. code-block:: python

    from fastapi import FastAPI, HTTPException
    from fastapi.responses import JSONResponse
    import onnxruntime as ort
    import numpy as np
    from datetime import datetime

    # Initialize FastAPI app
    app = FastAPI(
        title="Linear Regression Model API",
        description="API for serving a linear regression model via ONNX Runtime",
        version="1.0.0"
    )

    # Global variables
    MODEL_PATH = "linear_regression_model.onnx"
    MODEL_VERSION = "1.0.0"
    session = None


    @app.on_event("startup")
    async def load_model():
        """Load ONNX model on startup"""
        global session
        try:
            session = ort.InferenceSession(MODEL_PATH)
            print(f"✓ Model loaded successfully from {MODEL_PATH}")
        except Exception as e:
            print(f"❌ Failed to load model: {e}")
            raise


    @app.get("/", response_model=HealthCheck)
    async def root():
        """Root endpoint with health check"""
        return {
            "status": "healthy" if session is not None else "unhealthy",
            "model_loaded": session is not None,
            "model_path": MODEL_PATH
        }


    @app.get("/health")
    async def health_check():
        """Detailed health check endpoint"""
        if session is None:
            raise HTTPException(status_code=503, detail="Model not loaded")

        return {
            "status": "healthy",
            "timestamp": datetime.now().isoformat(),
            "model_version": MODEL_VERSION,
            "model_inputs": [
                {"name": inp.name, "shape": inp.shape, "type": inp.type}
                for inp in session.get_inputs()
            ],
            "model_outputs": [
                {"name": out.name, "shape": out.shape, "type": out.type}
                for out in session.get_outputs()
            ]
        }


    @app.post("/predict", response_model=PredictionOutput)
    async def predict(input_data: PredictionInput):
        """
        Make a prediction using the loaded model

        Args:
            input_data: PredictionInput object with features

        Returns:
            PredictionOutput object with prediction and metadata
        """
        if session is None:
            raise HTTPException(status_code=503, detail="Model not loaded")

        try:
            # Prepare input
            X = np.array([input_data.features], dtype=np.float32)
            input_name = session.get_inputs()[0].name

            # Run inference
            prediction = session.run(None, {input_name: X})[0]

            # Return result
            return PredictionOutput(
                prediction=float(prediction[0]),
                model_version=MODEL_VERSION
            )

        except Exception as e:
            raise HTTPException(
                status_code=500,
                detail=f"Prediction failed: {str(e)}"
            )


    @app.post("/predict_batch")
    async def predict_batch(input_data: List[PredictionInput]):
        """
        Make predictions for multiple inputs

        Args:
            input_data: List of PredictionInput objects

        Returns:
            List of predictions
        """
        if session is None:
            raise HTTPException(status_code=503, detail="Model not loaded")

        if len(input_data) > 100:
            raise HTTPException(
                status_code=400,
                detail="Batch size too large. Maximum 100 samples."
            )

        try:
            # Prepare batch input
            X = np.array([item.features for item in input_data], dtype=np.float32)
            input_name = session.get_inputs()[0].name

            # Run inference
            predictions = session.run(None, {input_name: X})[0]

            # Return results
            return {
                "predictions": [
                    {
                        "prediction": float(pred),
                        "model_version": MODEL_VERSION
                    }
                    for pred in predictions
                ],
                "batch_size": len(predictions)
            }

        except Exception as e:
            raise HTTPException(
                status_code=500,
                detail=f"Batch prediction failed: {str(e)}"
            )

To run the API:

.. code-block:: bash

    # Install FastAPI and uvicorn if not already installed
    pip install fastapi uvicorn

    # Save the code to a file (e.g., api.py)
    # Run the server
    uvicorn api:app --host 0.0.0.0 --port 8000 --reload

    # The API will be available at http://localhost:8000
    # Interactive documentation at http://localhost:8000/docs

Step 5: Test It by Sending Requests to API
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now let's test our deployed model with various methods:

**Method 1: Using curl (command line)**

.. code-block:: bash

    # Health check
    curl http://localhost:8000/health

    # Single prediction
    curl -X POST "http://localhost:8000/predict" \
         -H "Content-Type: application/json" \
         -d '{"features": [0.5, 0.3, 0.8, 0.2, 0.6]}'

    # Expected output:
    # {"prediction": 3.45, "model_version": "1.0.0"}

**Method 2: Using Python requests library**

.. code-block:: python

    import requests
    import json

    # Base URL
    BASE_URL = "http://localhost:8000"

    # Test health check
    response = requests.get(f"{BASE_URL}/health")
    print("Health check:", response.json())

    # Test single prediction
    data = {
        "features": [0.5, 0.3, 0.8, 0.2, 0.6]
    }

    response = requests.post(
        f"{BASE_URL}/predict",
        headers={"Content-Type": "application/json"},
        data=json.dumps(data)
    )

    if response.status_code == 200:
        result = response.json()
        print(f"Prediction: {result['prediction']:.4f}")
        print(f"Model version: {result['model_version']}")
    else:
        print(f"Error: {response.status_code}")
        print(response.text)

    # Test batch prediction
    batch_data = [
        {"features": [0.1, 0.2, 0.3, 0.4, 0.5]},
        {"features": [0.6, 0.7, 0.8, 0.9, 0.1]},
        {"features": [0.2, 0.3, 0.4, 0.5, 0.6]}
    ]

    response = requests.post(
        f"{BASE_URL}/predict_batch",
        headers={"Content-Type": "application/json"},
        data=json.dumps(batch_data)
    )

    if response.status_code == 200:
        result = response.json()
        print(f"\nBatch predictions:")
        for i, pred in enumerate(result['predictions']):
            print(f"  Sample {i+1}: {pred['prediction']:.4f}")
    else:
        print(f"Error: {response.status_code}")
        print(response.text)

**Method 3: Comprehensive testing function**

.. code-block:: python

    def test_api_endpoints():
        """
        Comprehensive test of all API endpoints
        """
        import requests
        import json

        BASE_URL = "http://localhost:8000"

        print("API Testing Suite")
        print("=" * 60)

        # Test 1: Root endpoint
        print("\n1. Testing root endpoint...")
        try:
            response = requests.get(BASE_URL)
            assert response.status_code == 200
            data = response.json()
            assert data['status'] == 'healthy'
            print("   ✓ Root endpoint working")
        except Exception as e:
            print(f"   ❌ Root endpoint failed: {e}")

        # Test 2: Health check
        print("\n2. Testing health check...")
        try:
            response = requests.get(f"{BASE_URL}/health")
            assert response.status_code == 200
            data = response.json()
            assert 'model_version' in data
            print(f"   ✓ Health check passed (version: {data['model_version']})")
        except Exception as e:
            print(f"   ❌ Health check failed: {e}")

        # Test 3: Valid prediction
        print("\n3. Testing valid prediction...")
        try:
            data = {"features": [0.5, 0.3, 0.8, 0.2, 0.6]}
            response = requests.post(
                f"{BASE_URL}/predict",
                headers={"Content-Type": "application/json"},
                data=json.dumps(data)
            )
            assert response.status_code == 200
            result = response.json()
            assert 'prediction' in result
            print(f"   ✓ Prediction successful: {result['prediction']:.4f}")
        except Exception as e:
            print(f"   ❌ Prediction failed: {e}")

        # Test 4: Invalid input (wrong number of features)
        print("\n4. Testing invalid input validation...")
        try:
            data = {"features": [0.5, 0.3, 0.8]}  # Only 3 features instead of 5
            response = requests.post(
                f"{BASE_URL}/predict",
                headers={"Content-Type": "application/json"},
                data=json.dumps(data)
            )
            assert response.status_code == 422  # Validation error
            print("   ✓ Invalid input correctly rejected")
        except AssertionError:
            print("   ❌ Invalid input not rejected properly")
        except Exception as e:
            print(f"   ❌ Test failed: {e}")

        # Test 5: Invalid input (NaN value)
        print("\n5. Testing NaN value rejection...")
        try:
            data = {"features": [0.5, float('nan'), 0.8, 0.2, 0.6]}
            response = requests.post(
                f"{BASE_URL}/predict",
                headers={"Content-Type": "application/json"},
                data=json.dumps(data)
            )
            # Should be rejected
            assert response.status_code in [422, 500]
            print("   ✓ NaN values correctly rejected")
        except AssertionError:
            print("   ❌ NaN values not rejected")
        except Exception as e:
            print(f"   ❌ Test failed: {e}")

        # Test 6: Batch prediction
        print("\n6. Testing batch prediction...")
        try:
            batch_data = [
                {"features": [0.1, 0.2, 0.3, 0.4, 0.5]},
                {"features": [0.6, 0.7, 0.8, 0.9, 0.1]},
                {"features": [0.2, 0.3, 0.4, 0.5, 0.6]}
            ]
            response = requests.post(
                f"{BASE_URL}/predict_batch",
                headers={"Content-Type": "application/json"},
                data=json.dumps(batch_data)
            )
            assert response.status_code == 200
            result = response.json()
            assert result['batch_size'] == 3
            print(f"   ✓ Batch prediction successful ({result['batch_size']} samples)")
        except Exception as e:
            print(f"   ❌ Batch prediction failed: {e}")

        # Test 7: Large batch rejection
        print("\n7. Testing large batch rejection...")
        try:
            large_batch = [{"features": [0.1, 0.2, 0.3, 0.4, 0.5]}] * 101
            response = requests.post(
                f"{BASE_URL}/predict_batch",
                headers={"Content-Type": "application/json"},
                data=json.dumps(large_batch)
            )
            assert response.status_code == 400
            print("   ✓ Large batch correctly rejected")
        except AssertionError:
            print("   ❌ Large batch not rejected")
        except Exception as e:
            print(f"   ❌ Test failed: {e}")

        print("\n" + "=" * 60)
        print("Testing complete!")

    # Run the test suite
    test_api_endpoints()

**Method 4: Using the interactive documentation**

FastAPI automatically generates interactive API documentation. Visit:

* Swagger UI: ``http://localhost:8000/docs``
* ReDoc: ``http://localhost:8000/redoc``

These interfaces allow you to:

* See all available endpoints
* View request/response schemas
* Test endpoints interactively
* See example requests and responses

Summary and Exercises
----------------------

Successful machine learning projects require more than just training accurate models. This lecture covered the essential infrastructure needed to take models from experimentation to production:

* **Tracking** ensures you can reproduce and compare experiments
* **Reproducibility** guarantees models work consistently across environments
* **Deployment** makes models available for real-world use with proper monitoring

By following these practices, you'll be able to:

* Collaborate effectively with team members
* Maintain model quality over time
* Deploy reliably to production
* Debug issues when they arise
* Scale your ML systems

Remember: the goal is not just to build models that work on your laptop, but to create robust systems that deliver value in production. Good luck with your machine learning projects!


Further Reading and Resources
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**MLFlow**

* Official documentation: https://mlflow.org/docs/latest/index.html
* MLFlow tracking tutorial: https://mlflow.org/docs/latest/tracking.html
* Model registry guide: https://mlflow.org/docs/latest/model-registry.html

**ONNX**

* ONNX website: https://onnx.ai/
* ONNX Runtime: https://onnxruntime.ai/
* skl2onnx documentation: http://onnx.ai/sklearn-onnx/

**FastAPI**

* FastAPI documentation: https://fastapi.tiangolo.com/
* Deployment guide: https://fastapi.tiangolo.com/deployment/

**Best Practices**

* Google's ML Engineering best practices: https://developers.google.com/machine-learning/guides/rules-of-ml


.. topic:: Exercises

    **Exercise 1: MLFlow Practice**

    1. Train three different models on the iris dataset (Logistic Regression, Random Forest, SVM)
    2. Log all experiments to MLFlow with appropriate parameters and metrics
    3. Create confusion matrix plots and log them as artifacts
    4. Compare the models in MLFlow UI
    5. Load the best model and make predictions on new data

    **Exercise 2: Reproducibility Challenge**

    6. Train a model and save it with pickle
    7. Create a conda environment file with exact versions
    8. Convert the same model to ONNX
    9. Verify that all three formats (original, pickle, ONNX) produce identical predictions
    10. Try loading the model in a different environment (or share with a colleague)

    **Exercise 3: Build a Complete API**

    11. Train a regression or classification model of your choice
    12. Convert it to ONNX
    13. Create a FastAPI application with:

    * Health check endpoint
    * Single prediction endpoint
    * Batch prediction endpoint
    * Input validation
    * Error handling

    1. Write tests for all endpoints
    2. Document your API with examples
    3. Deploy it locally and test with curl or Python requests

    **Exercise 4: Monitoring Setup**

    4. Deploy your model from Exercise 3
    5. Implement logging for all predictions
    6. Create a monitoring dashboard (can be simple prints or plots)
    7. Simulate data drift by changing input distribution
    8. Implement drift detection
    9. Set up alerts for performance degradation

    **Exercise 5: End-to-End Project**

    Build a complete ML system:

    10. Choose a dataset (e.g., from Kaggle or UCI repository)
    11. Train multiple models with MLFlow tracking
    12. Select the best model based on metrics
    13. Create a reproducible environment with conda-lock
    14. Convert to ONNX and verify equivalence
    15. Build a FastAPI deployment
    16. Implement monitoring and logging
    17. Write comprehensive tests
    18. Document the entire process
