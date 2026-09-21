# Blog Post 2: Web Scraping for Actionable Insights

## What Technical Skills Do Economic Consulting Firms Actually Want?

This project uses web scraping in R to examine technical skills mentioned in entry-level economic consulting job postings from **The Brattle Group** and **Charles River Associates (CRA)**.

The analysis focuses on eight technical skills:

- Excel
- R
- Python
- Stata
- SQL
- SAS
- VBA
- GAMS

The goal is to identify which skills appear consistently across entry-level job postings and which skills appear to be more firm-specific.

## Repository Structure

```text
post2/
├── index.qmd
├── README.md
├── codes/
│   ├── scrape1.R
│   └── analysis.R
├── data/
│   └── raw/
│       ├── brattle_job_details.csv
│       └── cra_job_details.csv
└── result/
    ├── skill_frequency.png
    └── company_skill_comparison.png
```

## Data Sources

Job postings were collected from the publicly available Greenhouse job boards of:

- The Brattle Group
- Charles River Associates

Only publicly accessible pages were used. The scraping code does not bypass logins, CAPTCHAs, paywalls, or other access restrictions.

A one-second delay between requests is included when scraping multiple Brattle job pages.

## Reproducing the Analysis

The analysis was conducted in R.

### Required Packages

Install the required packages if necessary:

```r
install.packages(c(
  "rvest",
  "dplyr",
  "stringr",
  "readr",
  "tidyr",
  "ggplot2",
  "purrr",
  "tibble"
))
```

### Step 1: Use the Saved Scraped Data

The raw scraped job-posting data are already included in:

```text
data/raw/
```

To reproduce the cleaning, skill classification, summary statistics, and figures, run:

```text
codes/analysis.R
```

This script reads the saved CSV files and regenerates the figures in:

```text
result/
```

### Step 2: Re-scrape the Job Postings (Optional)

To collect the job-posting data again from the original websites, run:

```text
codes/scrape1.R
```

Because job postings change over time, re-running the scraping script may produce results that differ from the saved data used in the published blog post.

The scraping script includes a delay between requests and should not be run unnecessarily.

## Output

The analysis produces two main figures:

1. `skill_frequency.png` — overall frequency of technical-skill mentions across the selected entry-level job types.
2. `company_skill_comparison.png` — comparison of skill mentions between Brattle and CRA.

## Blog Post

The published article is generated from:

```text
index.qmd
```