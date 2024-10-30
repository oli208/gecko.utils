#' Get the full path or filename of the currently running script
#'
#' This function attempts to retrieve the path of the currently active script
#' in RStudio or the currently sourced script in non-interactive sessions.
#' If neither is available, it will return `NULL` or throw an error based on the specified `throw_error_if_missing` parameter.
#'
#' @param only_filename Logical; if `TRUE`, only the filename (not the full path) is returned. Defaults to `FALSE`.
#' @param throw_error_if_missing Logical; if `TRUE`, throws an error if the path cannot be determined. If `FALSE`, returns `NULL`. Defaults to `TRUE`.
#' @return A string with either the full normalized path or just the filename of the current script, based on `only_filename`.
#' @details Returns `NULL` if the script path cannot be determined and `throw_error_if_missing` is set to `FALSE`.
#' @importFrom rstudioapi getActiveDocumentContext isAvailable
#' @examples
#' get_current_script_path() # Returns full path if available
#' get_current_script_path(only_filename = TRUE) # Returns only the filename of current file
#' @export
get_current_script_path <- function(only_filename = FALSE, throw_error_if_missing = TRUE) {
    # Try to get the active document path in RStudio
    current_script_path <- tryCatch({
        if (rstudioapi::isAvailable()) {
            rstudioapi::getActiveDocumentContext()$path
        }
    }, error = function(e) {
        if (throw_error_if_missing) {
            stop("Unable to determine the script file path. This may happen if you are not using RStudio or sourcing a script.")
        } else {
            return(NULL)
        }
    })

    # If only_filename is TRUE, extract just the filename
    if (!is.null(current_script_path) && only_filename) {
        current_script_path <- basename(current_script_path)
    }

    # Return the script path or filename
    current_script_path
}
