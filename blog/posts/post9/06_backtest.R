
library(tidyverse)

set.seed(123)

base_path <- "blog/posts/post9"
data_path <- file.path(base_path, "data")
fig_path <- file.path(base_path, "figures")

dir.create(fig_path, recursive = TRUE,
           showWarnings = FALSE)



preds <- readRDS(
  file.path(data_path, "comparison_predictions.rds")
)

df <- readRDS(
  file.path(data_path, "model_data.rds")
)

prices <- readRDS(
  file.path(data_path, "stock_prices.rds")
)

spy <- readRDS(
  file.path(data_path, "spy_prices.rds")
)


# Signal: today's close
# Entry: next trading day's close
# Exit: 21st trading day's close
# Holding period: 20 trading days

spy_calendar <- spy %>%
  arrange(date) %>%
  mutate(
    entry_date = lead(date, 1),
    exit_date = lead(date, 21),
    spy_return =
      lead(spy_price, 21) /
      lead(spy_price, 1) - 1
  )

test_calendar <- spy_calendar %>%
  filter(
    date >= as.Date("2024-01-01"),
    date <= max(preds$date),
    !is.na(spy_return)
  )

# Rebalance every 20 trading days
signal_dates <- test_calendar$date[
  seq(1, nrow(test_calendar), by = 20)
]

cat("Backtest periods:", length(signal_dates), "\n")



stock_schedule <- prices %>%
  group_by(symbol) %>%
  arrange(date, .by_group = TRUE) %>%
  mutate(
    stock_entry = lead(date, 1),
    stock_exit = lead(date, 21)
  ) %>%
  ungroup() %>%
  select(date, symbol, stock_entry, stock_exit)

# Join predictions with historical features
panel <- preds %>%
  inner_join(
    df %>% select(
      date, symbol, mom_6m, target_end_date
    ),
    by = c("date", "symbol")
  ) %>%
  inner_join(
    stock_schedule,
    by = c("date", "symbol")
  ) %>%
  inner_join(
    spy_calendar %>% select(
      date, entry_date, exit_date, spy_return
    ),
    by = "date"
  ) %>%
  filter(
    date %in% signal_dates,
    stock_entry == entry_date,
    stock_exit == exit_date,
    target_end_date == exit_date
  )

# Every trading period must have enough stocks
coverage <- panel %>%
  count(date)

stopifnot(
  length(signal_dates) > 5,
  nrow(coverage) == length(signal_dates),
  all(coverage$n >= 10)
)

cat("Validated stocks per period:\n")
print(summary(coverage$n))


scores <- panel %>%
  pivot_longer(
    cols = c(
      original_pred,
      improved_pred,
      mom_6m
    ),
    names_to = "model",
    values_to = "score"
  ) %>%
  mutate(
    model = recode(
      model,
      original_pred = "Original XGBoost",
      improved_pred = "Improved XGBoost",
      mom_6m = "Momentum Benchmark"
    )
  )

# Equal-weight the 10 highest-ranked stocks
portfolios <- scores %>%
  group_by(date, model) %>%
  arrange(desc(score), symbol, .by_group = TRUE) %>%
  dplyr::slice_head(n = 10) %>%
  ungroup() %>%
  mutate(weight = 0.10)

# Save selected stocks
write.csv(
  portfolios %>%
    select(
      date, symbol, model, score,
      weight, target
    ),
  file.path(data_path, "selected_stocks.csv"),
  row.names = FALSE
)


portfolio_returns <- portfolios %>%
  group_by(date, model) %>%
  summarise(
    gross_return = sum(weight * target),
    .groups = "drop"
  ) %>%
  left_join(
    spy_calendar %>% select(date, exit_date),
    by = "date"
  )

# SPY buy-and-hold benchmark
spy_returns <- test_calendar %>%
  filter(date %in% signal_dates) %>%
  transmute(
    date,
    exit_date,
    model = "SPY Buy & Hold",
    gross_return = spy_return
  )

all_returns <- bind_rows(
  portfolio_returns,
  spy_returns
)



# Buy-and-hold SPY incurs cost only once.

transaction_cost <- 0.002

all_returns <- all_returns %>%
  group_by(model) %>%
  arrange(date, .by_group = TRUE) %>%
  mutate(
    period = row_number(),
    net_return = case_when(
      model == "SPY Buy & Hold" &
        period == 1 ~
        (1 + gross_return) *
        (1 - transaction_cost) - 1,
      
      model == "SPY Buy & Hold" ~
        gross_return,
      
      TRUE ~
        (1 + gross_return) *
        (1 - transaction_cost) - 1
    )
  ) %>%
  ungroup()



backtest <- all_returns %>%
  group_by(model) %>%
  arrange(date, .by_group = TRUE) %>%
  mutate(
    growth = cumprod(1 + net_return),
    peak = cummax(pmax(1, growth)),
    drawdown = growth / peak - 1
  ) %>%
  ungroup()



periods_per_year <- 252 / 20

performance <- backtest %>%
  group_by(model) %>%
  summarise(
    periods = n(),
    
    final_value = last(growth),
    
    cumulative_return = last(growth) - 1,
    
    annualized_return =
      last(growth)^(
        periods_per_year / n()
      ) - 1,
    
    sharpe =
      mean(net_return) /
      sd(net_return) *
      sqrt(periods_per_year),
    
    max_drawdown = min(drawdown),
    
    .groups = "drop"
  ) %>%
  arrange(desc(annualized_return))

cat("\n========== BACKTEST RESULTS ==========\n")

print(
  performance %>%
    mutate(
      across(
        c(
          final_value,
          cumulative_return,
          annualized_return,
          sharpe,
          max_drawdown
        ),
        ~ round(.x, 4)
      )
    ),
  width = Inf
)


write.csv(
  performance,
  file.path(data_path, "backtest_performance.csv"),
  row.names = FALSE
)

write.csv(
  backtest,
  file.path(data_path, "backtest_returns.csv"),
  row.names = FALSE
)



p1 <- ggplot(
  backtest,
  aes(
    x = exit_date,
    y = growth,
    color = model
  )
) +
  geom_line(linewidth = 1.1) +
  labs(
    title = "Investment Performance Comparison",
    subtitle = paste(
      "Top-10 portfolios vs. SPY |",
      "20-trading-day holding periods"
    ),
    x = "Date",
    y = "Growth of $1",
    color = "Strategy",
    caption = paste(
      "Illustrative backtest;",
      "assumes 20 bps round-trip trading cost."
    )
  ) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "bottom"
  )

print(p1)

ggsave(
  file.path(fig_path, "cumulative_returns.png"),
  plot = p1,
  width = 10,
  height = 6,
  dpi = 300
)



p2 <- ggplot(
  backtest,
  aes(
    x = exit_date,
    y = drawdown,
    color = model
  )
) +
  geom_line(linewidth = 1) +
  scale_y_continuous(
    labels = scales::percent
  ) +
  labs(
    title = "Strategy Drawdowns",
    x = "Date",
    y = "Drawdown",
    color = "Strategy"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "bottom")

print(p2)

ggsave(
  file.path(fig_path, "drawdown_comparison.png"),
  plot = p2,
  width = 10,
  height = 6,
  dpi = 300
)

cat("\nStep 6 completed successfully!\n")
