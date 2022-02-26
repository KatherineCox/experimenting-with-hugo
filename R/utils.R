write_md <- function( yaml=NULL, content=NULL, filename ) {

  # convert R list to yaml string and add the yaml delimiters
  yaml_string <- yaml::as.yaml(yaml)
  writeLines(c("---", yaml_string, "---\n", content), con = filename)
}

read_md <- function(file) {
  s <- readLines(file)
  yaml_delim <- grep("---", s)

  # we expect there to be two yaml delimiters
  if ( !(length(yaml_delim) == 2) ) {
    # this is a problem, return an error
  } else {
    yaml_start <- yaml_delim[1]
    yaml_end <- yaml_delim[2]

    # get the yaml (between the yaml delimiters)
    # include the delimiters, although I don't think it's required for yaml.load
    yaml_string <- s[yaml_start:yaml_end]
    yaml_string <- paste(yaml_string, collapse="\n")

    # get the content - should be everything after the second delim
    content <- s[-(1:yaml_end)]
    content <- paste(content, collapse="\n")
  }

  list(
    yaml = yaml_string,
    content = content
  )

}
