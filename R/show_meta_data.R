#' @title Show Metadata of Dataframe
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Summarizes metadata for a data frame, including column names, types, and metadata attributes.
#' @param x A data frame or tibble with metadata attributes.
#' @param fields A character vector specifying the metadata fields to include in the summary.
#'               Defaults to all fields starting with "meta".
#' @param show_in_viewer A logical indicating whether to display the metadata in the console (FALSE) or in the interactive viewer (TRUE).
#' @return A tibble summarizing the metadata for each column.
#' @examples
#' # Example using mtcars dataset
#' data(mtcars)
#'
#' # Set metadata
#' meta_data(mtcars) <- list(
#'   mpg = list(Description = "Miles/(US) gallon", meta_Unit = "mpg"),
#'   cyl = list(Description = "Number of cylinders", meta_Unit = "count"),
#'   disp = list(Description = "Displacement (cu.in.)", meta_Unit = "cu.in.")
#' )
#'
#' # Show metadata summary
#' show_meta_data(mtcars)
#' @export
show_meta_data <- function(x, fields = NULL, show_in_viewer = FALSE) {
    stopifnot(is.data.frame(x))

    # If fields are not provided, use all fields starting with "meta"
    if (is.null(fields)) {
        all_attrs <- unique(unlist(lapply(x, function(col) names(attributes(col)))))
        fields <- sub("^meta_", "", grep("^meta_", all_attrs, value = TRUE))
    }

    metadata <- meta_data(x, fields = fields)

    # Build output data frame dynamically based on requested fields
    df_metadata <- data.frame(
        Column = names(x),
        Class = sapply(x, function(col) paste(class(col), collapse = " ")),
        stringsAsFactors = FALSE,
        row.names = NULL
    )

    for (field in fields) {
        df_metadata[[field]] <- sapply(metadata, function(meta) {
            if (!is.null(meta[[field]])) meta[[field]] else NA_character_
        })
    }

    if (show_in_viewer) {
        show_dataframe_in_viewer(df_metadata)
    } else {
        return(df_metadata)
    }
}





#' @title Show Dataframe in Viewer
#' @description Show a data frame in a viewer
#' `r lifecycle::badge("experimental")`
#' @param df A data frame or tibble.
#' @param ... Additional arguments to pass to `reactable::reactable`.
#' @importFrom reactable reactable reactableTheme colDef
#' @importFrom htmltools tagList tags HTML
#'
show_dataframe_in_viewer <- function(df, ...) {
    htmltools::browsable(
        htmltools::tagList(
            tags$style(HTML("
      .modern-button {
        display: inline-block;
        margin: 5px 0; /* Adjust spacing around the button */
        padding: 5px 10px;
        font-size: 0.8rem; /* Adjust font size */
        color: #000;
        background-color: #fff;
        border: none;
        border-radius: 6px;
        cursor: pointer;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
        }

      .modern-button:hover {
        transform: scale(1.02); /* Slight zoom effect on hover */
      }

      .modern-button:active {
        transform: scale(0.98); /* Shrink slightly on click */
      }

      .button-container {
        display: flex;
        justify-content: space-between;
        margin-bottom: 5px;
      }
    ")),
            htmltools::div(
                tags$span(
                    "Metadata viewer",
                    style = "font-size: 1.2rem; font-weight: bold; font-family: system-ui;"
                ),
                class = "button-container",
                tags$button(
                    "Show/hide class column",
                    class = "modern-button",
                    onclick = "Reactable.setHiddenColumns('metadata-vis-class', prevColumns => {
          return prevColumns.length === 0 ? ['Class'] : []
        })"
                )
            ),
            reactable::reactable(
                df,
                defaultPageSize = 20,
                searchable = TRUE, # Add a search box
                resizable = TRUE, # Allow column resizing
                # compact = TRUE,       # Use compact mode
                highlight = TRUE,
                bordered = FALSE, # Remove borders for a cleaner look
                theme = reactableTheme(
                    color = "#000", # Text color
                    backgroundColor = "#fff", # Background color
                    borderColor = "#ddd", # Subtle border color
                    style = list(
                        fontFamily = "-apple-system, BlinkMacSystemFont, Noto Sans, Segoe UI,
                     Helvetica, Arial, sans-serif",
                        fontSize = "0.80rem"
                    ),
                    searchInputStyle = list(width = "100%"),
                    headerStyle = list(
                        backgroundColor = "#f7f7f7", # Light gray header
                        color = "#000", # Black header text
                        fontWeight = "bold"
                    )
                ),
                columns = list(
                    Column = colDef(
                        style = list(
                            fontWeight = "bold", borderRight = "1px solid #eee",
                            backgroundColor = "#f7f7f7"
                        ),
                        sticky = "left",
                        # Add a right border style to visually distinguish the sticky column
                        headerStyle = list(
                            borderRight = "1px solid #eee",
                            backgroundColor = "#f7f7f7"
                        )
                    ),
                    Class = colDef(show = FALSE),
                    Description = colDef(minWidth = 250) # 25% width, 100px minimum
                ),
                elementId = "metadata-vis-class",
                ...
            )
        )
    )
}
