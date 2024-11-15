library(testthat)
library(gecko.utils)
test_that("get_current_script_path returns the full path in RStudio or interactive mode", {
    # Assuming we're in RStudio or in a similar interactive session
    result <- gecko.utils:::get_current_script_path()
    expect_type(result, "character")
    expect_true(file.exists(result) || is.null(result))
})

test_that("get_current_script_path returns only the filename when only_filename = TRUE", {
    result <- gecko.utils:::get_current_script_path(only_filename = TRUE)
    expect_type(result, "character")

    # Check that the result does not contain directory paths
    expect_false(grepl("/", result, fixed = TRUE))
    expect_false(grepl("\\", result, fixed = TRUE))
})
