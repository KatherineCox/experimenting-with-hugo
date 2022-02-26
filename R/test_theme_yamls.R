#TODO: optionally log the functions produced by parsers?
# - could be useful for yaml troubleshooting
# Possible tags?
# - !img, !page, !copy (files or directories), !import (other yaml)

# YAML tags essentially tell the parser what to import it as.  So...
# - !img import as a call to make_test_image
# - !copy import as a call to file.copy (probably need to deal with directories
# - !import import as more YAML (merge?)
# - !page - import as call to make_test_page
#
# Do we need an explicit !page tag?
# Do we need an explicit !copy tag, or can we assume copy if not !img?
# What if we want to copy index.md, not just resources?
#
# Would it be better to just handle everything with !expr?
# - I like the conciseness of !img child1 (vs !expr make_test_image(child1)
# - but !expr models that you could use any expression, and is more flexible
# - ...but that also implies promises I'm not making, and raises the question of
# -   when/where the expression is evaluated
#
# How to import an existing index.md instead of making a new one?
# - it's convenient (at least for testing) for the default behavior to be creating a new one.
# - should we overload the !import tag?
# - What if we add a "base" arg to make_test_page?  And then other args override?
# - If we do that, is there any need for an !import tag to import other yamls?
#   - may still be useful for importing list pages and their children

# What if we just enable a "test_mode" which automatically creates pages where needed?
# - default to off so we don't get weird "this is a page" pages in real sites
# - make_test_page() as a wrapper to make_page() with title, etc. filled in from name

# what do we call the "name" argument to make_page?
# "name" is pretty generic and I'm not sure how to use it with call()
# page_name?

# So far we've been thinking top down...time to think about bottom up.
# What does a bottom child look like?
# What does make_page actually accept as arguments for "children"?
# What does the big complex nested call look like?

# What if make_page doesn't worry about children, just makes a single page
# Needs an arg to specify list or single

# Set clean T/F at the top; either nuke the whole thing or don't
# Individual pages shouldn't have to worry about it



empty <- ""

home_only_scalar <- "
home
"

home_page2_sequence <- "
- home
- page2
"

home_only_map <- "
home:
"

home_params <- "
home:
  params:
    param1: a thing
    param2: another thing
"

home_content <- "
home:
  content: 'here is some content'
"

home_content_with_md <- "
home:
  content: 'here is **some content**'
"

home_image <- "
home:
  resources:
    - !img home
"

home_resource <- "
home:
  resources:
    - file1
"

home_resources <- "
home:
  resources:
    - file1
    - file2
"

home_children <- "
home:
  children:
    - page1
    - page2
"

home_all <- "
home:
  params:
    param1: a thing
    param2: another thing
  content: 'here is some content'
  resources:
    - file1
    - file2
    - !img home1
  children:
    - page1
    - page2
"


# These parse functions return a function that, when called, creates the test site
# The function takes a single parameter - the directory to write the content
# By returning a function we can catch most yaml errors during parsing
# rather than getting halfway through creating the test site and then crashing

parse_site_yaml <- function(yaml) {

  y <- yaml::yaml.load(yaml)

  # needs a handler for images, but I haven't written it yet
  # should be something like:
  # y <- yaml::yaml.load(yaml, handlers = list(img = make_test_image_factory(x)))

  # check length and type
  # there should be one top-level page named "content" or "home"
  # but perhaps there can be static, data, etc. that just get copied?
  # if there *are* other things, only pass content to parse_page_yaml()

  construct_page_calls(y)

}

construct_page_calls <- function(yaml_list, output_dir = ".", test_mode=FALSE) {

  # accepts yaml that has already been converted to an R object (usually a list)
  # builds a list of calls to make_page()
  # This lets us catch most yaml errors while building the calls
  # rather than getting halfway through creating the test site and then crashing

  if (is.null(yaml_list)) {
    # this is useful for easily handling null children in recursive calls
    # should this raise a warning if called at top level?
    return(NULL)
  }

  # make an empty list to hold output
  page_calls <- list()

  # if we were only given page names (i.e. no params, children, etc.)
  # this is read in by yaml::yaml.load as a character vector (not list)
  # (it doesn't matter to R if this is of length 1 or more)
  if (typeof(yaml_list) == "character") {
    for (page in yaml_list) {
      # add a new call to the end of the list
      page_calls[[length(page_calls) + 1]] <- call("make_page",
                                                   page_name = page,
                                                   test_mode = test_mode)
    }
  }

  else if (typeof(yaml_list) == "list") {

    for (page in names(yaml_list)) {

      # construct the call for this page
      # for params and resources, if there's no entry in yaml_list they will be null
      call_args <- list(
        make_page,
        page_name = page,
        output_dir = file.path(output_dir, page),
        params = yaml_list[[page]][["params"]],
        resources = yaml_list[[page]][["resources"]]
      )

      # add the call for this page to the end of the list
      page_calls[[length(page_calls) + 1]] <- as.call(call_args)


      # construct the calls for any children and add them on to the end
      # if there are no children, this should leave page_calls unchanged
      # - retrieving a non-existent item (i.e. "children") by name returns NULL
      # - construct_page_calls returns NULL for a NULL yaml_list
      # - add NULL to a list doesn't change the list
        child_calls <- construct_page_calls(yaml_list[[page]][["children"]])
        page_calls <- c(page_calls, child_calls)

    }
  }

  else {
    # wtf is this, return some kind of error
  }

  page_calls
}

make_page <- function(page_name, output_dir=".") {
  print(paste("making", page_name, "page"))
}

#testing <- home_only_scalar
testing <- home_page2_sequence
#testing <- home_only_map


y <- yaml::yaml.load(testing)
t <- parse_site_yaml(testing)
t
eval(t$home)
