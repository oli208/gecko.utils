library(testthat)
library(gecko.utils)

test_that("get_current_script_path returns the full path in RStudio or interactive mode", {
  skip_if_not(rstudioapi::isAvailable(), "Skipping test: Not running inside RStudio")

  # Assuming we're in RStudio or in a similar interactive session
  result <- get_current_script_path()
  expect_type(result, "character")
  expect_true(file.exists(result) || is.null(result))
})

test_that("get_current_script_path returns only the filename when only_filename = TRUE", {
  skip_if_not(rstudioapi::isAvailable(), "Skipping test: Not running inside RStudio")

  result <- get_current_script_path(only_filename = TRUE)
  expect_type(result, "character")

  # Check that the result does not contain directory paths
  expect_false(grepl("/", result, fixed = TRUE))
  expect_false(grepl("\\", result, fixed = TRUE))
})


# Test get_current_script_path function
test_that("get_current_script_path works correctly inside RStudio", {
  skip_if_not(rstudioapi::isAvailable(), "Skipping test: Not running inside RStudio")

  script_path <- get_current_script_path()

  expect_type(script_path, "character") # Should return a character string
  expect_true(file.exists(script_path) || script_path == "") # The path should exist or be empty if no file is open
})

test_that("get_current_script_path returns only filename when only_filename = TRUE", {
  skip_if_not(rstudioapi::isAvailable(), "Skipping test: Not running inside RStudio")

  script_filename <- get_current_script_path(only_filename = TRUE)

  expect_type(script_filename, "character") # Should return a character string
  expect_false(grepl("/", script_filename, fixed = TRUE)) # Should not contain a full path
})
