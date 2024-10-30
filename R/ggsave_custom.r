#' Save plot with custom filename for multiple plot types
#'
#' @description
#' `r lifecycle::badge("superseded")`
#'
#' The functionality of this function has been superseded by the `save_plot_with_metadata()` function.
#'
#'
#' This function saves a plots with a custom filename that includes
#' the script name, plot name and the current date. It uses a flexible naming convention
#' to ensure better traceability of figures.
#' If no plot is provided, it will save the last ggplot created or the active plot on the graphics device.
#'
#' @param name A string representing the name of the plot (to be included in the filename).
#' @param plot_obj The ggplot object to be saved.
#'                 If not provided, it will use the last ggplot created (`ggplot2::last_plot()`).
#' @param filepath The directory where the file will be saved. Defaults to current working directory . You can use set_ggsave_path() to change the default path for your total R-project.
#' @param dateformat The date format to be used in the filename. Defaults to "%y%m%d".
#' @param print_from_device A logical value indicating whether to print the plot from the device (base R plot) or from ggplot2. Defaults to FALSE.
#' @param ... Additional arguments passed to `ggplot2::ggsave()`` or `png()` (e.g., width, height, etc.).
#' @return Saves a file and returns the full path of the saved file.
#' @details An error if the file path does not exist and cannot be created.
#' @export
ggsave_custom <- function(name, plot_obj = NULL, filepath = getOption("figure_save_path", "./"),
                          dateformat = "%y%m%d", print_from_device = FALSE, ...) {
    lifecycle::deprecate_warn("0.0.1", "ggsave_custom()", "save_plot_with_metadata()")



     # Get the current script file path
    script_path <- gecko.utils:::get_current_script_path()

    # Extract the script filename without extension
    script_filename <- tools::file_path_sans_ext(basename(script_path))

    # Format the current date
    current_date <- format(Sys.time(), format = dateformat)

    # Ensure the filepath is normalized and create the directory if it doesn't exist
    normalized_filepath <- normalizePath(filepath, winslash = "/",  mustWork = FALSE)
    if (!dir.exists(normalized_filepath)) {
        dir.create(normalized_filepath, recursive = TRUE)
    }

    # Create the full output file path (with PNG extension)
    full_path <- file.path(normalized_filepath, paste0(script_filename, "_", name, "_", current_date, ".png"))

    # Use helper function to save the plot based on the plot_type
    gecko.utils:::save_plot(full_path = full_path,
                            plot_obj = plot_obj,
                            print_from_device = print_from_device,
                            ...
                            )


    # Return the full path of the saved file (useful for logging or confirmation)
    return(full_path)
}
