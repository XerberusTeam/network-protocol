use pyo3::prelude::*;
use pyo3::types::PyDict;
use pyo3::wrap_pymodule;

mod submodule;

#[pyclass]
struct ExampleClass {
	#[pyo3(get, set)]
	value: i32,
}

#[pymethods]
impl ExampleClass {
	#[new]
	pub fn new(value: i32) -> Self {
		ExampleClass { value }
	}
}

/// An example module implemented in Rust using PyO3.
#[pymodule]
#[pyo3(name = "model_runtime")]
fn model_runtime(py: Python<'_>, m: &Bound<'_, PyModule>) -> PyResult<()> {
	m.add_class::<ExampleClass>()?;
	m.add_wrapped(wrap_pymodule!(submodule::submodule))?;

	let sys = PyModule::import(py, "sys")?;
	let sys_modules: Bound<'_, PyDict> = sys.getattr("modules")?.downcast_into()?;
	sys_modules.set_item("model_runtime.submodule", m.getattr("submodule")?)?;

	Ok(())
}
