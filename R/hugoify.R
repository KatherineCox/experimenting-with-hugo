tutorial = "test_tutorials/Biological_Databases_FlyBase/Biological_Databases_Flybase.Rmd"
destination = file.path("content", "tutorials")

# assume we've been handed an Rmd file that is a learnr tutorial
# list_files_with_exts() may be useful
# xfun::dir_create is a wrapper for dir.create() that first checks if it exists
# - not sure if this is needed?  sticking with dir.create() for now
# - may be useful for section directories



# read in the rmd yaml as an R list
yaml_list <- rmarkdown::yaml_front_matter(tutorial)

# get name to use as destination directory and create directory
source_dir <- dirname(tutorial)
source_filename <- xfun::sans_ext(basename(tutorial))

# create destination directory
destination_dir <- file.path(destination, source_filename)
dir.create(destination_dir)

# copy image and update yaml to point to new image location
image_filepath <- file.path(source_dir, yaml_list$image)
image_filename <- basename(yaml_list$image)
file.copy(image_filepath, destination_dir)
yaml_list$image <- image_filename

# create (empty) index.md file
destination_md <- file.path(destination_dir, "index.md")
file.create(destination_md)

# write index.md file
# - convert R list to yaml string
# - add the yaml delimiters
yaml_string <- yaml::as.yaml(yaml_list)
cat("---\n", yaml_string, "---\n", file=destination_md, sep="")


