# Blog Post 2
# Analysis of Technical Skills

library(dplyr)
library(stringr)
library(readr)

library(tidyr)
library(ggplot2)


# 1.Brattle_Job

brattle_details <- read_csv(
  "blog/posts/post2/data/raw/brattle_job_details.csv",
  show_col_types = FALSE
)



brattle_skills <- brattle_details |>
  mutate(
    description_lower = str_to_lower(job_description),
    
    excel = str_detect(description_lower, "\\bexcel\\b"),
    python = str_detect(description_lower, "\\bpython\\b"),
    stata = str_detect(description_lower, "\\bstata\\b"),
    sql = str_detect(description_lower, "\\bsql\\b"),
    sas = str_detect(description_lower, "\\bsas\\b"),
    vba = str_detect(description_lower, "\\bvba\\b"),
    gams = str_detect(description_lower, "\\bgams\\b"),
    
    r = str_detect(
      job_description,
      regex("\\bR\\b(?!\\s*&\\s*D\\b)", ignore_case = FALSE)
    )
  )



skill_counts <- brattle_skills |>
  summarise(
    excel = sum(excel),
    r = sum(r),
    python = sum(python),
    stata = sum(stata),
    sql = sum(sql),
    sas = sum(sas),
    vba = sum(vba),
    gams = sum(gams)
  )

print(skill_counts)




entry_jobs <- brattle_skills |>
  filter(
    str_detect(
      job_title,
      regex("analyst|intern", ignore_case = TRUE)
    ),
    !str_detect(
      job_title,
      regex("senior|manager|principal|director", ignore_case = TRUE)
    )
  ) |>
  distinct(job_title, .keep_all = TRUE)

# find U.S.-focused entry-level roles
entry_jobs_us <- entry_jobs |>
  filter(
    !str_detect(
      job_title,
      regex("Sydney", ignore_case = TRUE)
    )
  )

entry_skill_counts <- entry_jobs_us |>
  summarise(
    excel = sum(excel),
    r = sum(r),
    python = sum(python),
    stata = sum(stata),
    sql = sum(sql),
    sas = sum(sas),
    vba = sum(vba),
    gams = sum(gams)
  )


r_check <- entry_jobs_us |>
  transmute(
    job_title,
    r_context = str_extract(
      job_description,
      regex(
        ".{0,60}\\bR\\b(?!\\s*&\\s*D\\b).{0,60}",
        ignore_case = FALSE,
        dotall = TRUE
      )
    )
  )

print(r_check)



# CRA_Jobs

cra_details <- read_csv(
  "blog/posts/post2/data/raw/cra_job_details.csv",
  show_col_types = FALSE
)


cra_skills <- cra_details |>
  mutate(
    description_lower = str_to_lower(job_description),
    
    excel = str_detect(description_lower, "\\bexcel\\b"),
    python = str_detect(description_lower, "\\bpython\\b"),
    stata = str_detect(description_lower, "\\bstata\\b"),
    sql = str_detect(description_lower, "\\bsql\\b"),
    sas = str_detect(description_lower, "\\bsas\\b"),
    vba = str_detect(description_lower, "\\bvba\\b"),
    gams = str_detect(description_lower, "\\bgams\\b"),
    
    r = str_detect(
      job_description,
      regex("\\bR\\b(?!\\s*&\\s*D\\b)", ignore_case = FALSE)
    )
  )


cra_skill_counts <- cra_skills |>
  summarise(
    excel = sum(excel),
    r = sum(r),
    python = sum(python),
    stata = sum(stata),
    sql = sum(sql),
    sas = sum(sas),
    vba = sum(vba),
    gams = sum(gams)
  )

print(cra_skill_counts)



# Combine Brattle and CRA entry-level roles

brattle_final <- entry_jobs_us |>
  mutate(company = "The Brattle Group") |>
  select(
    company,
    job_title,
    excel,
    r,
    python,
    stata,
    sql,
    sas,
    vba,
    gams
  )

cra_final <- cra_skills |>
  mutate(company = "Charles River Associates") |>
  select(
    company,
    job_title,
    excel,
    r,
    python,
    stata,
    sql,
    sas,
    vba,
    gams
  )

all_jobs <- bind_rows(
  brattle_final,
  cra_final
)

print(all_jobs)
print(nrow(all_jobs))


overall_skill_counts <- all_jobs |>
  summarise(
    excel = sum(excel),
    r = sum(r),
    python = sum(python),
    stata = sum(stata),
    sql = sum(sql),
    sas = sum(sas),
    vba = sum(vba),
    gams = sum(gams)
  )

print(overall_skill_counts)



# Create overall skill frequency table

skill_summary <- overall_skill_counts |>
  pivot_longer(
    cols = everything(),
    names_to = "skill",
    values_to = "count"
  ) |>
  mutate(
    percent = count / nrow(all_jobs),
    skill = recode(
      skill,
      excel = "Excel",
      r = "R",
      python = "Python",
      stata = "Stata",
      sql = "SQL",
      sas = "SAS",
      vba = "VBA",
      gams = "GAMS"
    )
  ) |>
  arrange(desc(percent))

print(skill_summary)


# Figure 1: Overall skill frequency

skill_summary <- skill_summary |>
  mutate(
    skill = factor(
      skill,
      levels = c(
        "GAMS", "SQL", "SAS", "VBA",
        "Stata", "Python", "R", "Excel"
      )
    )
  )

skill_plot <- ggplot(
  skill_summary,
  aes(x = skill, y = percent)
) +
  geom_col() +
  geom_text(
    aes(label = scales::percent(percent, accuracy = 1)),
    hjust = -0.15,
    size = 4
  ) +
  coord_flip() +
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 1),
    limits = c(0, 1.08)
  ) +
  labs(
    title = "Technical Skills Mentioned in Entry-Level Economic Consulting Job Postings",
    subtitle = "Share of unique U.S. entry-level job types mentioning each skill",
    x = NULL,
    y = "Share of job types",
    caption = "Source: The Brattle Group and Charles River Associates job postings"
  ) +
  theme_minimal()

print(skill_plot)


ggsave(
  "blog/posts/post2/result/skill_frequency.png",
  skill_plot,
  width = 8,
  height = 5,
  dpi = 300
)

# Compare skill requirements by company

company_skill_summary <- all_jobs |>
  pivot_longer(
    cols = c(excel, r, python, stata, sql, sas, vba, gams),
    names_to = "skill",
    values_to = "mentioned"
  ) |>
  group_by(company, skill) |>
  summarise(
    percent = mean(mentioned),
    .groups = "drop"
  ) |>
  mutate(
    skill = recode(
      skill,
      excel = "Excel",
      r = "R",
      python = "Python",
      stata = "Stata",
      sql = "SQL",
      sas = "SAS",
      vba = "VBA",
      gams = "GAMS"
    )
  )

print(company_skill_summary)

company_plot <- ggplot(
  company_skill_summary,
  aes(
    x = skill,
    y = percent,
    fill = company
  )
) +
  geom_col(
    position = "dodge"
  ) +
  coord_flip() +
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 1),
    limits = c(0, 1)
  ) +
  labs(
    title = "Technical Skill Requirements Differ Across Consulting Firms",
    subtitle = "Share of unique entry-level job types mentioning each skill",
    x = NULL,
    y = "Share of job types",
    fill = "Company",
    caption = "Source: The Brattle Group and Charles River Associates job postings"
  ) +
  theme_minimal()

print(company_plot)

ggsave(
  "blog/posts/post2/result/company_skill_comparison.png",
  company_plot,
  width = 8,
  height = 5,
  dpi = 300
)

