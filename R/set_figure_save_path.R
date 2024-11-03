#' Helper function to set figure_save_path in .Rprofile
#'
#' This function helps users set and persist the `figure_save_path` option in the project's `.Rprofile`.
#' Users can specify a directory to store figues and choose whether to apply the setting interactively.
#'
#' @param path Optional. A character string representing the directory to save figures. Defaults to NULL.
#' If NULL, the user is prompted interactively to input a path. You can use '../yourpathname' to go up one level.
#' @param interactive Logical. Whether to run the function interactively. Defaults to TRUE.
#' @param confirm_overwrite Logical. Whether to ask for confirmation before overwriting an existing .Rprofile file. Defaults to TRUE.
#'
#' @return The path that was set in the `.Rprofile` file.
#' @importFrom rprojroot find_rstudio_root_file
#' @export
set_figure_save_path <- function(path = NULL, interactive = TRUE, confirm_overwrite = TRUE) {

    # Get the current working directory and R project root
    project_root <- rprojroot::find_rstudio_root_file()
    rprofile_path <- file.path(project_root, ".Rprofile")

    # If path is not provided, prompt the user interactively (if interactive mode is enabled)
    if (is.null(path)) {
        if (interactive) {
            path <- readline("Enter the directory where you want to save ggplot images (e.g., 'images'): ")
        } else {
            stop("No path provided, and non-interactive mode is enabled.")
        }
    }

    # Validate the provided path
    if (!dir.exists(path)) {
        if (interactive) {
            dir_create <- readline(paste("Directory", path, "does not exist. Create it? (y/n): "))
            if (tolower(dir_create) == "y") {
                dir.create(path, recursive = TRUE)
                message("Directory created: ", path)
            } else {
                stop("Directory does not exist and was not created.")
            }
        } else {
            # Non-interactive mode automatically creates the directory
            dir.create(path, recursive = TRUE)
            message("Directory created: ", path)
        }
    }

    # Check if the .Rprofile exists
    if (file.exists(rprofile_path)) {
        if (confirm_overwrite && interactive) {
            overwrite <- readline("An .Rprofile already exists. Do you want to append the figure_save_path setting to it? (y/n): ")
            if (tolower(overwrite) != "y") {
                message("Operation canceled. No changes were made.")
                return(invisible(NULL))
            }
        }
    } else {
        message("No .Rprofile found in the project. A new one will be created.")
    }

    # Define the line to append
    figure_save_option <- paste0("options(figure_save_path = '", path, "')\n")

    # Append or create the .Rprofile with the new option
    write(figure_save_option, file = rprofile_path, append = TRUE)

    message("figure_save_path has been set to '", path, "' and saved in the project's .Rprofile.")
    message("You will need to restart your R session for the change to take effect.")

    return(invisible(path))
}
