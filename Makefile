# ==========
# VARIABLES
# ==========

# Python version
# /!\ PYTHON_VERSION should include the release number (i.e. not 3.x, but 3.x.x)
PYTHON_VERSION = 3.12.1

# Python version without release number
PYTHON_SHORT_VERSION = $(shell echo $(PYTHON_VERSION) | sed -r "s/^([[:digit:]]+\.[[:digit:]]+)\..*$$/\1/g")

# Python version for Ruff
PYTHON_RUFF_VERSION = $(shell echo $(PYTHON_VERSION) | sed -r "s/^([[:digit:]]+)\.([[:digit:]]+)\..*$$/py\1\2/g")

# Python version file
PYTHON_VERSION_FILE = .python-version

# Python interpreters
PYENV_PYTHON = $(shell pyenv root)/versions/$(PYTHON_VERSION)/bin/python
PYTHON = $(VENV_DIR)/bin/python

# requirements
REQUIREMENTS_FILE = requirements.in
DEV_REQUIREMENTS_FILE = requirements-dev.in
REQUIREMENTS_FILES = $(REQUIREMENTS_FILE) $(DEV_REQUIREMENTS_FILE)
COMPILED_REQUIREMENTS_FILE = requirements.txt

# virtual environment
VENV_DIR = venv
VENV_ACTIVATE = $(VENV_DIR)/bin/activate


# ==========
# INIT & CLEAR
# ==========

# initialise the repository
.PHONY : init
init :
	$(MAKE) install-requirements
	$(MAKE) set-ruff-target-version
	$(MAKE) install-pre-commit-hooks
	$(MAKE) set-github-actions-python-version

# clear the repository
.PHONY : clear
clear :
	rm -rf .python-version requirements.txt venv


# ==========
# RUFF LINTING & FORMATTING
# ==========

# lint and format
.PHONY : lint-format
lint-format : | $(VENV_ACTIVATE)
	$(MAKE) lint
	$(MAKE) format

# lint
.PHONY : lint
lint : | $(VENV_ACTIVATE)
	. $(VENV_ACTIVATE) && ruff check

# format
.PHONY : format
format : | $(VENV_ACTIVATE)
	. $(VENV_ACTIVATE) && ruff format

# set Ruff `target-version`
.PHONY : set-ruff-target-version
set-ruff-target-version : $(PYTHON_VERSION_FILE)
	sed -r -i "" "s/^(target-version = ).*$$/\1\"$(PYTHON_RUFF_VERSION)\"/g" "pyproject.toml"


# ==========
# PYTHON
# ==========

# install requirements
.PHONY : install-requirements
install-requirements : $(COMPILED_REQUIREMENTS_FILE)
	. $(VENV_ACTIVATE) && pip-sync
	$(MAKE) install-pre-commit-hooks

# compile requirements
$(COMPILED_REQUIREMENTS_FILE) : $(REQUIREMENTS_FILES) | $(VENV_ACTIVATE)
	. $(VENV_ACTIVATE) && pip-compile --output-file=$@ --strip-extras $^

# create virtual environment
$(VENV_ACTIVATE) : $(PYTHON_VERSION_FILE)
	$(PYENV_PYTHON) -m pip install -U pip virtualenv
	$(PYENV_PYTHON) -m virtualenv $(VENV_DIR)
	$(PYTHON) -m pip install -U pip pip-tools

# set pyenv local Python version
$(PYTHON_VERSION_FILE) : | $(PYENV_PYTHON)
	pyenv local $(PYTHON_VERSION)

# install Python version
$(PYENV_PYTHON) :
	arch -arm64 pyenv install --skip-existing $(PYTHON_VERSION)


# ==========
# PRE-COMMIT
# ==========

# install pre-commit hooks
.PHONY : install-pre-commit-hooks
install-pre-commit-hooks : $(COMPILED_REQUIREMENTS_FILE) | $(VENV_ACTIVATE)
	$(MAKE) set-pre-commit-ruff-version
	. $(VENV_ACTIVATE) && pre-commit install

# set Ruff version based on requirements.txt
.PHONY : set-pre-commit-ruff-version
set-pre-commit-ruff-version : RUFF_VERSION = $(shell sed -r -n "s/ruff==([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+)/\1/p" "requirements.txt")
set-pre-commit-ruff-version : $(COMPILED_REQUIREMENTS_FILE)
	perl -0777 -pi -e "s/(?<=ruff-pre-commit\n\s{4}rev:\sv)(\d+\.\d+\.\d+)/$(RUFF_VERSION)/g" ".pre-commit-config.yaml"


# ==========
# GITHUB ACTIONS
# ==========

# set GitHub Actions `python-version`
.PHONY : set-github-actions-python-version
set-github-actions-python-version : $(COMPILED_REQUIREMENTS_FILE)
	perl -0777 -pi -e "s/(?<=python-version:\s\')(\d+.\d+)(?=\')/$(PYTHON_SHORT_VERSION)/g" ".github/actions/setup-venv/action.yaml"
