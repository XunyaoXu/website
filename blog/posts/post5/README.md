# Blog Post 5: The Geography of Income in Philadelphia

## Overview

This project examines the geographic distribution of median household income across Philadelphia using Geographic Information Systems (GIS) and data from the U.S. Census Bureau.

The analysis explores spatial differences in household income across census tracts and identifies geographic patterns of economic inequality.

## Data Source

- **Source:** U.S. Census Bureau
- **Dataset:** American Community Survey (ACS) 2024 5-Year Estimates
- **Geographic Area:** Philadelphia County, Pennsylvania
- **Geographic Level:** Census Tract
- **Variable:** B19013_001 — Median Household Income
- **Units:** 2024 inflation-adjusted U.S. dollars

Data are downloaded programmatically using the R package `tidycensus`.

## Tools and Packages

The analysis was conducted in R using:

- `tidycensus` — Census data retrieval
- `dplyr` — Data processing
- `sf` — Spatial data manipulation
- `ggplot2` — Geographic visualization
- `scales` — Formatting numerical values

## Project Files

- `index.qmd` — Blog post containing the analysis and interpretation.
- `analysis.R` — Reproducible R code for loading, cleaning, analyzing, and visualizing the data.
- `philly_income_map.png` — Generated map of median household income.
- `income_summary.csv` — Summary statistics generated from the data.
- `README.md` — Project documentation and replication instructions.
- `philly_income.gpkg` — Original ACS income data and geographic boundaries.

## Reproduction Instructions

This project is fully reproducible without a Census API key. The original ACS data and geographic boundaries are included in the repository as `philly_income.gpkg`.

To reproduce the analysis:

1. Download or clone the GitHub repository.
2. Install R and the required packages:

   ```r
   install.packages(c("dplyr", "sf", "ggplot2", "scales"))
   ```

3. Open RStudio and set the working directory to the root of the `website` project.
4. Run the following command:

   ```r
   source("blog/posts/post5/analysis.R")
   ```

5. The script will automatically:
   - Load the saved Census data from `philly_income.gpkg`.
   - Clean the data and calculate income statistics.
   - Generate `philly_income_map.png`.
   - Save summary statistics to `income_summary.csv`.

6. To reproduce the blog post, render `blog/posts/post5/index.qmd` using Quarto.

No Census API key or additional data download is required.

## Data Availability

The repository includes `philly_income.gpkg`, containing the original ACS 2024 5-Year Estimates used in this analysis, including tract boundaries, income estimates, and margins of error.

The data were originally retrieved from the U.S. Census Bureau using the `tidycensus` package in R.


## Main Findings

The analysis includes 375 Philadelphia census tracts with valid median household income estimates.

- Median of tract-level median household incomes: $62,083
- Mean of tract-level median household incomes: $68,707
- 25th percentile: $43,529
- 75th percentile: $88,647
- Lowest observed tract median income: $17,875
- Highest observed tract median income: $227,656

The results reveal substantial geographic variation in median household income within Philadelphia, suggesting that economic inequality has an important spatial dimension.

These tract-level statistics are not estimates of the citywide household income distribution.

## Limitations

ACS data are survey estimates subject to sampling uncertainty. Census tract boundaries do not necessarily correspond to commonly recognized neighborhoods. The analysis is descriptive and does not establish causal relationships.

## Data Reference

U.S. Census Bureau. American Community Survey, 2024 ACS 5-Year Estimates, Table B19013.

https://www.census.gov/programs-surveys/acs