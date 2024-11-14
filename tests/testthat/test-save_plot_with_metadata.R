library(testthat)
library(ggplot2)
library(gecko.utils)

# Test Setup: Create a temporary directory to avoid cluttering the working directory
temp_dir <- tempdir()

test_that("save_plot_with_metadata saves ggplot2 plot with default naming convention", {
    # Create a simple ggplot
    p <- ggplot(mtcars, aes(x = wt, y = mpg)) + geom_point()

    # Run the function
    saved_path <- save_plot_with_metadata("test_plot", plot = p, save_dir = temp_dir)

    # Check that the file exists
    expect_true(file.exists(saved_path))

    # Clean up
    file.remove(saved_path)
})

test_that("save_plot_with_metadata saves last ggplot2 plot when plot is not specified", {
    # Create a simple ggplot
    p <- ggplot(mtcars, aes(x = wt, y = mpg)) + geom_point()
    print(p) # Save as last_plot()

    # Run the function without specifying plot
    saved_path <- save_plot_with_metadata("test_last_plot", save_dir = temp_dir)

    # Check that the file exists
    expect_true(file.exists(saved_path))

    # Clean up
    file.remove(saved_path)
})

test_that("save_plot_with_metadata saves base R plot using device copy", {
    # Create a base R plot
    plot(1:10, 1:10)

    # Run the function with device-based saving
    saved_path <- save_plot_with_metadata("test_base_r_plot", use_device = TRUE, save_dir = temp_dir, filetype = "png")

    # Check that the file exists
    expect_true(file.exists(saved_path))

    # Clean up
    file.remove(saved_path)
})

test_that("save_plot_with_metadata preserves filename and moves older versions to archive", {
    # Create a simple ggplot
    p <- ggplot(mtcars, aes(x = wt, y = mpg)) + geom_point()

    # Define paths for latest and archive folders
    latest_dir <- file.path(temp_dir, "latest")
    archive_dir <- file.path(temp_dir, "archive")

    # Save first version with preserve_latest = TRUE
    saved_path_1 <- save_plot_with_metadata("test_preserve", plot = p, save_dir = temp_dir, preserve_latest = TRUE,
                                            latest_subdir = "latest", archive_subdir = "archive")
    expect_true(file.exists(saved_path_1))

    # Save second version, which should trigger archiving of the first
    Sys.sleep(1)  # Ensure a slight delay so the timestamp changes
    saved_path_2 <- save_plot_with_metadata("test_preserve", plot = p, save_dir = temp_dir, preserve_latest = TRUE,
                                            latest_subdir = "latest", archive_subdir = "archive")
    expect_true(file.exists(saved_path_2))

    # Check that the first version has been moved to the archive folder
    archived_files <- list.files(archive_dir, pattern = "test_preserve", full.names = TRUE)
    expect_true(length(archived_files) > 0)

    # Clean up
    file.remove(saved_path_2)
    file.remove(archived_files)
    unlink(latest_dir, recursive = TRUE)
    unlink(archive_dir, recursive = TRUE)
})

test_that("save_plot_with_metadata handles invalid directories gracefully", {
    # Define an invalid directory path
    invalid_dir <- file.path(temp_dir, "invalid", "nested", "path")

    # Create a simple ggplot
    p <- ggplot(mtcars, aes(x = wt, y = mpg)) + geom_point()

    # Run the function with the invalid path (it should create the directory structure)
    saved_path <- save_plot_with_metadata("test_invalid_dir", plot = p, save_dir = invalid_dir)

    # Check that the file exists and that the directories were created
    expect_true(file.exists(saved_path))
    expect_true(dir.exists(invalid_dir))

    # Clean up
    file.remove(saved_path)
    unlink(invalid_dir, recursive = TRUE)
})


test_that("save_plot_with_metadata saves base R plot using pdf", {
    # Create a base R plot
    plot(1:10, 1:10)

    # Run the function with filetype pdf
    saved_path <- save_plot_with_metadata("test_base_r_plot", use_device = TRUE, save_dir = temp_dir, filetype = "pdf")

    # Check that the file exists
    expect_true(file.exists(saved_path))

    # Clean up
    file.remove(saved_path)
})

