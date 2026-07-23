"""Model selection and diagnostics."""
from fun_ds.model.diagnostics import OLSDiagnostics
from fun_ds.model.selection import compare_models, cross_val_summary

__all__ = ["cross_val_summary", "compare_models", "OLSDiagnostics"]
