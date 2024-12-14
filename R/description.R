#' @title Get or set metadata for data frame columns
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Retrieve or set metadata (e.g., descriptions, units, symbols) for data frame columns dynamically.
#' @param x A data frame or tibble.
#' @param fields A character vector of metadata fields to retrieve. Defaults to `c("Description", "Unit", "Symbol")`.
#' @return A named list of metadata for each column, with missing fields filled as `NA`.
#' @examples
#' # Example using mtcars dataset
#' data(mtcars)
#'
#' # Set metadata using list
#' meta_data(mtcars) <- list(
#'   mpg = list(Description = "Miles/(US) gallon", Unit = "mpg"),
#'   cyl = list(Description = "Number of cylinders", Unit = "count"),
#'   disp = list(Description = "Displacement (cu.in.)", Unit = "cu.in.")
#' )
#'
#' # Set metadata using data frame
#' meta_data(mtcars) <- data.frame(Datafield = c("mpg", "cyl", "disp"),
#'                                Description = c("Miles/(US) gallon", "Number of cylinders", "Displacement (cu.in.)"),
#'                                Unit = c("mpg", "count", "cu.in."))
#'
#'
#' # Get metadata
#' descriptions(mtcars)
#' @export
meta_data <- function(x, fields = c("Description", "Unit", "Symbol")) {
  stopifnot(is.data.frame(x))

  # For each column, extract metadata attributes
  lapply(names(x), function(col) {
    attributes <- attributes(x[[col]])

    # Extract metadata fields prefixed with "meta_"
    meta_data <- grep("^meta_", names(attributes), value = TRUE)
    meta_list <- setNames(lapply(fields, function(field) {
      meta_key <- paste0("meta_", field)
      if (meta_key %in% meta_data) {
        attributes[[meta_key]]
      } else {
        NA_character_
      }
    }), fields)

    return(meta_list)
  }) %>% setNames(names(x))
}

#' @export
`meta_data<-` <- function(x, value) {
  stopifnot(is.data.frame(x))

  # If `value` is a data.frame, attempt to parse it using `parse_metadata`
  if (is.data.frame(value)) {
    required_cols <- c("Datafield", "Description")  # Default required columns
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

  invisible(x)  # Avoid unnecessary output
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
#' parse_metadata(metadata, key_col = "Datafield", desc_col = "Description")
parse_metadata <- function(metadata, key_col, desc_col, fields = c("Unit", "Symbol")) {
  stopifnot(is.data.frame(metadata), key_col %in% names(metadata), desc_col %in% names(metadata))

  # Ensure fields include "Description"
  fields <- unique(c("Description", fields))

  # Validate that all fields exist in the metadata
  stopifnot(all(fields %in% names(metadata)))

  # Parse metadata into a structured list
  lapply(seq_len(nrow(metadata)), function(i) {
    entry <- metadata[i, ]
    setNames(lapply(fields, function(field) {
      if (!is.null(entry[[field]])) {
        entry[[field]]
      } else {
        NA_character_
      }
    }), fields)
  }) %>% setNames(metadata[[key_col]])
}


#' @title Show Metadata of Dataframe
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Summarizes metadata for a data frame, including column names, types, and metadata attributes.
#' @param x A data frame or tibble with metadata attributes.
#' @param fields A character vector specifying the metadata fields to include in the summary.
#'               Defaults to all fields starting with "meta".
#' @return A tibble summarizing the metadata for each column.
#' @examples
#' # Example using mtcars dataset
#' data(mtcars)
#'
#' # Set metadata
#' show_meta_data(mtcars) <- list(
#'   mpg = list(Description = "Miles/(US) gallon", meta_Unit = "mpg"),
#'   cyl = list(Description = "Number of cylinders", meta_Unit = "count"),
#'   disp = list(Description = "Displacement (cu.in.)", meta_Unit = "cu.in.")
#' )
#'
#' # Show metadata summary
#' show_meta_data(mtcars)
#' @export
show_meta_data <- function(x, fields = NULL) {
  stopifnot(is.data.frame(x))

  # If fields are not provided, use all fields starting with "meta"
  if (is.null(fields)) {
    all_attrs <- unique(unlist(lapply(x, function(col) names(attributes(col)))))
    fields <- sub("^meta_", "", grep("^meta_", all_attrs, value = TRUE))
  }

  metadata <- meta_data(x, fields = fields)

  # Build output tibble dynamically based on requested fields
  tibble::tibble(
    Column = names(x),
    Class = sapply(x, function(col) paste(class(col), collapse = " ")),
    !!!lapply(fields, function(field) {
      sapply(metadata, function(meta) if (!is.null(meta[[field]])) meta[[field]] else NA_character_)
    }) %>% setNames(fields)
  )
}

