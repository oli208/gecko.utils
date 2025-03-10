% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ggsave_custom.r
\name{ggsave_custom}
\alias{ggsave_custom}
\title{Save plot with custom filename for multiple plot types}
\usage{
ggsave_custom(
  name,
  plot_obj = NULL,
  filepath = getOption("figure_save_path", "./"),
  dateformat = "\%y\%m\%d",
  print_from_device = FALSE,
  ...
)
}
\arguments{
\item{name}{A string representing the name of the plot (to be included in the filename).}

\item{plot_obj}{The ggplot object to be saved.
If not provided, it will use the last ggplot created (\code{ggplot2::last_plot()}).}

\item{filepath}{The directory where the file will be saved. Defaults to current working directory . You can use set_ggsave_path() to change the default path for your total R-project.}

\item{dateformat}{The date format to be used in the filename. Defaults to "\%y\%m\%d".}

\item{print_from_device}{A logical value indicating whether to print the plot from the device (base R plot) or from ggplot2. Defaults to FALSE.}

\item{...}{Additional arguments passed to \verb{ggplot2::ggsave()`` or }png()` (e.g., width, height, etc.).}
}
\value{
Saves a file and returns the full path of the saved file.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#superseded}{\figure{lifecycle-superseded.svg}{options: alt='[Superseded]'}}}{\strong{[Superseded]}}

The functionality of this function has been superseded by the \code{save_plot_with_metadata()} function.

This function saves a plots with a custom filename that includes
the script name, plot name and the current date. It uses a flexible naming convention
to ensure better traceability of figures.
If no plot is provided, it will save the last ggplot created or the active plot on the graphics device.
}
\details{
An error if the file path does not exist and cannot be created.
}
