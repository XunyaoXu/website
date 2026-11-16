
library(tidyverse)
library(slider)

prices <- readRDS(
  "blog/posts/post9/data/stock_prices.rds"
)

spy <- readRDS(
  "blog/posts/post9/data/spy_prices.rds"
)

df <- prices %>%
  group_by(symbol) %>%
  arrange(date, .by_group = TRUE) %>%
  mutate(
    # Daily return
    return = adjusted / lag(adjusted) - 1,
    
    # Momentum
    mom_1m = adjusted / lag(adjusted, 21) - 1,
    mom_3m = adjusted / lag(adjusted, 63) - 1,
    mom_6m = adjusted / lag(adjusted, 126) - 1,
    
    ret_5d = adjusted / lag(adjusted, 5) - 1,
    
    vol_1m = slide_dbl(
      return,
      sd,
      .before = 20,
      .complete = TRUE
    ),
    
   
    target = lead(adjusted, 21) /
      lead(adjusted, 1) - 1,
    
    target_end_date = lead(date, 21)
  ) %>%
  ungroup() %>%
  left_join(
    spy %>% select(date, spy_ret),
    by = "date"
  ) %>%
  mutate(
    excess_ret = return - spy_ret
  ) %>%
  select(
    date, symbol, adjusted,
    mom_1m, mom_3m, mom_6m,
    ret_5d, vol_1m, excess_ret,
    target, target_end_date
  ) %>%
  drop_na()

saveRDS(
  df,
  "blog/posts/post9/data/model_data.rds"
)

cat("Total observations:", nrow(df), "\n")
cat("Number of stocks:", n_distinct(df$symbol), "\n")
cat("Date range:",
    as.character(min(df$date)),
    "to",
    as.character(max(df$date)), "\n")

cat("\nTarget summary:\n")
summary(df$target)

cat("\nFirst observations:\n")
print(head(df))

