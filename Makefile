# ==========
# VARIABLES
# ==========

# Python version
# /!\ PYTHON_VERSION should include the release number (i.e. not 3.x, but 3.x.x)
PYTHON_VERSION = 3.12.1

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

# clear the repository
.PHONY : clear
clear :
	rm -rf .python-version requirements.txt venv


# ==========
# PYTHON
# ==========

# install requirements
.PHONY : install-requirements
install-requirements : $(COMPILED_REQUIREMENTS_FILE)
	. $(VENV_ACTIVATE) && pip-sync

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
