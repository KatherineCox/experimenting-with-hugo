# list_files_with_exts() may be useful
# xfun::dir_create is a wrapper for dir.create() that first checks if it exists
# - not sure if this is needed?  sticking with dir.create() for now
# - may be useful for section directories
# - lean towards nuking everything and starting clean, so, no worries
# - but may want it to catch errors with conflicting names


# for now, assume source is a learnr .Rmd file.
# - think about other directory structures later
#
# args hugo_root, hugo_section
# e.g. hugo_root = <repo>, hugo_section = "tutorials"
# becomes <repo>/content/tutorials
# be flexible about where "content" goes or whether it's required



hugoify <- function(source, hugo_section, hugo_root=".", hugo_name=NULL) {
  # get source directory path, so we can reference it easily
  source_dir <- dirname(source)

  # get name for directory to create in hugo, if not provided
  if (is.null(hugo_name)) {
    hugo_name <- xfun::sans_ext(basename(source))
  }

  # create output directory
  output_dir <- file.path(hugo_root, "content", hugo_section, hugo_name)
  dir.create(output_dir)

  # read in the rmd yaml as an R list
  yaml_list <- rmarkdown::yaml_front_matter(source)

  # create (empty) index.md file
  output_md <- file.path(output_dir, "index.md")
  file.create(output_md)

  # copy image and update yaml to point to new image location
  image_filepath <- file.path(source_dir, yaml_list$image)
  image_filename <- basename(yaml_list$image)
  file.copy(image_filepath, output_dir)
  yaml_list$image <- image_filename

  # write index.md file
  # - convert R list to yaml string
  # - add the yaml delimiters
  yaml_string <- yaml::as.yaml(yaml_list)
  cat("---\n", yaml_string, "---\n", file=output_md, sep="")
}

# DELETE ME!
# for temporary testing, formalize into proper tests later
source = "test_tutorials/Biological_Databases_FlyBase/Biological_Databases_Flybase.Rmd"
hugo_section = "tutorials"
hugoify(source = source, hugo_section = hugo_section)

source = "test_tutorials/Biological_Databases_HPA/Biological_Databases_HPA.Rmd"
hugo_section = "tutorials"
hugoify(source = source, hugo_section = hugo_section)
