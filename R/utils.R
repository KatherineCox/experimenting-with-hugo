write_md <- function( yaml=NULL, content=NULL, filename ) {

  # convert R list to yaml string and add the yaml delimiters
  yaml_string <- yaml::as.yaml(yaml)
  writeLines(c("---", yaml_string, "---\n", content), con = filename)
}
