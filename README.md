# Python Project Template

A template for quickly starting a Python project.

## Motivation

Setting up a Python environment can be time consuming and require the creation of many files. This template uses [GNU Make](https://www.gnu.org/software/make/) to automate this process, reducing the complexity of the initial configuration to the simple command `gmake init`.

## Requirements

This repository is designed to be used on macOS with zsh. Compatibility with other operating systems and shells is not guaranteed.

It requires:

- [pyenv](https://github.com/pyenv/pyenv)
- [GNU make](https://www.gnu.org/software/make/)

## Using the template

### Initial setup

1. Set the desired Python version in the Makefile
2. List the required (development) dependencies in `requirements(-dev).in`
3. Run `gmake init`

### Additionale rules

Some additional Make rules are also implemented:

- `clear`: reset the template (removes the virtual environment, the compiled `requirements.txt` and the `.python-version` file)
- `install-requirements`: recompile `requirements.txt` and install the requirements
