"""Backwards-compatible re-exports from fun_ds.model.selection.

This module is kept so existing notebooks that import from
``fun_ds.evaluation`` continue to work unchanged. Prefer importing
directly from ``fun_ds.model`` in new code.
"""
from fun_ds.model.selection import compare_models, cross_val_summary

__all__ = ["cross_val_summary", "compare_models"]
