make_page <- function( name, output_dir=file.path(".", name), test_mode = FALSE,
                       kind = c("home", "section", "page"),
                       md_template = NULL,
                       params=NULL, content=NULL, resources=NULL) {

  # create the output directory if needed
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # set values for making a test page
  # TODO: allow overrides?
  if (test_mode) {
    params = list(title = name)
    content=paste("This is the", name, "page.")
  }

  # write the index file
  kind <- match.arg(kind)
  if (kind == "page") {
    index_name <- "index.md"
  } else {
    index_name <- "_index.md"
  }
  write_md(params, content, file.path(output_dir, index_name))

  # copy over page resources
  for (r in resources) {

    if (typeof(r) == "function") {
      #do.call
    } else {
      file.copy(r, output_dir, recursive = TRUE)
    }
  }
# TODO: what should this return?
}
