# Blog Post 6 — Matching Parents and Children with SQL in Python

This repository contains a reproducible Quarto tutorial demonstrating how to match parents and children using SQL in Python and estimate intergenerational income elasticity (IGE).

The tutorial uses **simulated longitudinal data**, not real PSID or U.S. population data. All reported results are based on the simulation.

## Directory Structure

- `index.qmd`: Complete Quarto tutorial explaining SQL matching, income construction, IGE estimation, and life-cycle bias.
- `scripts/generate_data.py`: Generates simulated parent-child panel data using a fixed random seed.
- `scripts/analyze.py`: Performs SQL matching, constructs income measures, estimates IGE, and saves results.
- `data/`: Generated datasets and analysis results.
- `figures/`: Generated visualizations.
- `requirements.txt`: Required Python packages.

## Reproducing the Analysis

Run the following commands from the `blog/posts/post6/` directory:

```bash
python -m pip install -r requirements.txt
python scripts/generate_data.py
python scripts/analyze.py
quarto render index.qmd
```

Python 3.11 or a compatible version is recommended. Quarto and a working Jupyter Python kernel are required to render the executable Python code in the tutorial.

## Data Structure

The simulation generates 1,200 parent-child pairs, corresponding to 2,400 individuals and 24,000 person-year income observations from 2010 to 2019.

- `individuals.csv`: Contains `person_id`, `family_id`, `parent_id`, and `role`.
- `earnings.csv`: Contains `person_id`, `year`, `age`, and `income`.

The `parent_id` variable identifies each child's parent, while `family_id` verifies family membership.

## Main Results

| Income Measure | Estimated IGE |
|---|---:|
| Single-year income (2010) | 0.194 |
| Ten-year average income (2010–2019) | 0.385 |

The simulated long-run income transmission parameter is 0.43.

Estimated IGE varies with the age at which children's incomes are measured. The tutorial uses this pattern to illustrate potential life-cycle bias and explains how multi-year averaging reduces temporary income fluctuations.

These findings are intended to demonstrate computational methods and should not be interpreted as empirical estimates of U.S. intergenerational mobility.

## Reproducibility Notes

All simulated data are generated programmatically rather than manually collected or edited. The analysis scripts reproduce the income measures and IGE estimates.

The Quarto tutorial contains instructional Python and SQL examples, with an executable visualization demonstrating age-related variation in estimated IGE.