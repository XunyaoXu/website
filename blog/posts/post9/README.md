# Blog Post 9 — Predicting Stock Returns with XGBoost

This folder contains a reproducible stock-return prediction and exploratory portfolio-backtesting analysis for AEDS 6400. The Quarto article is `index.qmd`.

## Contents

- `01_data_preparation.R` — download adjusted daily prices for 95 available stocks plus SPY.
- `02_feature_engineering.R` — construct past-return features, the future 20-trading-day target, and target-end dates.
- `03_original_model.R` — train the baseline XGBoost model and save out-of-sample predictions.
- `04_improved_model.R` — add features, tune four candidate specifications using a pre-test validation period, train the selected model, and save predictions.
- `05_model_comparison.R` — compare the original and improved models with historical-mean and zero-return benchmarks on identical test observations.
- `06_backtest.R` — backtest 20-trading-day equal-weight top-10 portfolios, including SPY and momentum comparators.
- `07_visualizations.R` — generate error, forecast-scatter, and feature-importance plots.
- `data/` — model input and output files (`.rds` and `.csv`).
- `figures/` — figures referenced in `index.qmd`.

The optional `05_advanced_xgboost.R` is **not** part of this blog post's main findings.

## Reproduction

Open the existing `website.Rproj` project, keep the working directory at the `website/` root, and install the R packages used by the scripts, including `tidyverse`, `tidyquant`, `tidymodels`, `slider`, and `xgboost`.

Run the following in order from the `website` project root:

```r
source("blog/posts/post9/01_data_preparation.R")
source("blog/posts/post9/02_feature_engineering.R")
source("blog/posts/post9/03_original_model.R")
source("blog/posts/post9/04_improved_model.R")
source("blog/posts/post9/05_model_comparison.R")
source("blog/posts/post9/06_backtest.R")
source("blog/posts/post9/07_visualizations.R")
```

The analysis was originally run on adjusted daily prices through November 13, 2026. If the data source returns revisions, missing tickers, or a different end date, results may differ. To replicate published values exactly, use the archived input data in `data/` rather than re-downloading.

Preview or render the post from the project root:

```sh
quarto preview blog/posts/post9/index.qmd
# or
quarto render blog/posts/post9/index.qmd
```

`index.qmd` reads `data/model_comparison.csv` and `data/backtest_performance.csv` during rendering, and embeds these five files from `figures/`:

- `prediction_errors.png`
- `actual_vs_predicted.png`
- `feature_importance.png`
- `cumulative_returns.png`
- `drawdown_comparison.png`

## Methodological notes

- The training and validation splits exclude labels whose future target window extends across their boundary.
- Backtest returns are illustrative and assume an estimated 20-basis-point round-trip cost for model portfolios.
- The fixed, currently selected stock universe is subject to survivorship bias.
- Drawdowns are measured at 20-trading-day holding-period endpoints, not daily.
- Sharpe ratios use zero as the risk-free rate.
- This is a research exercise, not a live-trading system or investment advice.
