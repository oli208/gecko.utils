test_that("meta_data and meta_data<- functions work as expected", {
    data(mtcars)

    # Test setting metadata using a list
    metadata_list <- list(
        mpg = list(Description = "Miles/(US) gallon", Unit = "mpg"),
        cyl = list(Description = "Number of cylinders", Unit = "count"),
        disp = list(Description = "Displacement (cu.in.)", Unit = "cu.in.")
    )
    meta_data(mtcars) <- metadata_list

    # Verify metadata was set correctly
    expect_equal(attr(mtcars$mpg, "meta_Description"), "Miles/(US) gallon")
    expect_equal(attr(mtcars$cyl, "meta_Unit"), "count")
    expect_equal(attr(mtcars$disp, "meta_Unit"), "cu.in.")
    expect_equal(attr(mtcars$disp, "meta_Symbol"), NULL) # Symbol not set

    # Test retrieving metadata
    metadata <- meta_data(mtcars)
    expect_equal(metadata$mpg$Description, "Miles/(US) gallon")
    expect_equal(metadata$cyl$Unit, "count")
    expect_equal(metadata$disp$Unit, "cu.in.")
})

test_that("meta_data<- works with data frame input", {
    data(mtcars)

    # Test setting metadata using a data frame
    metadata_df <- data.frame(
        Datafield = c("mpg", "cyl", "disp"),
        Description = c("Miles/(US) gallon", "Number of cylinders", "Displacement (cu.in.)"),
        Unit = c("mpg", "count", "cu.in.")
    )
    meta_data(mtcars) <- metadata_df

    # Verify metadata was set correctly
    expect_equal(attr(mtcars$mpg, "meta_Description"), "Miles/(US) gallon")
    expect_equal(attr(mtcars$cyl, "meta_Unit"), "count")
    expect_equal(attr(mtcars$disp, "meta_Unit"), "cu.in.")
})

test_that("parse_metadata correctly parses a metadata table", {
    metadata_df <- data.frame(
        Datafield = c("mpg", "cyl", "disp"),
        Description = c("Miles/(US) gallon", "Number of cylinders", "Displacement (cu.in.)"),
        Unit = c("mpg", "count", "cu.in."),
        Symbol = c("m", "n", NA)
    )

    parsed_metadata <- parse_metadata(
        metadata = metadata_df,
        key_col = "Datafield",
        desc_col = "Description",
        fields = c("Unit", "Symbol")
    )

    # Verify parsed output
    expect_equal(parsed_metadata$mpg$Description, "Miles/(US) gallon")
    expect_equal(parsed_metadata$cyl$Unit, "count")
    expect_equal(parsed_metadata$disp$Symbol, NA_character_)
})

test_that("show_meta_data generates a correct summary", {
    data(mtcars)

    # Set metadata
    metadata_list <- list(
        mpg = list(Description = "Miles/(US) gallon", Unit = "mpg"),
        cyl = list(Description = "Number of cylinders", Unit = "count"),
        disp = list(Description = "Displacement (cu.in.)", Unit = "cu.in.")
    )
    meta_data(mtcars) <- metadata_list

    # Generate metadata summary
    summary <- show_meta_data(mtcars)

    # Verify output
    expect_s3_class(summary, "data.frame")
    expect_equal(summary$Column, names(mtcars))
    expect_equal(unname(summary$Description[1]), "Miles/(US) gallon")
    expect_equal(unname(summary$Unit[2]), "count")
})

test_that("meta_data handles missing metadata gracefully", {
    data(mtcars)

    # Test retrieving metadata when none is set
    metadata <- meta_data(mtcars)
    expect_true(all(sapply(metadata, function(meta) all(is.na(meta)))))

    # Test show_meta_data when no metadata is set
    summary <- show_meta_data(mtcars) # Or show_meta_data if renamed

    # Ensure output includes the correct structure
    expect_true("Column" %in% names(summary))
    expect_true("Class" %in% names(summary))

    # If metadata fields are missing, they should not cause warnings or errors
    if ("Description" %in% names(summary)) {
        expect_true(all(is.na(summary$Description)))
    } else {
        expect_true(TRUE) # No Description field means no metadata was set
    }

    if ("Unit" %in% names(summary)) {
        expect_true(all(is.na(summary$Unit)))
    } else {
        expect_true(TRUE)
    }

    if ("Symbol" %in% names(summary)) {
        expect_true(all(is.na(summary$Symbol)))
    } else {
        expect_true(TRUE)
    }
})


test_that("meta_data<- warns about missing columns", {
    data(mtcars)

    # Test setting metadata for a non-existent column
    metadata_list <- list(
        mpg = list(Description = "Miles/(US) gallon"),
        non_existent = list(Description = "This column does not exist")
    )

    expect_warning(meta_data(mtcars) <- metadata_list, "Column 'non_existent' not found in the data frame")
})



