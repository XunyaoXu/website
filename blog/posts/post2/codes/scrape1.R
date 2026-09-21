# Blog Post 2
# Web Scraping Economic Consulting Job Postings
# The Brattle Group

library(rvest)
library(dplyr)
library(stringr)
library(tibble)
library(readr)
library(purrr)

# Read Brattle job board

brattle_url <- "https://job-boards.greenhouse.io/thebrattlegroup"

brattle_page <- read_html(brattle_url)


# Extract job links

brattle_links <- brattle_page |>
  html_elements("a")

brattle_jobs <- tibble(
  job_title = brattle_links |> html_text2(),
  href = brattle_links |> html_attr("href")
)

brattle_jobs <- brattle_jobs |>
  filter(
    !is.na(href),
    str_detect(href, "/thebrattlegroup/jobs/")
  ) |>
  mutate(
    company = "The Brattle Group",
    job_url = xml2::url_absolute(href, brattle_url)
  ) |>
  select(
    company,
    job_title,
    job_url
  ) |>
  filter(job_title != "") |>
  distinct(job_url, .keep_all = TRUE)


# Function to scrape an individual job page

scrape_brattle_job <- function(url) {
  
  page <- read_html(url)
  
  title <- page |>
    html_element("h1") |>
    html_text2()
  
  page_text <- page |>
    html_element("body") |>
    html_text2()
  
  tibble(
    job_title = title,
    job_url = url,
    job_description = page_text
  )
}


# Scrape all job postings

scrape_brattle_job_slow <- function(url) {
  
  Sys.sleep(1)
  
  scrape_brattle_job(url)
}

brattle_details <- map_dfr(
  brattle_jobs$job_url,
  scrape_brattle_job_slow
)



dir.create(
  "blog/posts/post2/data/raw",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(
  brattle_details,
  "blog/posts/post2/data/raw/brattle_job_details.csv"
)

print(nrow(brattle_details))


# Read CRA job board

cra_url <- "https://job-boards.greenhouse.io/charlesriverassociates"

cra_page <- read_html(cra_url)

cra_links <- cra_page |>
  html_elements("a")

length(cra_links)

# Extract CRA job links
cra_jobs <- tibble(
  job_title = cra_links |> html_text2(),
  href = cra_links |> html_attr("href")
)

cra_jobs <- cra_jobs |>
  filter(
    !is.na(href),
    str_detect(href, "/charlesriverassociates/jobs/")
  ) |>
  mutate(
    company = "Charles River Associates",
    job_url = xml2::url_absolute(href, cra_url)
  ) |>
  select(
    company,
    job_title,
    job_url
  ) |>
  filter(job_title != "") |>
  distinct(job_url, .keep_all = TRUE)

print(nrow(cra_jobs))
head(cra_jobs)


# CRA U.S. entry-level economics roles

cra_target_jobs <- tibble(
  company = "Charles River Associates",
  job_url = c(
    "https://job-boards.greenhouse.io/charlesriverassociates/jobs/7894191",
    "https://job-boards.greenhouse.io/charlesriverassociates/jobs/8120300"
  )
)

scrape_cra_job <- function(url) {
  
  Sys.sleep(1)
  
  page <- read_html(url)
  
  title <- page |>
    html_element("h1") |>
    html_text2()
  
  page_text <- page |>
    html_element("body") |>
    html_text2()
  
  tibble(
    job_title = title,
    job_url = url,
    job_description = page_text
  )
}

cra_details <- map_dfr(
  cra_target_jobs$job_url,
  scrape_cra_job
)

print(cra_details$job_title)


write_csv(
  cra_details,
  "blog/posts/post2/data/raw/cra_job_details.csv"
)
