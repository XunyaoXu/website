
packages <- c(
  "tidyverse",
  "tidyquant",
  "tidymodels",
  "lubridate",
  "slider",
  "xgboost",
  "ggplot2"
)

new_packages <- packages[
  !packages %in% installed.packages()[, "Package"]
]

if (length(new_packages) > 0) {
  install.packages(new_packages)
}

# Load libraries
library(tidyverse)
library(tidyquant)
library(tidymodels)
library(lubridate)
library(slider)
library(xgboost)
library(ggplot2)

set.seed(123)

dir.create("data", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)



tickers <- c(
  # Technology
  "AAPL","MSFT","NVDA","GOOG","META","AMZN",
  "AVGO","ORCL","ADBE","CRM","CSCO","AMD",
  "INTC","QCOM","TXN","IBM","NOW","INTU",
  "AMAT","MU",
  
  # Financials
  "JPM","BAC","WFC","GS","MS","BLK","C",
  "SCHW","SPGI","AXP","USB","PNC","TFC","COF",
  
  # Healthcare
  "UNH","JNJ","LLY","PFE","MRK","ABBV",
  "TMO","DHR","ABT","BMY","AMGN","GILD",
  "CVS","ISRG","MDT",
  
  # Consumer Discretionary
  "TSLA","HD","MCD","NKE","SBUX","LOW",
  "TJX","BKNG","CMG","ORLY",
  
  # Consumer Staples
  "WMT","COST","PG","KO","PEP","PM",
  "MO","CL","EL",
  
  # Industrials
  "CAT","GE","HON","UPS","BA","RTX",
  "DE","LMT","MMM","ETN",
  
  # Energy
  "XOM","CVX","COP","SLB","EOG",
  
  # Communication
  "NFLX","DIS","CMCSA","TMUS","VZ",
  
  # Real Estate / Utilities / Materials
  "AMT","PLD","NEE","DUK","SO","LIN","APD"
)

start_date <- as.Date("2022-01-01")
end_date <- as.Date("2026-11-14")

prices <- tq_get(
  tickers,
  from = start_date,
  to = end_date,
  get = "stock.prices"
)

spy <- tq_get(
  "SPY",
  from = start_date,
  to = end_date,
  get = "stock.prices"
) %>%
  select(date, spy_price = adjusted) %>%
  arrange(date) %>%
  mutate(
    spy_ret = spy_price / lag(spy_price) - 1
  )

saveRDS(prices, "blog/posts/post9/data/stock_prices.rds")
saveRDS(spy, "blog/posts/post9/data/spy_prices.rds")

cat("Number of stocks:",
    n_distinct(prices$symbol), "\n")

cat("Number of observations:",
    nrow(prices), "\n")

cat("Date range:",
    as.character(min(prices$date)),
    "to",
    as.character(max(prices$date)), "\n")

print(head(prices))

