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
save_plot <- function(full_path, plot_obj = NULL,
                      print_from_device = FALSE,
                      filetype = "png",
                      width = 8,
                      height = 6,
                      dpi = 300,
                      units = c("in", "cm", "mm", "px"),
                      ...
                      ) {

    if (print_from_device) {
        # Validate that there is an open device to copy from
        if (dev.cur() == 1) stop("No open graphics device to copy from. Create a plot on a device first, or set print_from_device = FALSE and pass a plot object.")
    }

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
        ggplot2::ggsave(filename = full_path, plot = plot_obj, width = width,
                        height = height, units = units, dpi = dpi,...)

        # Save base R plot from device
    } else if (print_from_device  & filetype == "png") {
        dev.copy(
            grDevices::png,
            filename = full_path,
            width    = to_pixels(width, units, dpi),
            height   = to_pixels(height, units, dpi),
            res      = dpi,
            ...
        )
        dev.off()

    } else if (print_from_device & filetype == "pdf") {
        dev.copy(
            grDevices::pdf,
            file = full_path,
            width    = to_inches(width, units, dpi),
            height   = to_inches(height, units, dpi),
            ...
        )
        dev.off()

    } else { # Unsupported plot type
        stop("Unsupported plot type. Please use ggplot2 or base R plots")
    }

    # Return the file path of the saved plot
    return(full_path)
}



# conversion helper: convert width/height to inches when needed (used for pdf and when converting px)
to_inches <- function(value, units, dpi) {
    if (units == "in") return(value)
    if (units == "cm") return(value / 2.54)
    if (units == "mm") return(value / 25.4)
    if (units == "px") return(value / dpi)
    stop("Unknown units in to_inches(): ", units)
}

# Conversion helper: get pixels from width/height when units == "px"
to_pixels <- function(value, units, dpi) {
    if (units == "px") return(round(value))
    # convert to inches first then to px
    inches <- to_inches(value, units, dpi)
    return(round(inches * dpi))
}

