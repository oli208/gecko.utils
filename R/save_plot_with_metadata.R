#' Universal Plot Saving Function with Metadata
#'
#' A flexible function to save plots (ggplot2, base R, etc.) with a customizable filename.
#' The filename includes metadata such as the script name, plot name, and current date.
#'
#' @param plot_name A string for the plot's name, which will be part of the filename.
#' @param plot A ggplot2 plot object to save. If not provided, defaults to the last ggplot created (`ggplot2::last_plot()`).
#' @param save_dir Base directory for saving the plot. Uses the project-wide default path if set with `set_figure_save_path()`.
#' @param filetype The file type to save the plot. For base R plots, use "png" or "pdf". For ggplot2 plots, use any valid file type (e.g., "png", "pdf", "jpeg", "tiff", etc.)
#' @param prefix A logical or string indicating whether the script name should be included as a prefix in the filename. If a string is provided, it will be used as a custom prefix.
#' @param timestamp_format The date format used in filenames (default: "%y%m%d").
#' @param preserve_latest A logical indicating whether only the latest file version should be stored
#'                        with a consistent filename, without a date suffix.
#' @param latest_subdir Subdirectory to store the latest version if `preserve_latest = TRUE`.
#' @param archive_subdir Subdirectory to store older versions if `preserve_latest = TRUE`.
#' @param use_device Logical. If `TRUE`, the function will save from the active graphics device (useful for base R plots).
#' @param ... Additional arguments for `ggsave()` (ggplot2) or `png()` (base R), such as width, height, etc.
#' @return Returns the full path of the saved plot.
#'
#' @examples
#' library(ggplot2)
#' library(gecko.utils)
#' # Save a ggplot2 plot with metadata (scriptname, plot_name, date) in the filename
#' p <- ggplot(mtcars, aes(x = wt, y = mpg)) + geom_point()
#' save_plot_with_metadata(plot_name = "mtcars_scatter", save_dir = "figures")
#'
#' # Save a plot to always overwrite the previous version (useful for workflows with direct linked figures)
#' # The latest version will be stored in the "latest" subdirectory, if there is
#' # an older file with the same name, the old file will be archived.
#' save_plot_with_metadata("mtcars_scatter", save_dir = "figures", preserve_latest = TRUE)
#'
#' # Save a base R plot with a custom filename
#' plot(1:10, 1:10)
#' save_plot_with_metadata("base_r_plot", use_device = TRUE)
#'
#' @export
save_plot_with_metadata <- function(plot_name, plot = NULL, save_dir = getOption("figure_save_path", "./"),
                                    filetype = getOption("gecko.utils_default_filetype", "png"),
                                    prefix = TRUE, timestamp_format = "%y%m%d", preserve_latest = FALSE,
                                    latest_subdir = "latest", archive_subdir = "archive",
                                    use_device = FALSE, ...) {

    # check if the filetype is valid
    if (use_device && !filetype %in% c("png", "pdf")) {
        stop("Unsupported filetype for the plot type. Please use 'png' or 'pdf' for base R plots.")
    } else if (!use_device && !filetype %in% c("eps", "ps", "tex", "pdf", "jpeg", "tiff", "png", "bmp", "svg", "wmf")) {
        stop("Unsupported filetype for the plot type. Please use a valid file type for ggplot2 plots.")
    }

    # Normalize and create the main save directory if it doesn't exist
    normalized_save_dir <- normalizePath(save_dir, winslash = "/", mustWork = FALSE)
    if (!dir.exists(normalized_save_dir)) dir.create(normalized_save_dir, recursive = TRUE)

    # Set up directories for the latest and archive paths when preserve_latest is TRUE
    latest_path <- if (preserve_latest) file.path(normalized_save_dir, latest_subdir) else NULL
    archive_path <- if (preserve_latest) file.path(normalized_save_dir, archive_subdir) else NULL

    if (preserve_latest) {
        if (!dir.exists(latest_path)) dir.create(latest_path, recursive = TRUE)
        if (!dir.exists(archive_path)) dir.create(archive_path, recursive = TRUE)
    }

    # Base filename generation based on script name and plot name
#    script_name <- tools::file_path_sans_ext(basename(gecko.utils:::get_script_file_path()))
#    TODO what should happen if the script name is not available?

    if (is.logical(prefix) && prefix) {
        script_name <- tools::file_path_sans_ext(get_current_script_path(only_filename = TRUE, throw_error_if_missing = FALSE))
    } else if (is.character(prefix)) {
        script_name <- prefix
    } else {
        script_name <- NULL
    }

    # If script name is Null, base_filename should be only plot_name
    if (is.null(script_name)) {
        base_filename <- plot_name
    } else {
        base_filename <- paste0(script_name, "_", plot_name)
    }

    # Determine the final filename and move old versions if in "latest-only" mode
    if (preserve_latest) {
        latest_file <- file.path(latest_path, paste(base_filename, filetype, sep = "."))

        # Archive the previous version if it exists
        if (file.exists(latest_file)) {
            current_date <- format(Sys.time(), timestamp_format)
            archive_file <- file.path(archive_path, paste0(base_filename, "_", current_date, ".", filetype))
            if (!file.exists(archive_file)) {  # Prevent duplicate archiving
                file.rename(latest_file, archive_file)
                message(sprintf("Archived old version to: %s", archive_file))
            }
        }
        full_path <- latest_file  # Final file path for the latest version
    } else {
        # Standard mode: append timestamp to filename
        current_date <- format(Sys.time(), timestamp_format)
        full_path <- file.path(normalized_save_dir, paste0(base_filename, "_", current_date, ".", filetype))
    }

    # Use helper function to save plot based on plot type
    save_plot(
        full_path = full_path,
        plot_obj = plot,
        print_from_device = use_device,
        filetype = filetype,
        ...
    )

    # Return the path of the saved plot for logging or further use
    return(full_path)
}
