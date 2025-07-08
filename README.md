# Introduction

Python Package Cookiecutter Code to help make faster libraries. The objective of this repo is to concentrate on developing source code by standardizing the ecosystem of tools for development

## Summary

Writing code helps us solve a business problem. However writing good code will make it reusable. Writing good code with tests around it will help convert the code into a python library (or module or package) usable by fellow team members or to the open source community.

A developer will want to go through this process in a seamless manner. This article and repo will define a proven process and provide guidelines to write a python library.

 #TODO 
- Convert library to a cookiecutter template. Helps parametrize the library name.
- Use GitHub actions to include testing, test coverage etc.

For library guidance on a typical data science, see see [for data science projects](docs\data_science_guidance.md)

## Usage

The recommended practices for developing python libraries are given below:

<img src="docs/package_development.svg" width=auto, height=auto/>

[https://realpython.com/pypi-publish-python-package/](https://realpython.com/pypi-publish-python-package/)

### Modern Approach: Using UV (Recommended)

**UV is an extremely fast Python package manager** that replaces pip, pip-tools, pipenv, poetry, and more with a single tool. See our comprehensive guides:

- **[UV Best Practices](docs/uv_best_practices.md)** - Complete guide to using UV for Python package development
- **[UV vs Traditional Workflow](docs/uv_workflow_comparison.md)** - Detailed comparison showing 10x+ performance improvements

**Quick UV Workflow:**

| Step | Description | UV Commands |
|------|-------------|-------------|
| 1 | Initialize project | `uv init --lib my-package` |
| 2 | Install dependencies | `uv sync` (creates venv + lockfile) |
| 3 | Add dependency | `uv add requests` |
| 4 | Run tests | `uv run pytest` |
| 5 | Build package | `uv build` |
| 6 | Publish package | `uv publish` |

**Key Benefits:**
- 🚀 **10-100x faster** than traditional tools
- 🔧 **Single tool** replaces entire toolchain
- 🔒 **Automatic lockfiles** for reproducible builds
- 🐍 **Python version management** built-in
- ⚡ **Zero-config** virtual environments

**Using toml file, bumpver and twine (Traditional)**

| Step |  Description | Commands/Detailed Description | Reference |
|---|---|---|---|
| 1 | Create python project with directory structure | Follow pep8 guidelines | [https://www.freecodecamp.org/news/build-your-first-python-package/](https://www.freecodecamp.org/news/build-your-first-python-package/) |
| 2 | Package compliance | Ensure all directories are package modules using __init__.py  | [https://www.freecodecamp.org/news/build-your-first-python-package/](https://www.freecodecamp.org/news/build-your-first-python-package/) |
| 3 | Add .toml file and setup.py to build wheels | pip install bumpver <br> bumpver update --patch  <br> pip install build <br> python -m build | https://realpython.com/pypi-publish-python-package/ |
| 4 | Create account on pypi and upload using twine package | These commands will push the .whl and .tar.gz file into the pypi repository <br> conda install twine <br> twine upload dist/*  | https://realpython.com/pypi-publish-python-package/ |

To see instructions using setup.py & twine, without Version Bump, see [using setup.py](docs\using_setuppy.md)

## CI

### Modern CI/CD with UV (Recommended)

UV significantly simplifies CI/CD pipelines with faster operations and fewer dependencies:

```yaml
# .github/workflows/test.yml
- name: Install uv
  uses: astral-sh/setup-uv@v3
  
- name: Install dependencies and run tests
  run: |
    uv sync --extra dev
    uv run pytest
    
- name: Build and publish
  run: |
    uv build
    uv publish
```

See [our example workflow](.github/workflows/test_uv.yml) for a complete CI/CD pipeline using UV.

**Benefits in CI/CD:**
- ⚡ **Faster builds** (5-10x speedup)
- 🔧 **Simpler configuration** (fewer steps)
- 🔒 **Reproducible environments** (lockfile support)
- 🐍 **Multi-Python testing** (built-in Python management)

### Traditional CI/CD

More CI/CD streamlining for python packages:
- use cookiecutter to generate a package template
- set up travis CI for auto deployment of package to pypi

 #TODO 
- Convert library to a cookiecutter template. Helps parametrize the library name.

https://github.com/audreyfeldroy/cookiecutter-pypackage
https://cookiecutter-pypackage.readthedocs.io/en/latest/tutorial.html
https://pypi.org/project/cookiecutter/

https://github.com/boromir674/cookiecutter-python-package
https://github.com/boromir674/cookiecutter-python-package/tox.ini

https://youtu.be/ugGu8fHWFog (A data science project example folder)

### Github

Helps cover testing, test coverage, etc.
https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-python
https://hynek.me/articles/python-github-actions/

### Travis CI, No Free Support?

https://jacobtomlinson.dev/posts/2021/testing-and-continuous-integration-for-python-packages-with-github-actions/

https://github.com/ksator/continuous-integration-with-python

https://medium.com/swlh/automate-python-testing-with-github-actions-7926b5d8a865


## Testing a Package Locally 

**Using .toml file (Working)**

A package can be imported locally from another code and thoroughly tested as well if required. Editable install is the best way to achieve this.
The steps to do so are:
- Change to the current working directory where the pyproject.toml file is located
- Execute the following command to install the package locally
	- python -m pip install -e .
- This installation uses the files in the current working directory

**Using conda-build (Did not work)**

Building A Package Locally
- Add following package to the base environment
    -Install conda-buiild
    -Conda install conda-build
- Utilize the below to build the package in current path. A specific path can also be specified.
    - Conda develop . 
    - https://docs.conda.io/projects/conda-build/en/latest/user-guide/tutorials/build-pkgs.html


## Writing Tests
- Write tests. Preferably utilize pytest. 
- Example test and file structure
	- https://github.com/jumptrading/luddite
	- Utilized test_package.py for all tests 
	- pytest.ini file for pytest configurations
	- Utilize github test workflows
	- https://github.com/jumptrading/luddite/blob/master/.github/workflows/tests.yml
- https://tox.wiki/en/latest/

### References

**UV Documentation:**
- **[UV Quick Start Guide](docs/uv_quick_start.md)** - Get started with UV in under 5 minutes
- **[UV Best Practices](docs/uv_best_practices.md)** - Comprehensive UV guide for Python packages
- **[UV vs Traditional Workflow](docs/uv_workflow_comparison.md)** - Performance and DX comparisons
- **[UV-Optimized pyproject.toml Template](pyproject_uv_template.toml)** - Copy-paste template

**Traditional Packaging:**
[https://www.freecodecamp.org/news/build-your-first-python-package/](https://www.freecodecamp.org/news/build-your-first-python-package/)

[https://python-packaging-tutorial.readthedocs.io/en/latest/setup_py.html](https://python-packaging-tutorial.readthedocs.io/en/latest/setup_py.html)

[https://packaging.python.org/](https://packaging.python.org/)

Guidelines to contribute to libraries:
[https://pandas.pydata.org/docs/development/contributing.html#contributing](https://pandas.pydata.org/docs/development/contributing.html#contributing)

https://realpython.com/pypi-publish-python-package/

https://github.com/johnthagen/python-blueprint
