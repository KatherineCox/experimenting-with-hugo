# TODO: add page kind (home, list, single) as a param, and update how index.md is named
# TODO: option for single pages without their own directories?
# TODO: make yaml parsing less fragile / more informative errors? bleh

make_test_page <- function( name, output_dir=".",
                            params=list(title=name),
                            content=paste("This is the", name, "page."),
                            resources=NULL, children=NULL) {

  # create the output directory if needed
  if (!dir.exists(output_dir)) {
    dir.create(output_dir)
  }

  # write the index file
  if (is.null(children)) {
    index_name <- "index.md"
  } else {
    index_name <- "_index.md"
  }
  write_md(params, content, file.path(output_dir, index_name))

  # copy over page resources
  for (r in resources) {
    file.copy(r, output_dir)
  }

  # make child pages
  for (child in names(children)) {
    # append the name and output directory to the args list, then make the page
    args <- c( list(name=child, output_dir=file.path(output_dir, child)),
               children[[child]])
    do.call(make_test_page, args)
  }

}

make_test_content <- function( config, output_dir = "./content", overwrite=FALSE) {

  # create directory
  # make sure we don't unintentionally overwrite existing content
  # if we do want to overwrite, delete the old content so we start fresh
  if (dir.exists(output_dir)) {
    if (!overwrite) {
      stop("Directory '", output_dir, "' already exists.
           Set 'overwrite=TRUE' if you wish to overwrite the existing directory.
           This will delete all existing files in the directory.")
    } else {
      unlink(output_dir, recursive = TRUE)
    }
  }
  dir.create(output_dir)

  y <- yaml::yaml.load(config, eval.expr = TRUE)

  for (page in names(y)) {
    # append the name and output directory to the args list, then make the page
    args <- c( list(name=page, output_dir=file.path(output_dir, page)),
               y[[page]])
    do.call(make_test_page, args)
  }

}

make_test_page("test")

test_yaml <-"
list1:
  children:
    child1:
    child2:
list2:
  children:
    child3:
    child4:
      params:
        subtitle: child4 subtitle
"

make_test_content(test_yaml, output_dir="test_output", overwrite = TRUE)
