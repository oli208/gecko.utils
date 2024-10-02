

ggsavecustom <- function(name, filepath = "../06_graphics/", ...) {
    # Get the current script file path
    
    this_file <- tryCatch({
        rstudioapi::getActiveDocumentContext()$path
    }, error = function(e) {
        tryCatch({
            normalizePath(sys.frame(1)$ofile)
        }, error = function(e) {
            stop("Cannot determine the script file path.")
        })
    })
    
    
    # Extract the script filename without extension
    script_filename <- tools::file_path_sans_ext(basename(this_file))
    
    
    # Full path for the output file
    fullpath <- paste0(filepath, script_filename, "_", Sys.Date(), "_", name, ".png")
    
    
    # Save the current ggplot with specified width, height, and units
    ggsave(fullpath, units = "cm", ...)
}
