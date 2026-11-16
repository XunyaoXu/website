
library(tidyverse)
library(tidymodels)
library(xgboost)

set.seed(123)

base_path <- "blog/posts/post9"
data_path <- file.path(base_path, "data")
fig_path <- file.path(base_path, "figures")

dir.create(fig_path, recursive = TRUE,
           showWarnings = FALSE)



metrics <- read.csv(
  file.path(data_path, "model_comparison.csv")
)

preds <- readRDS(
  file.path(data_path, "comparison_predictions.rds")
)

improved_fit <- readRDS(
  file.path(data_path, "improved_model.rds")
)



plot_metrics <- metrics %>%
  pivot_longer(
    cols = c(RMSE, MAE),
    names_to = "Metric",
    values_to = "Value"
  ) %>%
  mutate(
    Model = factor(Model, levels = unique(metrics$Model))
  )

p1 <- ggplot(
  plot_metrics,
  aes(x = Model, y = Value, fill = Model)
) +
  geom_col(width = 0.65) +
  facet_wrap(~Metric, scales = "free_y") +
  geom_text(
    aes(label = sprintf("%.4f", Value)),
    vjust = -0.5,
    size = 3.5
  ) +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.15))
  ) +
  labs(
    title = "Out-of-Sample Prediction Errors",
    subtitle = "Lower values indicate better predictions",
    x = NULL,
    y = "Prediction Error"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "none",
    axis.text.x = element_text(
      angle = 25, hjust = 1
    )
  )

print(p1)

ggsave(
  file.path(fig_path, "prediction_errors.png"),
  plot = p1,
  width = 10,
  height = 6,
  dpi = 300
)



scatter_data <- preds %>%
  dplyr::slice_sample(
    n = min(4000, nrow(preds))
  ) %>%
  dplyr::select(
    target, original_pred, improved_pred
  ) %>%
  pivot_longer(
    cols = c(original_pred, improved_pred),
    names_to = "Model",
    values_to = "Predicted"
  ) %>%
  mutate(
    Model = recode(
      Model,
      original_pred = "Original XGBoost",
      improved_pred = "Improved XGBoost"
    )
  )

p2 <- ggplot(
  scatter_data,
  aes(x = target, y = Predicted)
) +
  geom_point(alpha = 0.13, size = 0.9) +
  geom_abline(
    slope = 1, intercept = 0,
    linetype = "dashed"
  ) +
  facet_wrap(~Model) +
  coord_cartesian(
    xlim = c(-0.3, 0.4),
    ylim = c(-0.3, 0.4)
  ) +
  labs(
    title = "Actual vs. Predicted Stock Returns",
    subtitle = "Random sample of 4,000 test observations",
    x = "Actual 20-Day Return",
    y = "Predicted 20-Day Return",
    caption = "Display restricted to -30% to +40%."
  ) +
  theme_minimal(base_size = 13)

print(p2)

ggsave(
  file.path(fig_path, "actual_vs_predicted.png"),
  plot = p2,
  width = 10,
  height = 6,
  dpi = 300
)



xgb_engine <- workflows::extract_fit_engine(
  improved_fit
)

importance <- xgboost::xgb.importance(
  model = xgb_engine
)

importance_top <- importance %>%
  as_tibble() %>%
  dplyr::slice_head(n = 12)

p3 <- ggplot(
  importance_top,
  aes(
    x = reorder(Feature, Gain),
    y = Gain
  )
) +
  geom_col() +
  coord_flip() +
  scale_y_continuous(
    labels = scales::percent
  ) +
  labs(
    title = "Improved XGBoost: Feature Importance",
    subtitle = "Importance measured using XGBoost Gain",
    x = NULL,
    y = "Feature Importance"
  ) +
  theme_minimal(base_size = 13)

print(p3)

ggsave(
  file.path(fig_path, "feature_importance.png"),
  plot = p3,
  width = 10,
  height = 6,
  dpi = 300
)

cat("\nStep 7 completed successfully!\n")

