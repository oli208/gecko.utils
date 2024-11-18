library(testthat)
library(ggplot2)
library(gecko.utils)

test_that("figure_info includes custom text in the caption", {
    info <- figure_info(custom_text = "Custom Text", include_r_version = FALSE)
    expect_true(grepl("Custom Text", info$caption_text))
})

test_that("figure_info includes R version in the caption when enabled", {
    info <- figure_info(include_r_version = TRUE)

    r_version <- utils::sessionInfo()$R.version$version.string
    r_version_clean <- sub("^R version ", "", r_version)

    # Construct the expected part of the caption text
    expected_r_version_text <- paste0("R Version: ", r_version_clean)

    expect_true(grepl(expected_r_version_text, info$caption_text, fixed = TRUE))
})


test_that("figure_info omits R version when include_r_version is FALSE", {
    info <- figure_info(include_r_version = FALSE)
    expect_false(grepl("R Version:", info$caption_text))
})

test_that("figure_info uses default datetime format if not specified", {
    info <- figure_info(include_r_version = FALSE)
    current_datetime <- format(Sys.time(), "%d.%m.%Y %X")
    expect_true(grepl(current_datetime, info$caption_text))
})


test_that("figure_info handles custom datetime format", {
    custom_format <- "%Y-%m-%d %H:%M:%S"
    info <- figure_info(datetime_format = custom_format, include_r_version = FALSE)
    current_datetime <- format(Sys.time(), custom_format)
    expect_true(grepl(current_datetime, info$caption_text))
})




test_that("figure_info integrates with ggplot objects", {
    info <- figure_info(custom_text = "Custom Metadata")
    p <- ggplot(mtcars, aes(x = wt, y = mpg)) + geom_point()
    p_with_info <- p + info
    expect_true(grepl("Custom Metadata", p_with_info$labels$caption))
})

test_that("figure_info warns if plot already has a caption", {
    info <- figure_info(custom_text = "Additional Metadata")
    p <- ggplot(mtcars, aes(x = wt, y = mpg)) + geom_point() + labs(caption = "Existing Caption")
    expect_warning(p + info, "The plot already has a caption. `figure_info\\(\\)` did not overwrite it.")
})

