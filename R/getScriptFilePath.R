#' Get the file path of the currently running script
#'
#' This function attempts to retrieve the path of the currently active script
#' in RStudio or the currently sourced script in non-interactive sessions.
#' If neither is available, it will throw an error.
#'
#' @return A string with the full normalized path of the current script.
#' @throws An error if the script path cannot be determined.
get_script_file_path <- function() {
    script_path <- tryCatch({
        # Try to get the active document path in RStudio
        rstudioapi::getActiveDocumentContext()$path
    }, error = function(e) {
        # Fallback to get the file path from the sourced script
        tryCatch({
            normalizePath(sys.frame(1)$ofile)
        }, error = function(e) {
            stop("Unable to determine the script file path. This may happen if you are not using RStudio or sourcing a script.")
        })
    })

    # Return the script path
    script_path
}
