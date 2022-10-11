---
title: Spatial Production Allocation Model for Country studies (mapspamc) 
summary: Development of an R package to create crop distribution maps for country studies using the SPAM approach.
tags: ["current research", "mapspamc"]
date: "2022-10-11"

# Optional external URL for project (replaces project detail page).
external_link: ""

# Placement options: 1 = Full column width, 2 = Out-set, 3 = Screen-width
# Focal point options: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight
image:
  preview_only: false
  placement: ""
  focal_point: ""
  caption: "Crop distribution maps for Malawi at 5 arc minutes and 30 arc seconds."
  
url_code: ""
url_pdf: ""
url_slides: ""
url_video: ""

# Slides (optional).
#   Associate this project with Markdown slides.
#   Simply enter your slide deck's filename without extension.
#   E.g. `slides = "example-slides"` references `content/slides/example-slides.md`.
#   Otherwise, set `slides = ""`.
slides: ""
---

Spatial information on the location of crops is key to inform agriculture and food policies and are an important input for global and national land use change and agricultural market models. The global crop distribution maps produced with the Spatial Production Allocation Model (SPAM, www.mapspam.info) are an important source for this type of information and are widely used by researchers, policy makers and business. SPAM uses a downscaling approach to allocate national and subnational crop statistics to a 5 arc minute grid, informed and constrained by spatial information on biophysical and socio-economic drivers of crop location. This project introduces the [mapspamc](https://michielvandijk.github.io/mapspamc/) package, coded in R and GAMS that allows users to create crop distribution maps for single countries using the SPAM crop cross-entropy crop allocation algorithm as well as an alternative approach to create crop distribution maps at a resolution of 30 arc seconds. It presents a six-step approach to produce the crop distribution maps, including: (1) model setup, (2) pre-processing, (3) model preparation, (4) running the model, (5) post-processing and (6) model validation. A detailed example for Malawi is presented to illustrate how the package can used and what type of outcomes can be produced.
