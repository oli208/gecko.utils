#' Add figure information as a caption to a ggplot
#'
#' This function adds metadata to a ggplot as a caption, including the current date,
#' script name, and optionally the R version.
#'
#' @param custom_text Optional. A string of custom text to include at the beginning of the caption.
#' @param include_r_version Optional. A logical indicating whether to include R version information in the caption. Defaults to TRUE.
#' @param datetime_format Optional. A string defining the date and time format for the caption. Defaults to "%d.%m.%Y %X".
#' @return A `figure_info` object that can be added to a ggplot object.
#' @import ggplot2
#' @export
figure_info <- function(custom_text = NULL, include_r_version = TRUE, datetime_format = "%d.%m.%Y %X") {
  # Get the current date and time formatted as per the argument
  current_datetime <- format(Sys.time(), datetime_format)

  # Get the script name using the helper function, fallback if path is unavailable
  script_name <- tryCatch({
    basename(get_script_file_path())
  }, error = function(e) {
    "Unknown script"
  })

  # Get R version info, clean the string to avoid duplication
  r_version_info <- if (include_r_version) {
    r_version <- utils::sessionInfo()$R.version$version.string
    # Remove the redundant "R version" part
    sub("^R version ", "", r_version)
  } else {
    NULL
  }

  # Construct the caption text
  caption_text <- paste0(
    if (!is.null(custom_text)) paste0(custom_text, "\n") else "",
    if (!is.null(r_version_info)) paste0("R Version: ", r_version_info, "\n") else "",
    "Figure created on: ", current_datetime,
    "\nR Script: ", script_name
  )

  # Return a structure for use in ggplot_add
  structure(list(caption_text = caption_text), class = "figure_info")
}

# Define the ggplot_add method for figure_info class
#' @export
ggplot_add.figure_info <- function(object, plot, object_name) {
  # Check if the plot already has a caption
  if (!is.null(plot$labels$caption)) {
    warning("The plot already has a caption. `figure_info()` did not overwrite it.")
  } else {
    # Add the generated caption to the plot
    plot <- plot + labs(caption = object$caption_text)
  }
  plot
}


