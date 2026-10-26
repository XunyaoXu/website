# Blog Post 3: Education Gaps in U.S. Labor Market Participation and Unemployment

This project uses IPUMS Current Population Survey (CPS) data to examine how unemployment and labor force participation differ across education groups in the United States.

The central question is whether education gaps are larger in unemployment among people already in the labor force or in labor force participation itself.

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

## Analysis

The post contains three substantive visualizations that build one story:

1. Unemployment rates by education from 2015 through 2026.
2. Labor force participation rates by education from 2015 through 2026.
3. A direct comparison of the unemployment and participation gaps between adults with a high school education or less and adults with graduate degrees.

The third figure highlights the main result: the education gap in labor force participation is much larger than the education gap in unemployment.

## Files

- `index.qmd` contains the complete analysis and visualizations.
- `data/raw/cps_00001.dat.gz` contains the CPS microdata.
- `data/raw/cps_00001.xml` contains the IPUMS DDI metadata used to read the data.

## Reproducing the Analysis

1. Open `index.qmd` in RStudio.
2. Install the required R packages if needed:
   - `tidyverse`
   - `ipumsr`
   - `scales`
3. Make sure the CPS `.dat.gz` and `.xml` files are stored in `data/raw/`.
4. Render `index.qmd` with Quarto.

All statistics and figures in the blog post are generated directly from the CPS microdata in `index.qmd`.

## Data Source

IPUMS CPS, Basic Monthly samples, July 2015–2026. The extract metadata identify the dataset as IPUMS CPS and provide DOI `10.18128/D030.V13.0`.
