
library(tidyverse)



base_path <- "blog/posts/post9/data"

df <- readRDS(
  file.path(base_path, "model_data.rds")
)

original <- readRDS(
  file.path(base_path, "original_predictions.rds")
)

improved <- readRDS(
  file.path(base_path, "improved_predictions.rds")
)



# Use only returns fully observed before 2024.
train <- df %>%
  dplyr::filter(
    target_end_date < as.Date("2024-01-01")
  )

historical_mean <- mean(train$target)

cat("Historical mean benchmark:",
    round(historical_mean, 5), "\n")



original_clean <- original %>%
  dplyr::select(
    date, symbol,
    original_pred = .pred
  )

improved_clean <- improved %>%
  dplyr::select(
    date, symbol,
    improved_pred = .pred
  )

# Check for duplicate date-stock combinations
stopifnot(
  nrow(original_clean) ==
    nrow(dplyr::distinct(original_clean, date, symbol)),
  nrow(improved_clean) ==
    nrow(dplyr::distinct(improved_clean, date, symbol))
)

actual <- df %>%
  dplyr::filter(
    date >= as.Date("2024-01-01")
  ) %>%
  dplyr::select(date, symbol, target)

comparison_data <- actual %>%
  dplyr::inner_join(
    original_clean,
    by = c("date", "symbol")
  ) %>%
  dplyr::inner_join(
    improved_clean,
    by = c("date", "symbol")
  ) %>%
  dplyr::mutate(
    historical_mean_pred = historical_mean,
    zero_pred = 0
  ) %>%
  dplyr::arrange(date, symbol)

stopifnot(
  nrow(comparison_data) > 0,
  !anyNA(comparison_data),
  nrow(comparison_data) <= nrow(actual)
)

cat("\nMatched test observations:",
    nrow(comparison_data), "\n")

cat("Original prediction observations:",
    nrow(original_clean), "\n")

cat("Improved prediction observations:",
    nrow(improved_clean), "\n")



evaluate_model <- function(actual, predicted,
                           benchmark_mean,
                           model_name) {
  
  errors <- actual - predicted
  
  rmse_value <- sqrt(mean(errors^2))
  mae_value <- mean(abs(errors))
  
  # Conventional R2 using the test-set mean
  r2_value <- 1 -
    sum(errors^2) /
    sum((actual - mean(actual))^2)
  
  # Out-of-sample R2 relative to historical mean
  oos_r2 <- 1 -
    sum(errors^2) /
    sum((actual - benchmark_mean)^2)
  
  # Direction accuracy is undefined for a
  # constant zero-return forecast
  direction <- if (all(predicted == 0)) {
    NA_real_
  } else {
    mean((predicted > 0) == (actual > 0))
  }
  
  tibble(
    Model = model_name,
    N = length(actual),
    RMSE = rmse_value,
    MAE = mae_value,
    R2 = r2_value,
    OOS_R2 = oos_r2,
    Direction_Accuracy = direction
  )
}



results <- dplyr::bind_rows(
  
  evaluate_model(
    comparison_data$target,
    comparison_data$historical_mean_pred,
    historical_mean,
    "Historical Mean Benchmark"
  ),
  
  evaluate_model(
    comparison_data$target,
    comparison_data$zero_pred,
    historical_mean,
    "Zero Return Benchmark"
  ),
  
  evaluate_model(
    comparison_data$target,
    comparison_data$original_pred,
    historical_mean,
    "Original XGBoost"
  ),
  
  evaluate_model(
    comparison_data$target,
    comparison_data$improved_pred,
    historical_mean,
    "Improved XGBoost"
  )
)



cat("\n========== MODEL COMPARISON ==========\n")

print(
  results %>%
    dplyr::mutate(
      RMSE = round(RMSE, 4),
      MAE = round(MAE, 4),
      R2 = round(R2, 4),
      OOS_R2 = round(OOS_R2, 4),
      Direction_Accuracy =
        round(Direction_Accuracy * 100, 2)
    ),
  width = Inf
)



# How often were actual returns positive?
always_up_accuracy <- mean(
  comparison_data$target > 0
)

cat(
  "\nAlways-predict-UP accuracy:",
  round(always_up_accuracy * 100, 2),
  "%\n"
)



original_rmse <- results$RMSE[
  results$Model == "Original XGBoost"
]

improved_rmse <- results$RMSE[
  results$Model == "Improved XGBoost"
]

rmse_improvement <- (
  original_rmse - improved_rmse
) / original_rmse * 100

cat(
  "\nRMSE improvement:",
  round(rmse_improvement, 2),
  "%\n"
)


write.csv(
  results,
  file.path(base_path, "model_comparison.csv"),
  row.names = FALSE
)

saveRDS(
  comparison_data,
  file.path(base_path, "comparison_predictions.rds")
)

cat("\nStep 5 completed successfully!\n")
