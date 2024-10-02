#' Custom theme for ggplot2 with font setup and font fallback
#'
#' This function provides a custom ggplot2 theme with options for changing fonts and text sizes.
#' It ensures that extrafont is loaded and the fonts are registered if necessary.
#'
#' @param font_family A string representing the font family to use. Defaults to "Noto Sans".
#'                    Fallbacks to "Arial" or "sans" if not found.
#' @param title_size Font size for the plot title. Defaults to 20.
#' @param subtitle_size Font size for the plot subtitle. Defaults to 14.
#' @param caption_size Font size for the plot caption. Defaults to 9.
#' @param axis_title_size Font size for the axis titles. Defaults to 12.
#' @param axis_text_size Font size for the axis text. Defaults to 11.
#' @return A ggplot2 theme object.
theme_gecko <- function(
        font_family = "Noto Sans",         # Default font family
        title_size = 20,                   # Title font size
        subtitle_size = 14,                # Subtitle font size
        caption_size = 9,                  # Caption font size
        axis_title_size = 12,              # Axis title font size
        axis_text_size = 11                # Axis text font size
) {
    # Ensure the extrafont package is loaded
    if (!requireNamespace("extrafont", quietly = TRUE)) {
        stop("The 'extrafont' package is required but not installed. Please install it.")
    }

    # Check if fonts are loaded
    if (!"Noto Sans" %in% extrafont::fonts()) {
        message("Loading fonts from extrafont...")
        extrafont::loadfonts(device = "win", quiet = TRUE)  # Load fonts
    }

    theme_linedraw() %+replace%    # Replace elements we want to change

        theme(
            # Grid elements
            panel.grid.major = element_blank(),    # Remove major gridlines
            panel.grid.minor = element_blank(),    # Remove minor gridlines

            # Text elements
            plot.title = element_text(
                family = font_family,      # Set font family
                size = title_size,         # Set font size
                face = 'bold',             # Bold typeface
                hjust = 0,                 # Left align
                vjust = 2),                # Raise slightly

            plot.subtitle = element_text(
                family = font_family,      # Font family
                size = subtitle_size),     # Font size

            plot.caption = element_text(
                family = font_family,      # Font family
                size = caption_size,       # Font size
                hjust = 1),                # Right align

            axis.title = element_text(
                family = font_family,      # Font family
                face = 'bold',             # Bold typeface
                size = axis_title_size),   # Font size

            axis.text = element_text(
                family = font_family,      # Font family
                size = axis_text_size)     # Font size
        )
}

