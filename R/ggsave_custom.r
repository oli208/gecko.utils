#' Custom ggsave function to save ggplot figures with metadata in filename
#'
#' This function saves a ggplot object with a custom filename that includes
#' the script name and the current date. It uses a flexible naming convention
#' to ensure better traceability of figures.
#'
#' @param name A string representing the name of the plot (to be included in the filename).
#' @param filepath The path where the file will be saved. Defaults to "../06_graphics/". You can use set_ggsave_path() to change the default path for your total R-project.
#' @param dateformat The date format to be used in the filename. Defaults to "%y%m%d".
#' @param ... Additional arguments passed to ggsave (e.g., width, height, etc.).
#' @return Saves a file and returns the full path of the saved file.
#' @details An error if the file path does not exist and cannot be created.
#' @export
ggsave_custom <- function(name, filepath = getOption("ggsave.path", "../06_graphics/"), dateformat = "%y%m%d", ...) {
    # Get the current script file path
    script_path <- get_script_file_path()

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

    # Save the current ggplot with the provided options, units default to cm
    ggsave(full_path, units = "cm", ...)

    # Return the full path of the saved file (useful for logging or confirmation)
    return(full_path)
}
