#'========================================================================================================================================
#' Project:  bibtex_2_hugo
#' Subject:  Function to convert bibtex into md per article for blowdown
#' Author:   Michiel van Dijk
#' Note:     Based on https://raw.githubusercontent.com/lbusett/spartially/master/accessories/bibtex_2_hugo.R
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================================================================

# To force latex parsing of special characters in bibtex this might help:
# https://sourcethemes.com/academic/docs/writing-markdown-latex/
# See page elements section on how to escape slash, etc

# Check this for changing image size
# https://github.com/gcushen/hugo-academic/issues/84

# Replace Michiel van dijk with _mvd_ so it becomes bold and will be replaced by a hyperlink to the main page
# Compare png name with folder name and if there is a match copy it to folder and rename to featured.png
# Also set placement and focul point at the same time.
# Placement and focul point need a tab.
# Add csv file with additional information, such as website links (project, data, etc), that can be automatically added
# When the publication files are rebuild.

#' @title bibtex_2_academic
#' @description import publications from a bibtex file to a hugo-academic website
#' @author Lorenzo Busetto and Michiel van Dijk 

bibtex2academic <- function(bibfile,
                             outfold) {
  
  library(bib2df)
  library(dplyr)
  library(stringr)
  library(anytime)
  library(tidyr)
  library(purrr)
  
  # stop blogdown serve_site as to speed up
  blogdown::stop_server()
  
  # Import the bibtex file as tibble, use separate names to extract full names
  options(encoding="UTF-8")
  mypubs   <- bib2df(bibfile, separate_names = TRUE) 
  
  # Assign "categories" to the different types of publications
  # Legend: 0 = Uncategorized; 1 = Conference paper; 2 = Journal article;
  # 3 = Preprint / Working Paper; 4 = Report; 5 = Book; 6 = Book section;
  # 7 = Thesis; 8 = Patent
  mypubs <- mypubs %>%
    dplyr::mutate(
      PUBTYPE = dplyr::case_when(CATEGORY == "ARTICLE" ~ "2",
                                 CATEGORY == "ARTICLE IN PRESS" ~ "2",
                                 CATEGORY == "INPROCEEDINGS" ~ "1",
                                 CATEGORY == "PROCEEDINGS" ~ "1",
                                 CATEGORY == "CONFERENCE" ~ "1",
                                 CATEGORY == "CONFERENCE PAPER" ~ "1",
                                 CATEGORY == "MASTERTHESIS" ~ "7",
                                 CATEGORY == "PHDTHESIS" ~ "7",
                                 CATEGORY == "MANUAL" ~ "4",
                                 CATEGORY == "TECHREPORT" ~ "4",
                                 CATEGORY == "BOOK" ~ "5",
                                 CATEGORY == "INCOLLECTION" ~ "6",
                                 CATEGORY == "INBOOK" ~ "6",
                                 CATEGORY == "MISC" ~ "0",
                                 CATEGORY == "UNPUBLISHED" ~ "3",
                                 CATEGORY == "PATENT" ~ "8",
                                 TRUE ~ "0")) %>%
    arrange(desc(YEAR), TITLE)
  
  # create a function which populates the md template based on the info
  # about a publication and creates a new folder for each publication
  create_pub <- function(x) {
    
    # strings to remove (rm) and to keep (kp)
    rm1 <- "[{}]"
    rm2 <- "^(?i)abstract"
    kp <- "[^[:alnum:][:blank:]+,?&/\\-.():!]"

    # https://stackoverflow.com/questions/62391363/reading-latex-accents-of-bib-in-r
    
    # Modify variables, collapse full author names and remove strings
    df <- mypubs[x,] %>%
      dplyr::mutate(YEAR = ifelse(is.na(YEAR), 9999, YEAR),
             ABSTRACT = str_remove_all(ABSTRACT, kp),
             ABSTRACT = str_remove_all(ABSTRACT, rm2),
             ABSTRACT = ifelse(is.na(ABSTRACT), "", ABSTRACT),
             AUTHOR2 = paste0("\n- ", paste0(AUTHOR[[1]]["full_name"]$full_name, collapse = "\n- ")),
             AUTHOR2 = str_remove_all(AUTHOR2, rm1),
             AUTHOR2 = stringi::stri_trans_general(AUTHOR2, "latin-ascii"),
             EDITOR2 = paste(EDITOR[[1]]["full_name"]$full_name, collapse = ", "),
             EDITOR2 = str_remove_all(EDITOR2, rm1),
             TITLE = str_remove_all(TITLE, kp),
             DATE = paste0(YEAR, "-01-01"),
             DOI2 = ifelse(is.na(DOI), "", DOI),
             URL2 = ifelse(is.na(URL), "", URL)) 
    
    foldername <- tolower(paste(df[["YEAR"]], df[["TITLE"]] %>%
                    str_remove_all("[^[:alnum:][:blank:]-]") %>%
                    str_replace_all(fixed(" "), "_") %>%
                    str_sub(1, 35), sep = "_"))
    cat(foldername, "\n")
    dir.create(file.path(outfold, foldername), showWarnings = FALSE, recursive = TRUE)
    
    # Create md file
    index_file <- "index.md"
    if (!file.exists(file.path(outfold, foldername, index_file))) {
      fileConn <- file.path(outfold, foldername, index_file)
      write("---", fileConn)
      
      # Main information
      Encoding(df[["TITLE"]]) <- "unknown"
      write(paste0("title: \"", df[["TITLE"]], "\""), fileConn, append = T)
      write(paste0("authors: ", df["AUTHOR2"]), fileConn, append = T)
      write(paste0("date: \"", anydate(df[["DATE"]]), "\""), fileConn, append = T)
      write(paste0("doi: \"", df[["DOI2"]], "\""),fileConn, append = T)
      
      # Schedule page publish date (NOT publication's date). Empty for now
      write(paste0("publishDate: \"\""),fileConn, append = T)
      
      # Publication type
      write(paste0("publication_types: [\"", df[["PUBTYPE"]], "\"]"),
            fileConn, append = T)
      
      # Publication name and optional abbreviated publication name.
      # Create pub_format for each publication type
      
      if(df[["PUBTYPE"]] == 2){
        pub_format <- paste0("***",df[["JOURNAL"]], "***")
        if (!is.na(df[["VOLUME"]])) pub_format <- paste0(pub_format, ", ", df[["VOLUME"]])
        if (!is.na(df[["NUMBER"]])) pub_format <- paste0(pub_format, "(", df[["NUMBER"]], ")")
        if (!is.na(df[["PAGES"]])) pub_format <- paste0(pub_format,  ", pp. ", df[["PAGES"]])
      } else if(df[["PUBTYPE"]] == 6) {
        pub_format <- paste0(" In: ***", df[["BOOKTITLE"]], "***")
        if (!is.na(df[["EDITOR2"]])) pub_format <- paste0(pub_format, ". Ed. by ", df[["EDITOR2"]])
        if (!is.na(df[["ADDRESS"]])) pub_format <- paste0(pub_format, ". ", df[["ADDRESS"]])
        if (!is.na(df[["PUBLISHER"]]) & !is.na(df[["ADDRESS"]])) {
          pub_format <- paste0(pub_format, ": ", df[["PUBLISHER"]])
        } else if (!is.na(df[["PUBLISHER"]]) & is.na(df[["ADDRESS"]])) {
          pub_format <- paste0(pub_format, ". ", df[["PUBLISHER"]])
        }
        if (!is.na(df[["PAGES"]])) pub_format <- paste0(pub_format, ", pp. ", df[["PAGES"]])
      } else if(df[["PUBTYPE"]] == 4) {
        pub_format <- paste0("***", df[["SERIES"]], "***")
      } else {
        pub_format <- ""
      }
    
      write(paste0("publication: \"", pub_format, "\""), fileConn, append = T)
      write(paste0("publication_short: \"", pub_format, "\""),fileConn, append = T)
      
      # Abstract and optional shortened version.
      Encoding(df[["ABSTRACT"]]) <- "unknown"
      write(paste0("abstract: \"", df[["ABSTRACT"]],"\""), fileConn, append = T)
      write(paste0("summary: \"","\""), fileConn, append = T)
      
      # Tags and projects are set to empty/false for now
      write("tags: []", fileConn, append = T)
      write("categories: []", fileConn, append = T)
      write("featured: false", fileConn, append = T)
      
      # Custom links (optional).
      #   Uncomment and edit lines below to show custom links.
      # links:
      # - name: Follow
      #   url: https://twitter.com
      #   icon_pack: fab
      #   icon: twitter
      
      # Example
      # links:
      #   - name: Published Version
      # url: "https://doi.org/10.1162/rest_a_00844"
      # - name: Ungated
      # url: files/BMP_Austerity_2019.pdf
      # - name: Fiscal Shock Series
      # url_dataset: files/BMP_shocks.xlsx
      
      #links
      write("url_pdf: \"\"", fileConn, append = T)
      write(paste0("url_pdf: \"", df[["URL2"]], "\""),fileConn, append = T)
      write("url_code: \"\"", fileConn, append = T)
      write("url_dataset: \"\"", fileConn, append = T)
      write("url_poster: \"\"", fileConn, append = T)
      write("url_preprint: \"\"", fileConn, append = T)
      write("url_project: \"\"", fileConn, append = T)
      write("url_slides: \"\"", fileConn, append = T)
      write("url_source: \"\"", fileConn, append = T)
      write("url_video: \"\"", fileConn, append = T)
      
      # Featured image
      # To use, add an image named `featured.jpg/png` to your page's folder. 
      # Placement options: 1 = Full column width, 2 = Out-set, 3 = Screen-width
      # Focal point options: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight
      # Set `preview_only` to `true` to just use the image for thumbnails.
      # Focal points: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight.
      write("image: \n  caption: \"\"", fileConn, append = T)
      write("placement: \"\"", fileConn, append = T)
      write("focal_point: \"\"", fileConn, append = T)
      write("preview_only: false", fileConn, append = T)
      
      # Associated Projects (optional).
      #   Associate this publication with one or more of your projects.
      #   Simply enter your project's folder or file name without extension.
      #   E.g. `internal-project` references `content/project/internal-project/index.md`.
      #   Otherwise, set `projects: []`.
      write("projects: []", fileConn, append = T)
      
      # Slides (optional).
      #   Associate this publication with Markdown slides.
      #   Simply enter your slide deck's filename without extension.
      #   E.g. `slides: "example"` references `content/slides/example/index.md`.
      #   Otherwise, set `slides: ""`.
      write("slides: []", fileConn, append = T)
      
      # Other parameters
      write("math: true", fileConn, append = T)
      write("highlight: true", fileConn, append = T)
      
      write("---", fileConn, append = T)
      rm(fileConn)
    }
    
    # Create cite.bib file to facilitate citation
    bib_file <- "cite.bib"
    if (!file.exists(file.path(outfold, foldername, bib_file))) {
      fileConn <- file.path(outfold, foldername, bib_file)
      cite <- df %>%
        dplyr::select(CATEGORY, BIBTEXKEY, AUTHOR, TITLE, JOURNAL, YEAR, VOLUME, NUMBER, PAGES,
                      BOOKTITLE, CHAPTER, NUMBER, SERIES, EDITOR, PUBLISHER, ADDRESS, DOI, URL) %>%
        dplyr::mutate(
          AUTHOR = paste0(AUTHOR[[1]]["full_name"]$full_name, collapse = " and "),
          AUTHOR = str_remove_all(AUTHOR, rm1),
          EDITOR = ifelse(all(is.na(df$EDITOR[[1]][["full_name"]])), NA, 
                          paste(EDITOR[[1]]["full_name"]$full_name, collapse = " and ")),
          EDITOR = str_remove_all(EDITOR, rm1))
      
      # remove all NA columns
      cite <- cite[,colSums(is.na(cite)) < nrow(cite)]
      
      df2bib(cite, file = fileConn)
    }
  }
  # apply the "create_md" function over the publications list to generate
  # the different "md" files.
  
  walk(1:nrow(mypubs), function(x) create_pub(x))
  
}
