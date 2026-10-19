
# Blog Post 5: GIS Data Visualization
# The Geography of Income in Philadelphia

library(tidycensus)
library(dplyr)
library(sf)
library(ggplot2)
library(scales)


# Load saved ACS income and geographic data
# Source: U.S. Census Bureau, ACS 2024 5-Year Estimates

philly_income <- st_read(
  "blog/posts/post5/philly_income.gpkg",
  quiet = TRUE
)

print(nrow(philly_income))


philly_map <- philly_income %>%
  filter(!is.na(estimate), estimate >= 0)

income_summary <- philly_map %>%
  st_drop_geometry() %>%
  summarise(
    n_tracts = n(),
    min_income = min(estimate),
    median_income = median(estimate),
    mean_income = mean(estimate),
    max_income = max(estimate),
    p25 = quantile(estimate, 0.25),
    p75 = quantile(estimate, 0.75)
  )

print(income_summary)

income_plot <- ggplot(philly_map) +
  geom_sf(
    aes(fill = estimate),
    color = "white",
    linewidth = 0.15
  ) +
  scale_fill_distiller(
    palette = "YlOrRd",
    direction = 1,
    labels = label_dollar(),
    name = "Median Household Income"
  ) +
  labs(
    title = "The Geography of Income in Philadelphia",
    subtitle = "Median Household Income by Census Tract, 2020–2024",
    caption = "Source: U.S. Census Bureau, ACS 2024 5-Year Estimates"
  ) +
  theme_void() +
  theme(
    plot.title = element_text(
      size = 20, face = "bold", hjust = 0.5
    ),
    plot.subtitle = element_text(
      size = 13, hjust = 0.5
    ),
    plot.caption = element_text(size = 10),
    legend.position = "bottom",
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10),
    plot.margin = margin(10, 10, 10, 10)
  ) +
  guides(
    fill = guide_colorbar(
      title.position = "top",
      barwidth = unit(8, "cm"),
      barheight = unit(0.6, "cm")
    )
  )

# Save results
output_dir <- "blog/posts/post5"

ggsave(
  filename = file.path(output_dir, "philly_income_map.png"),
  plot = income_plot,
  width = 10,
  height = 8,
  dpi = 300
)

write.csv(
  income_summary,
  file.path(output_dir, "income_summary.csv"),
  row.names = FALSE
)

print("Analysis completed successfully!")
