# Blog Post 7: Interactive Data Visualization with Plotly

## Overview

This project accompanies Blog Post 7 for AEDS 6400: Computational Methods for Economists.

The post investigates the relationship between GDP per capita and life expectancy across countries and over time. It uses an interactive Plotly visualization that allows readers to move between years, compare countries and continents, and inspect individual observations using hover information.

## Research Question

**How has the relationship between income and life expectancy changed across countries and over time, and what can an interactive visualization reveal that a static figure cannot?**

## Data

The analysis uses the `gapminder` dataset included in the R `gapminder` package.

The dataset contains 1,704 observations covering 142 countries at five-year intervals from 1952 to 2007.

The main variables used are:

- `country`: country name
- `continent`: continent
- `year`: observation year
- `lifeExp`: life expectancy
- `pop`: population
- `gdpPercap`: GDP per capita

No external data files are required because the dataset is loaded directly through the `gapminder` R package.

## Software and Packages

The analysis was conducted in R using the following packages:

```r
library(tidyverse)
library(plotly)
library(gapminder)
library(scales)
```

If these packages are not installed, they can be installed with:

```r
install.packages(c(
  "tidyverse",
  "plotly",
  "gapminder",
  "scales"
))
```

## Reproduction

To reproduce the analysis:

1. Clone or download this repository.
2. Open the project in RStudio.
3. Make sure the required R packages are installed.
4. Open `blog/posts/post7/index.qmd`.
5. Render the Quarto document.

The dataset is loaded directly from the `gapminder` package, so no separate data download is necessary.

## Visualization

The main visualization is an interactive scatterplot created with Plotly.

- GDP per capita is shown on the horizontal axis using a logarithmic scale.
- Life expectancy is shown on the vertical axis.
- Point size represents population.
- Point color represents continent.
- The animation slider allows movement across years from 1952 to 2007.
- Hovering over a point displays the country, year, GDP per capita, life expectancy, and population.

## Files

```text
blog/posts/post7/
├── index.qmd
└── README.md
```

`index.qmd` contains the complete analysis, visualization code, and written discussion required to reproduce the blog post.