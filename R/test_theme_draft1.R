# TODO: add page kind (home, list, single) as a param, and update how index.md is named
# TODO: option for single pages without their own directories?
# TODO: make yaml parsing less fragile / more informative errors? bleh
# TODO: should output_dir be "." or "./name"?
# - Default to "." unless there's resources or children?
# - But then we'd probably want to name the file name.md instead of index.md
# - Should we default to enforcing page bundles?


make_test_page <- function( name, output_dir=file.path(".", name),
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

    if (typeof(r) == "function") {
      #do.call
    } else {
    file.copy(r, output_dir)
    }
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

make_image <- function(text, text_size=30, background="lightblue",
                        device="png", filename=paste(text, device, sep="."), ...) {
  p<- ggplot2::ggplot() +
      ggplot2::annotate(geom = "text", x=1, y=1, label = text, text_size = size) +
      ggplot2::theme_void() +
      ggplot2::theme(plot.background = ggplot2::element_rect(fill = background))

  ggplot2::ggsave(filename, device=device, ...)
}

# a wrapper for make image that can be called by providing the output directory
# used to capture a make_image call before we've figured out the directory structure
# useful when parsing yaml to build test sites
# args are specified in make_image() since that's exported
# this just passes everything along to make_image()
make_image_factory <- function(...) {
  function(output_dir =".") {
    make_image(path = output_dir, ...)
  }
}

test_yaml <- "my_exp: !expr paste('orange')"
y <- yaml::yaml.load(test_yaml, handlers = list(expr = function(x) parse(text = x)))
eval(y$my_exp)

test_yaml <- "my_exp: !expr return_image('hihi')"
y <- yaml::yaml.load(test_yaml, eval.expr=TRUE)

