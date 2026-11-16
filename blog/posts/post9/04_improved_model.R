
library(tidyverse)
library(tidymodels)
library(xgboost)
library(slider)

set.seed(123)

base_path <- "blog/posts/post9/data"


df <- readRDS(file.path(base_path, "model_data.rds"))
prices <- readRDS(file.path(base_path, "stock_prices.rds"))
spy <- readRDS(file.path(base_path, "spy_prices.rds"))



extra_features <- prices %>%
  group_by(symbol) %>%
  arrange(date, .by_group = TRUE) %>%
  mutate(
    daily_ret = adjusted / lag(adjusted) - 1,
    
    mom_10d = adjusted / lag(adjusted, 10) - 1,
    mom_2m = adjusted / lag(adjusted, 42) - 1,
    
    vol_3m = slide_dbl(
      daily_ret,
      sd,
      .before = 62,
      .complete = TRUE
    ),
    
    ma_20 = slide_dbl(
      adjusted,
      mean,
      .before = 19,
      .complete = TRUE
    ),
    
    price_to_ma20 = adjusted / ma_20 - 1
  ) %>%
  ungroup() %>%
  select(
    date, symbol,
    mom_10d, mom_2m,
    vol_3m, price_to_ma20
  )

market_features <- spy %>%
  arrange(date) %>%
  mutate(
    spy_mom_1m = spy_price / lag(spy_price, 21) - 1
  ) %>%
  select(date, spy_mom_1m)

df_improved <- df %>%
  left_join(extra_features, by = c("date", "symbol")) %>%
  left_join(market_features, by = "date") %>%
  drop_na()


features <- c(
  "mom_1m", "mom_3m", "mom_6m",
  "ret_5d", "vol_1m", "excess_ret",
  "mom_10d", "mom_2m",
  "vol_3m", "price_to_ma20",
  "spy_mom_1m"
)


train_initial <- df_improved %>%
  filter(target_end_date < as.Date("2023-01-01"))

validation <- df_improved %>%
  filter(
    date >= as.Date("2023-01-01"),
    target_end_date < as.Date("2024-01-01")
  )

train_final <- df_improved %>%
  filter(target_end_date < as.Date("2024-01-01"))

test <- df_improved %>%
  filter(date >= as.Date("2024-01-01"))

cat("Initial training:", nrow(train_initial), "\n")
cat("Validation:", nrow(validation), "\n")
cat("Final training:", nrow(train_final), "\n")
cat("Testing:", nrow(test), "\n")

stopifnot(
  nrow(train_initial) > 0,
  nrow(validation) > 0,
  nrow(test) > 0,
  max(train_initial$target_end_date) <
    min(validation$date),
  max(train_final$target_end_date) <
    min(test$date)
)


fit_xgb <- function(data, trees, depth, lr, min_n) {
  
  spec <- boost_tree(
    trees = trees,
    tree_depth = depth,
    learn_rate = lr,
    loss_reduction = 0,
    min_n = min_n
  ) %>%
    set_engine("xgboost", nthread = 2) %>%
    set_mode("regression")
  
  rec <- recipe(
    target ~ .,
    data = data %>% select(all_of(features), target)
  )
  
  wf <- workflow() %>%
    add_recipe(rec) %>%
    add_model(spec)
  
  fit(
    wf,
    data = data %>% select(all_of(features), target)
  )
}



params <- tibble(
  trees = c(150L, 300L, 500L, 300L),
  depth = c(2L, 3L, 3L, 4L),
  lr = c(0.03, 0.03, 0.01, 0.05),
  min_n = c(20L, 20L, 30L, 30L)
)



tuning_results <- vector("list", nrow(params))

for (i in seq_len(nrow(params))) {
  
  cat("Training candidate", i, "of", nrow(params), "\n")
  
  model <- fit_xgb(
    train_initial,
    trees = params$trees[i],
    depth = params$depth[i],
    lr = params$lr[i],
    min_n = params$min_n[i]
  )
  
  val_pred <- predict(
    model,
    validation %>% select(all_of(features))
  )$.pred
  
  val_rmse <- sqrt(
    mean((validation$target - val_pred)^2)
  )
  
  tuning_results[[i]] <- tibble(
    model_id = i,
    rmse = val_rmse
  )
}

tuning_summary <- bind_rows(tuning_results) %>%
  left_join(
    params %>% mutate(model_id = row_number()),
    by = "model_id"
  ) %>%
  arrange(rmse)

print(tuning_summary)



best <- dplyr::slice(tuning_summary, 1)

cat("\nBest parameters:\n")
print(best)



improved_fit <- fit_xgb(
  train_final,
  trees = best$trees,
  depth = best$depth,
  lr = best$lr,
  min_n = best$min_n
)



preds_improved <- predict(
  improved_fit,
  test %>% select(all_of(features))
) %>%
  bind_cols(
    test %>% select(
      date, symbol, target, target_end_date
    )
  )



rmse_improved <- rmse(
  preds_improved,
  truth = target,
  estimate = .pred
)

mae_improved <- mae(
  preds_improved,
  truth = target,
  estimate = .pred
)

rsq_improved <- rsq_trad(
  preds_improved,
  truth = target,
  estimate = .pred
)

direction_improved <- mean(
  sign(preds_improved$.pred) ==
    sign(preds_improved$target)
)

cat("\n===== IMPROVED MODEL RESULTS =====\n")

print(rmse_improved)
print(mae_improved)
print(rsq_improved)

cat(
  "Direction Accuracy:",
  round(direction_improved * 100, 2),
  "%\n"
)


saveRDS(
  improved_fit,
  file.path(base_path, "improved_model.rds")
)

saveRDS(
  preds_improved,
  file.path(base_path, "improved_predictions.rds")
)

write.csv(
  tuning_summary,
  file.path(base_path, "tuning_results.csv"),
  row.names = FALSE
)

cat("\nImproved model completed successfully!\n")

