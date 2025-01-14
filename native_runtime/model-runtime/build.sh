#!/usr/bin/env bash

set -e

cargo build
uv build --sdist --wheel --out-dir dist
maturin build -r --sdist --out dist
pip install --no-index --find-links=dist/ model_runtime
