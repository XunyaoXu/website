
library(tidyverse)
library(tidymodels)
library(xgboost)

set.seed(123)

df <- readRDS(
  "blog/posts/post9/data/model_data.rds"
)

features <- c(
  "mom_1m",
  "mom_3m",
  "mom_6m",
  "ret_5d",
  "vol_1m",
  "excess_ret"
)

train <- df %>%
  filter(target_end_date < as.Date("2024-01-01"))

test <- df %>%
  filter(date >= as.Date("2024-01-01"))

cat("Training observations:", nrow(train), "\n")
cat("Testing observations:", nrow(test), "\n")

xgb_spec <- boost_tree(
  trees = 300,
  tree_depth = 5,
  learn_rate = 0.05,
  loss_reduction = 0,
  min_n = 10
) %>%
  set_engine("xgboost") %>%
  set_mode("regression")

rec <- recipe(
  target ~ mom_1m + mom_3m + mom_6m +
    ret_5d + vol_1m + excess_ret,
  data = train
)

wf <- workflow() %>%
  add_recipe(rec) %>%
  add_model(xgb_spec)

original_fit <- fit(wf, data = train)

preds_original <- predict(original_fit, test) %>%
  bind_cols(
    test %>% select(
      date, symbol, target, target_end_date
    )
  )

rmse_original <- rmse(
  preds_original, truth = target, estimate = .pred
)

mae_original <- mae(
  preds_original, truth = target, estimate = .pred
)

rsq_original <- rsq_trad(
  preds_original, truth = target, estimate = .pred
)

direction_accuracy <- mean(
  sign(preds_original$.pred) ==
    sign(preds_original$target)
)

# 10. Display results
print(rmse_original)
print(mae_original)
print(rsq_original)

cat(
  "Direction accuracy:",
  round(direction_accuracy * 100, 2),
  "%\n"
)

saveRDS(
  original_fit,
  "blog/posts/post9/data/original_model.rds"
)

saveRDS(
  preds_original,
  "blog/posts/post9/data/original_predictions.rds"
)

cat("\nOriginal model completed successfully!\n")
›