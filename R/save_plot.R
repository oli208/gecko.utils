#' Helper function to save ggplot or base R plots
#'
#' This function saves a plot (either ggplot2 or base R) to a file, based on the provided options.
#'
#' @param full_path The full file path where the plot will be saved.
#' @param plot_obj The plot object for ggplot2 (if applicable).
#' @param print_from_device A logical indicating whether to save the plot from the current device (for base R plots).
#' @param filetype The file type to save the plot. For base R plots, use "png" or "pdf". For ggplot2 plots, use any valid file type (e.g., "png", "pdf", "jpeg", "tiff", etc.)
#' @param ... Additional arguments passed to the ggsave function (for ggplot) or png (for base R).
#' @import ggplot2
#' @importFrom grDevices dev.copy dev.off dev.copy2pdf pdf png
#' @return The full path of the saved file.
save_plot <- function(full_path, plot_obj = NULL, print_from_device = FALSE, filetype = "png", ...) {

    # Save ggplot2 plot
    if (!print_from_device) {
        if (is.null(plot_obj)) {
            if (!is.null(ggplot2::last_plot())) {
                plot_obj <- ggplot2::last_plot()
            } else {
                stop("No ggplot object provided and no last ggplot found.")
            }
        }
        # Save the ggplot
        ggplot2::ggsave(filename = full_path, plot = plot_obj, ...)

        # Save base R plot from device
    } else if (print_from_device  & filetype == "png") {
        dev.copy(png, filename = full_path)
        dev.off()

    } else if (print_from_device & filetype == "pdf") {
        dev.copy(pdf, file = full_path)
        dev.off()

    } else { # Unsupported plot type
        stop("Unsupported plot type. Please use ggplot2 or base R plots")
    }

    # Return the file path of the saved plot
    return(full_path)
}
