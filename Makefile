# ~/~ begin <<docs/logistic-growth.md#Makefile>>[init]
.RECIPEPREFIX=> 
.PHONY: all

all: docs/fig/logistic-bifurcation.png docs/fig/logistic-orbits.svg

docs/fig/logistic-bifurcation.png: logistic/plot-bifurcation.py
> @mkdir -p $(@D)
> poetry run python $<

docs/fig/logistic-orbits.svg: logistic/plot-orbits.py
> @mkdir -p $(@D)
> poetry run python $<
# ~/~ end