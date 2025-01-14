# import the contents of the Rust library into the Python extension
from .model_runtime import *
from .model_runtime import __all__

# optional: include the documentation from the Rust module
from .model_runtime import __doc__  # noqa: F401

__all__ = __all__ + ["PythonClass", "ExampleClass"]


class PythonClass:
    def __init__(self, value: int) -> None:
        self.value = value
