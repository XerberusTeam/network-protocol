# import nox


# @nox.session
# def python(session):
#     session.env["MATURIN_PEP517_ARGS"] = "--profile=dev"
#     session.install(".[dev]")
#     session.run("pytest")


import sys

import nox


@nox.session(python=["3.11", "3.12"])
def tests(session):
    session.run("pip", "install", "uv")
    session.run(
        "uv",
        "export",
        "--no-hashes",
        "--output-file",
        "requirements.txt",
    )
    session.run("pip", "install", "-r", "requirements.txt")
    session.run("pip", "install", "-e", ".")
    if sys.platform == "darwin":
        session.run("rustup", "target", "add", "x86_64-apple-darwin")
        session.run("rustup", "target", "add", "aarch64-apple-darwin")
    session.run("uv", "build", "--sdist", "--wheel", "--out-dir", "dist")
    session.run(
        "maturin",
        "build",
        "-r",
        "--sdist",
        "--out",
        "dist",
    )
    session.run("pip", "install", "--no-index", "--find-links=dist/", "model_runtime")
    session.run("pytest")


@nox.session(python=["3.11"])
def lint(session):
    session.run("pip", "install", "black", "ruff")
    session.run("black", "model_runtime/", "tests/")
