#' Get Information about Data
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This function retrieves information about a specific data field from a metadata file.
#' It calculates the Levenshtein distance between the provided variable name and the available data fields
#' to suggest the closest matches.
#'
#' @param variable_name The name of the data field.
#' @param filepath_sample_info The file path to the metadata file.
#' @return A description of the data field and its corresponding unit, if available.
#' @export
#'
#' @examples
#' \dontrun{
#' getDataInfo("DepthSampling")
#' }
#'
#' @import readxl
#' @import dplyr
#' @import janitor
#' @import stringdist
getDataInfo <- function(variable_name, filepath_sample_info = "../03_data/labdata.xlsx") {
    # Load necessary libraries
    if (!requireNamespace("readxl", quietly = TRUE)) {
        install.packages("readxl")
    }
    if (!requireNamespace("janitor", quietly = TRUE)) {
        install.packages("janitor")
    }
    if (!requireNamespace("dplyr", quietly = TRUE)) {
        install.packages("dplyr")
    }
    if (!requireNamespace("stringdist", quietly = TRUE)) {
        install.packages("stringdist")
    }

    require(readxl)
    require(janitor)
    require(dplyr)
    require(stringdist)

    # Function to read and clean data
    read_and_clean_data <- function(filepath, sheet) {
        readxl::read_xlsx(path = filepath, sheet = sheet, skip = 2) %>%
            janitor::clean_names() %>%
            dplyr::distinct() %>%
            dplyr::filter(datatype != "FOREIGN KEY")
    }

    # Function to calculate Levenshtein distance
    calculate_levenshtein_distance <- function(data, variable_name) {
        data %>%
            dplyr::distinct(datafield) %>%
            dplyr::mutate(lsv_dist = stringdist::stringdist(variable_name, datafield, method = "lv"))
    }

    # Function to suggest closest matches
    suggest_closest_matches <- function(testdatafields) {
        suggestions <- testdatafields %>%
            dplyr::arrange(lsv_dist) %>%
            dplyr::slice(1:3) %>%
            dplyr::pull(datafield)

        cat("No exact match found. Did you mean one of these?\n")
        for (i in 1:length(suggestions)) {
            cat(i, ": ", suggestions[i], "\n", sep = "")
        }

        choice <- as.numeric(readline("Enter the number of the correct variable (or 0 to cancel): "))

        if (choice %in% 1:length(suggestions)) {
            return(suggestions[choice])
        } else {
            cat("No valid choice made. Exiting.\n")
            return(NULL)
        }
    }

    # Main function body
    info_samples <- tryCatch({
        read_and_clean_data(filepath_sample_info, "metadata")
    }, error = function(e) {
        cat("Error reading the file: ", e$message, "\n")
        return(NULL)
    })

    if (is.null(info_samples)) return(NULL)

    testdatafields <- calculate_levenshtein_distance(info_samples, variable_name)

    if (min(testdatafields$lsv_dist) == 0) {
        selected_datafield <- testdatafields %>%
            dplyr::filter(lsv_dist == 0) %>%
            dplyr::slice(1) %>%
            dplyr::pull(datafield)
    } else {
        selected_datafield <- suggest_closest_matches(testdatafields)
        if (is.null(selected_datafield)) return(NULL)
    }

    # Output the description and unit in a nice manner
    result <- info_samples %>%
        dplyr::filter(datafield == selected_datafield) %>%
        dplyr::select(description, unit) %>%
        dplyr::slice(1)

    cat("\nData Field Description:\n")
    cat("Description: ", result$description, "\n", sep = "")
    cat("Unit: ", result$unit, "\n", sep = "")
}
