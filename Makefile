PYXS = $(wildcard yarl/*.pyx)
SRC = yarl tests setup.py

all: test


.install-deps: $(shell find requirements -type f)
	@pip install -U -r requirements/dev.txt
	@touch .install-deps


.install-cython: requirements/cython.txt
	pip install -r requirements/cython.txt
	touch .install-cython


yarl/%.c: yarl/%.pyx
	python -m cython -3 -o $@ $< -I yarl


.cythonize: .install-cython $(PYXS:.pyx=.c)


cythonize: .cythonize


.develop: .install-deps $(shell find yarl -type f) .cythonize
	@pip install -e .
	@touch .develop

flake8:
	flake8 $(SRC)

black-check:
	black --check --diff -t py35 $(SRC)

mypy:
	mypy --show-error-codes yarl tests

lint: flake8 black-check mypy

fmt:
	black -t py35 $(SRC)


test: lint .develop
	pytest ./tests ./yarl


vtest: lint .develop
	pytest ./tests ./yarl -v


cov: lint .develop
	pytest --cov yarl --cov-report html --cov-report term ./tests/ ./yarl/
	@echo "open file://`pwd`/htmlcov/index.html"


doc: doctest doc-spelling
	make -C docs html SPHINXOPTS="-W -E"
	@echo "open file://`pwd`/docs/_build/html/index.html"


doctest: .develop
	make -C docs doctest SPHINXOPTS="-W -E"


doc-spelling:
	make -C docs spelling SPHINXOPTS="-W -E"
