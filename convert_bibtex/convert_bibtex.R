# ========================================================================================
# Project:  michielvandijk.org
# Subject:  Script update website publications using .bib file from Mendeley
# Author:   Michiel van Dijk
# Contact:  michiel.vandijk@wur.nl
# ========================================================================================

# ========================================================================================
# SETUP ----------------------------------------------------------------------------------
# ========================================================================================

# Load pacman for p_load
if(!require(pacman)) install.packages("pacman")
library(pacman)

# Load key packages
p_load(here)

# R options
options(scipen = 999)
options(digits = 4)

# ========================================================================================
# TO ADD ---------------------------------------------------------------------------------
# ========================================================================================

# Fix special symbols in Mendeley/LATEX
# write function to add figure


# ========================================================================================
# PROCESS FILES --------------------------------------------------------------------------
# ========================================================================================
# Source function
source(here("convert_bibtex/bibtex_2_hugo.R"))

# Set input and output file
bibfile <- "C:/data/mendeley/my_pubs-website.bib"
outfold   <- here("content/publication/")

# process
bibtex2academic(bibfile  = bibfile, outfold   = outfold)


