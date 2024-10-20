#' Save ggplot figure for LaTeX workflow with file version management
#'
#' This function saves ggplot figures to a directory used for LaTeX, ensuring that only the newest
#' version of each figure (without a date in the filename) is stored. Older versions are moved to an archive.
#'
#' @param plot_name A string representing the name of the plot (to be included in the filename).
#' @param plot_obj The ggplot object to be saved.
#'                 If not provided, it will use the last ggplot created (`ggplot2::last_plot()`).
#' @param base_dir The base path for the plot. Defaults to current working directory. You can use set_ggsave_path() to change the default path for your total R-project.
#' @param latex_subdir The subdirectory for LaTeX files within the base path. Defaults to "latex".
#' @param archive_subdir The subdirectory where older versions are moved. Defaults to "archive".
#' @param date_format The date format to be used for archiving. Defaults to "%y%m%d".
#' @param print_from_device A logical value indicating whether to print the plot from the device (base R plot) or from ggplot2. Defaults to FALSE.
#' @param ... Additional arguments passed to ggsave (e.g., width, height, etc.).
#' @return The full path of the saved figure in the LaTeX directory.
#' @export
ggsave_latex <- function(plot_name, plot_obj = NULL, base_dir = getOption("ggsave.path", "./"),
                         latex_subdir = "latex", archive_subdir = "archive",
                         date_format = "%y%m%d", print_from_device = FALSE, ...) {

    # Construct full paths for the LaTeX and archive directories
    latex_dir <- file.path(base_dir, latex_subdir)
    archive_dir <- file.path(base_dir, archive_subdir)

    # Ensure both the LaTeX and archive directories exist
    if (!dir.exists(archive_dir)) {
        dir.create(archive_dir, recursive = TRUE)
    }

    if (!dir.exists(latex_dir)) {
        dir.create(latex_dir, recursive = TRUE)
    }

    # Get the script name and create the base filename without date
    script_name <- tools::file_path_sans_ext(basename(gecko.utils:::get_script_file_path()))
    base_filename <- paste0(script_name, "_", plot_name)

    # Full path for the LaTeX file (without date)
    latex_file <- file.path(latex_dir, paste0(base_filename, ".png"))

    # Check if an older version of the plot already exists in the LaTeX folder
    if (file.exists(latex_file)) {
        # Move the old version to the archive with the current date suffix
        current_date <- format(Sys.time(), date_format)
        archive_file <- file.path(archive_dir, paste0(base_filename, "_", current_date, ".png"))

        file.rename(latex_file, archive_file)
        message(sprintf("Moved old version to archive: %s", archive_file))
    }

    # Save the new plot in the LaTeX folder without the date in the filename
    gecko.utils:::save_plot(full_path = latex_file,
                            plot_obj = plot_obj,
                            print_from_device = print_from_device,
                            ...
    )


    message(sprintf("Saved new figure in LaTeX folder: %s", latex_file))

    # Return the path of the saved LaTeX figure
    return(latex_file)
}
