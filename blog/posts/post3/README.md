# Blog Post 3: Education and Labor Market Outcomes

This project uses IPUMS Current Population Survey (CPS) data to examine how unemployment and labor force participation vary across education groups in the United States.

## Data

The analysis uses July Basic Monthly CPS samples from 2015 through 2026 from IPUMS CPS.

The main variables used are:

- `YEAR`
- `AGE`
- `EDUC`
- `EMPSTAT`
- `LABFORCE`
- `WTFINL`

The analysis focuses on adults ages 25–64. Population statistics are calculated using the CPS final person weight, `WTFINL`.

## Files

- `index.qmd` contains the analysis and visualizations.
- `data/raw/cps_00001.dat.gz` contains the CPS microdata.
- `data/raw/cps_00001.xml` contains the IPUMS DDI metadata used to read the data.

## Reproducing the analysis

1. Open `index.qmd` in RStudio.
2. Install the required R packages if needed:
   - `tidyverse`
   - `ipumsr`
   - `scales`
3. Make sure the CPS `.dat.gz` and `.xml` files are stored in `data/raw/`.
4. Render `index.qmd` with Quarto.

The figures and statistics in the blog post are generated directly from the CPS data in the Quarto file.