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

# First look for an index.md; use this if available
# - allows people to separate hugo from learnr if desired
# - enables non-Rmd shinyapps
# Next look for an Rmd with runtime (shiny or shiny prerendered?)
# Settings in index.md should override .Rmd, since index.md is specifically for hugo




hugoify <- function(source, hugo_root=".", hugo_section=NULL, hugo_name=NULL) {
  # get source directory path, so we can reference it easily
  source_dir <- dirname(source)

  # build hugo_path, from components if not provided
  # TODO: handle whether or not "content" is included in user input
  hugo_path <- file.path(hugo_root, "content")
  if (!(is.null(hugo_section))) {
    hugo_path <- file.path(hugo_path, hugo_section)
  }

  # get name for directory to create in hugo, if not provided
  if (is.null(hugo_name)) {
    hugo_name <- xfun::sans_ext(basename(source))
  }

  # create output directory
  output_dir <- file.path(hugo_path, hugo_name)
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
  write_md( yaml_list, filename=output_md )
}

# DELETE ME!
# for temporary testing, formalize into proper tests later
source = "test_tutorials/Biological_Databases_FlyBase/Biological_Databases_FlyBase.Rmd"
hugo_section = "tutorials"
hugoify(source = source, hugo_section = hugo_section)

source = "test_tutorials/Biological_Databases_HPA/Biological_Databases_HPA.Rmd"
hugo_section = "tutorials"
hugoify(source = source, hugo_section = hugo_section)

source = "test_tutorials/Biological_Databases_Intro/Biological_Databases_Intro.Rmd"
hugo_section = "tutorials"
hugoify(source = source, hugo_section = hugo_section)
