#' @title Retrieve or Set Metadata for Data Frame Columns
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' The `meta_data()` function retrieves metadata attributes (such as descriptions, units, and symbols)
#' assigned to individual columns of a data frame.
#' The assignment function `meta_data<-()` allows setting metadata dynamically for columns.
#'
#' Metadata is stored as column attributes prefixed with `"meta_"`, e.g., `"meta_Description"`,
#' `"meta_Unit"`, `"meta_Symbol"`. This allows structured metadata management for data documentation.
#'
#' @param x A data frame or tibble.
#' @param fields A character vector of metadata fields to retrieve.
#'   Defaults to `c("Description", "Unit", "Symbol")`.
#'
#' @return A named list where each entry corresponds to a column in `x`,
#'   containing a list of metadata fields (filled with `NA` if missing).
#'
#' @examples
#' # Example using the mtcars dataset
#' data(mtcars)
#'
#' # Set metadata for columns
#' meta_data(mtcars) <- list(
#'   mpg = list(Description = "Miles per US gallon", Unit = "mpg"),
#'   cyl = list(Description = "Number of cylinders", Unit = "count"),
#'   disp = list(Description = "Engine displacement in cubic inches", Unit = "cu.in.")
#' )
#'
#' # Retrieve metadata
#' show_meta_data(mtcars)
#'
#' @importFrom stats setNames
#' @export
meta_data <- function(x, fields = c("Description", "Unit", "Symbol")) {
  stopifnot(is.data.frame(x))

  # Initialize an empty list to store results
  result <- list()

  # Iterate over each column in the dataframe
  for (col in names(x)) {
    attributes_list <- attributes(x[[col]])

    # Extract metadata fields prefixed with "meta_"
    meta_data_keys <- grep("^meta_", names(attributes_list), value = TRUE)

    meta_list <- setNames(lapply(fields, function(field) {
      meta_key <- paste0("meta_", field)
      if (meta_key %in% meta_data_keys) {
        attributes_list[[meta_key]]
      } else {
        NA_character_
      }
    }), fields)

    # Store result in the list
    result[[col]] <- meta_list
  }

  return(result)
}







#' @title Assign Metadata to Data Frame Columns
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' The assignment function `meta_data<-()` sets metadata attributes for data frame columns.
#' Metadata can be provided as a **named list** or a **data frame**.
#'
#' - If a **named list** is provided, each element corresponds to a column name,
#'   with a sublist containing metadata fields.
#' - If a **data frame** is provided, it must contain a `"Datafield"` column
#'   (defining the target column names) and a `"Description"` column.
#'   Additional columns are treated as metadata fields.
#'
#' Metadata is stored as attributes prefixed with `"meta_"`, e.g., `"meta_Description"`,
#' `"meta_Unit"`, `"meta_Symbol"`.
#'
#' @param x A data frame or tibble.
#' @param value A **named list** (where each element corresponds to a column and contains a list of metadata)
#'   or a **data frame** (with at least `"Datafield"` and `"Description"` columns).
#'
#' @return The modified data frame `x` with metadata attributes assigned to columns.
#'   The function returns `x` invisibly to avoid unnecessary printing.
#'
#' @examples
#' # Example using the mtcars dataset
#' data(mtcars)
#'
#' # Assign metadata using a named list
#' meta_data(mtcars) <- list(
#'   mpg = list(Description = "Miles per US gallon", Unit = "mpg"),
#'   cyl = list(Description = "Number of cylinders", Unit = "count"),
#'   disp = list(Description = "Engine displacement in cubic inches", Unit = "cu.in.")
#' )
#'
#' # Assign metadata using a data frame
#' meta_data(mtcars) <- data.frame(
#'   Datafield = c("mpg", "cyl", "disp"),
#'   Description = c(
#'     "Miles per US gallon",
#'     "Number of cylinders",
#'     "Engine displacement in cubic inches"
#'     ),
#'   Unit = c("mpg", "count", "cu.in.")
#' )
#'
#' # Retrieve metadata
#' show_meta_data(mtcars)
#'
#' @export
`meta_data<-` <- function(x, value) {
  stopifnot(is.data.frame(x))

  # If `value` is a data.frame, attempt to parse it using `parse_metadata`
  if (is.data.frame(value)) {
    required_cols <- c("Datafield", "Description") # Default required columns
    stopifnot(all(required_cols %in% names(value)))

    value <- parse_metadata(
      metadata = value,
      key_col = "Datafield",
      desc_col = "Description",
      fields = setdiff(names(value), c("Datafield", "Description"))
    )
  }

  stopifnot(is.list(value))

  # Set metadata for columns in the data frame
  for (col in names(value)) {
    if (!col %in% names(x)) {
      warning(sprintf("Column '%s' not found in the data frame. Skipping.", col))
      next
    }

    col_meta <- value[[col]]
    stopifnot(is.list(col_meta), !is.null(col_meta$Description))

    # Assign metadata attributes dynamically
    for (field in names(col_meta)) {
      attr(x[[col]], paste0("meta_", field)) <- col_meta[[field]]
    }
  }

  invisible(x) # Avoid unnecessary output
}


#' @title Parse Metadata Table
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Convert a metadata table into a list for easy assignment.
#' @param metadata A data frame containing metadata.
#' @param key_col Column specifying data field names.
#' @param desc_col Column specifying descriptions.
#' @param fields A character vector specifying metadata fields to include (e.g., c("Description", "Unit", "Symbol")).
#' @return A named list where each entry is metadata for a column.
#' @examples
#' # Example metadata data frame
#' metadata <- data.frame(
#'   Datafield = c("mpg", "cyl", "disp"),
#'   Description = c("Miles/(US) gallon", "Number of cylinders", "Displacement (cu.in.)"),
#'   Unit = c("mpg", "count", "cu.in.")
#' )
#'
#' # Parse metadata
#' parse_metadata(metadata, key_col = "Datafield", desc_col = "Description", fields = "Unit")
#' @export
parse_metadata <- function(metadata, key_col, desc_col, fields = c("Unit", "Symbol")) {
  stopifnot(is.data.frame(metadata), key_col %in% names(metadata), desc_col %in% names(metadata))

  # Ensure fields include "Description"
  fields <- unique(c("Description", fields))

  # Validate that all fields exist in the metadata
  stopifnot(all(fields %in% names(metadata)))

  # Parse metadata into a structured list
  result <- lapply(seq_len(nrow(metadata)), function(i) {
    entry <- metadata[i, ]
    setNames(lapply(fields, function(field) {
      if (!is.null(entry[[field]])) {
        entry[[field]]
      } else {
        NA_character_
      }
    }), fields)
  })

  # Set names of the list to match key_col values
  names(result) <- metadata[[key_col]]

  return(result)
}

