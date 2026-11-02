# Blog Post 8: Simulation, Bootstrap, and Hypothesis Testing

## Overview

This project uses Monte Carlo simulation to explain three fundamental concepts in statistical inference: bootstrap confidence intervals, confidence interval coverage, and hypothesis testing.

The main objective is to demonstrate how statistical inference works through repeated sampling and visualization. All observations are synthetically generated from a standard normal distribution with a known population mean of 0 and standard deviation of 1.

## Methods

The project consists of three experiments:

**1. Bootstrap Confidence Intervals**

- Generate a random sample of 100 observations.
- Draw 3,500 bootstrap samples with replacement.
- Construct a 95% percentile bootstrap confidence interval.
- Visualize the bootstrap distribution and confidence interval.

**2. Confidence Interval Coverage**

- Repeat the sampling and bootstrap procedure 1,000 times.
- Calculate the proportion of confidence intervals containing the true population mean.
- Visualize the confidence intervals that cover or miss the true parameter.

**3. Hypothesis Testing**

- Simulate 10,000 z-statistics under the null hypothesis.
- Visualize the null distribution and the 5% rejection regions.
- Calculate a simulated two-sided p-value and illustrate the corresponding tail areas.

## Key Results

- **Bootstrap 95% CI:** Approximately [-0.372, 0.008], containing the true population mean of 0.
- **Empirical Coverage Rate:** 94.7% across 1,000 independent simulated experiments, close to the nominal 95% level.
- **Hypothesis Testing:** The observed z-statistic was approximately 3.647, with a simulated p-value of 0.0001, leading to rejection of the null hypothesis at the 5% significance level.

These results illustrate the long-run interpretation of confidence intervals and how hypothesis testing evaluates evidence against a null hypothesis.

## Reproducibility

The analysis is implemented in Python using Quarto. No external datasets are required.

**Requirements:**
- Python 3.10+
- Quarto
- Python packages listed in `requirements.txt`

**To reproduce the analysis:**

1. Install Python and Quarto.
2. Install dependencies:

   `python -m pip install -r requirements.txt`

3. Render the Quarto document:

   `quarto render index.qmd`

4. Open the generated `index.html` to view the results and figures.

All simulations use a fixed random seed (`64008`) for reproducibility. Simulation parameters can be modified in the first Python code cell.

## Repository Structure

- `index.qmd` — Quarto source document containing explanations, Python code, figures, and results.
- `requirements.txt` — Python package dependencies.
- `README.md` — Project overview and reproduction instructions.

## Submission

The assignment requires both the published Quarto blog URL and the corresponding GitHub repository URL.