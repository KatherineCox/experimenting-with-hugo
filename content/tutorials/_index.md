---
title: "Tutorials"

# these default fields are required, it does not fail gracefully if they're missing
default_image: "cmoor_logo_notext.png"
default_image_alt_text: "C-MOOR logo"

# make sure this page gets built (override the cascade option below)
_build:
  render: true

# don't make pages for each tutorial
cascade:
  _build:
    render: false
    list: true
---
Here's our stuff.
