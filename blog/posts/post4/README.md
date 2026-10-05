# Blog Post 4: The Monthly Cost of Buying a New Home

This project analyzes how changes in U.S. new-home prices and mortgage rates have affected the monthly cost of purchasing a new home since 2015.

The analysis is written in Python and published using Quarto.

## Research Question

How have changes in U.S. new-home prices and mortgage rates affected the monthly cost of buying a new home since 2015?

## Data Sources

The analysis uses two publicly available data series from the Federal Reserve Bank of St. Louis (FRED):

- Median Sales Price of New Houses Sold for the United States (`MSPUS`)
  - https://fred.stlouisfed.org/series/MSPUS

- 30-Year Fixed Rate Mortgage Average in the United States (`MORTGAGE30US`)
  - https://fred.stlouisfed.org/series/MORTGAGE30US

The data are downloaded directly from FRED within the Python code, so no manually downloaded data files are required.

## Analysis

The post contains three main visualizations:

1. Median sales price of new U.S. homes since 2015.
2. Average 30-year fixed mortgage rate since 2015.
3. Estimated monthly cost of purchasing a median-priced new U.S. home.

For the monthly-cost calculation, the analysis assumes:

- 20% down payment
- 30-year fixed-rate mortgage
- Annual property taxes equal to 1% of the home value
- Annual homeowners insurance equal to 0.5% of the home value

Because the home-price data are quarterly and mortgage rates are weekly, mortgage rates are converted to quarterly averages before the two datasets are merged.

## Repository Structure

```text
blog/
└── posts/
    └── post4/
        ├── index.qmd
        └── README.md
```

`index.qmd` contains the complete analysis, including data acquisition, cleaning, transformations, calculations, visualizations, and interpretation.

## Requirements

This analysis requires:

- Python 3.11
- pandas
- matplotlib
- Jupyter
- Quarto
- PyYAML

Install the required Python packages with:

```bash
python3 -m pip install pandas matplotlib jupyter pyyaml
```

## Reproduction

From the root directory of the website repository, render the blog post with:

```bash
quarto render blog/posts/post4/index.qmd
```

Alternatively, open the website project in RStudio and click **Render** while `index.qmd` is open.

No local data files are required. The FRED data are downloaded programmatically when the document is rendered, and all transformations, calculations, figures, and numerical results are generated from the code in `index.qmd`.
