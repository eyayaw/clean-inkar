library("tidyr")
library('readr')
source('translate.R')


# avoid overwriting existing files
if_doesnot_exist_write <- function(.fun, df, path, ...) {
  if (file.exists(path)) {
    message("File exists: `", path, "`\n")
    ans <- readline("Do you wanna overwrite it? [y/n] ")
    if (tolower(ans) == "y") {
      .fun(df, path, ...)
    } else if (tolower(ans) == 'n') {
    message("You chose not to overwrite the existing file, out of caution, we chose to save it under new name.")
    .fun(df, sprintf("%s-%s%s",
                    sub("[.][a-zA-Z]{3}$", "", path),
                    Sys.time(),
                    sub("(.*)([.][a-zA-Z]{3}$)", "\\2", path), ...)
         )
  } else {
    stop(sprintf("Cannot proceed because your choice (`%s`) is not either `y` or ` n`", ans), call. = FALSE)
  }
  } else {
      .fun(df, path, ...)
    }
}
read_in <- function(file,
                    delim = ";",
                    skip = 0,
                    loc = locale(decimal_mark = ",",
                                 grouping_mark = "."), ...) {
  read_delim(file = file, delim = delim, locale = loc, skip = skip, ...)
}


# get the time series dim len of the variables, takes a df what read in returns
meta_info <- function(df) {
  freq <- table(nms <- sub("[_.]\\d+", "", names(df)))
  freq <- as.data.frame(freq)
  names(freq) <- c("var", "freq")
  # since `table` annoyingly orders the result
  freq$var <- factor(freq$var, levels = unique(nms))
  freq <- freq[order(freq$var), ]
  freq
}

# takes a data frame that read_in returns
correct_names <- function(df) {
  nms <- colnames(df)
  # remove any digit following a . or _,
  # this is a result of read_csv/read.csv making unique names
  nms <- sub("[_.]\\d+", "", nms)
  # concatenate the var names and years
  firstrow <- unlist(df[1, ]) # first row holds years
  firstrow <- ifelse(is.na(firstrow), "", paste0("YEAR", firstrow))
  paste0(nms, firstrow)
}

# varying for reshape
# freq = from meta_info, the freq of vars
# a0 = from meta_info the len of vars that are ids
construct_varying <- function(freq, a0) {
  to <- vector("list", length(freq))
  for (i in seq_along(to)) {
    to[[i]] <- a0 + sum(freq[seq_len(i)])
  }
  from <- lapply(seq_along(to), function(i) if (i == 1) {
    return(a0 + 1)
  } else {
    to[[i - 1]] + 1
  })
  Map(seq, from, to)
}


# return the data in a long format
# the header of the tidy data would look like
# Kennziffer,Raumeinheit,Aggregat,var, year,value
# the column var contains all time-varying variables
#
make_tidy_data <- function(df) {
  static.vars = grepl("([Ee]ntwicklung)|([Vv]eränderung)", names(df))
  if (any(static.vars)){
    message(paste0(names(df)[static.vars], collapse = "\n"),
          " are dropped. We suspect they are static or hard to combine with the rest of the vars.")
  }

  df = df[, !static.vars]
  meta <- meta_info(df)

  idvar <- c("Kennziffer", "Raumeinheit", "Aggregat")
  stopifnot(all(idvar %in% meta$var))

  vary <- meta[!(meta$var %in% idvar), "freq"]
  vary <- construct_varying(vary, length(idvar))
  times = range(na.omit(as.integer(df[1, ])))

  good.names <- correct_names(df)
  df <- df[-1, ] # remove the row that contains the years
  df <- setNames(df, good.names)

  # handle cases when the var is named like "BaulandpreiseYEAR2016/2017"
  # becomes "BaulandpreiseYEAR2016"
  # NB: if you want "BaulandpreiseYEAR2017" change the below code to replacement="YEAR\\2"
  patt = "YEAR(\\d{4})[/.-](\\d{4})"
  problematics = grepl(patt, names(df))
  df[, problematics] = lapply(df[, problematics], readr::parse_number) # German delimiter , for .
  names(df) = sub(patt, replacement = "YEAR\\1", names(df))

  # reshape to long
  # sorry, stats::reshape does not work for unbalanced panel
  # reshape(df,
  #         direction = 'long',
  #         varying = vary,
  #         idvar = idvar,
  #         timevar = "year",
  #         times = seq(times[[1]], times[[2]]),
  #         v.names = setdiff(names(df), idvar)
  #     )

  # tidyverse alternative
  pivot_longer(df, cols = unlist(vary)) %>%
    separate(col = name, into = c("var", "year"), sep = "YEAR")  # %>%
    # pivot_wider(names_from = "var", values_from = "value")
  # uncomment the commented part if you need all vars in one dataset (i.e back to wide format but tidy)
}

# nest the data by var and then write each var to disk
nest_write_each <- function(df, dir = NULL) {
  df <- tidyr::nest(df, data = -var)
  by = vapply(df[["data"]], function(df) df[["Aggregat"]][[1]], "")
  by = gsub("\\s|[.]", "", by)
  varname = gsub("/", "-or-", trimws(df[['var']])) # / is dir sep must be removed
  path <- sprintf("%s/%s-by-%s.csv", dir, varname, by)
  lapply(1:nrow(df), function(i) {
   if_doesnot_exist_write(write_csv, df$data[[i]], path[[i]])
  })
}


# a fucntion that does it all -----
# read in the .csv file with `read_in`, `make_tidy_data` and `nest_write_each`
## then read in the metadata from the .xls (sheet = Metadaten),
## translate it
## write it to a file with name Meta-*
## append the first two rows of meta_trans to columns-list.csv
## write each var to separated/*
do_all_steps <- function(path) {
  .dir <- dirname(path)
  xls.path <- sub("[.][A-Za-z]{3}$", ".xls", path)
  meta.path <- sprintf("%s/Metadata-%s", .dir, basename(path))
  if (file.exists(meta.path)) {
    message("File exists: `", meta.path, "`\n")
    message("No need to translate the metadata. It seems it already is.\n")
    meta_trans = read_csv(meta.path)
  }
  else {
      meta_trans <- translate_metadata(read_metadata_xls(xls.path))
      names(meta_trans) <- make_metadata_names(meta_trans)
      write_csv(meta_trans, meta.path)
      }
  .table <- read_csv("data/column-names.csv")
  if (any(newones <- !(meta_trans$Indikator %in% .table$de)))
   write_csv(with(meta_trans[newones,], data.frame(de = Indikator, en = Indicator)),
          "data/column-names.csv", append = TRUE)

  .table <- read_csv("data/column-names.csv")
  if (!dir.exists(new.dir <- paste0(.dir, "/separated"))) {
    dir.create(new.dir)
  }
  df_cleaned <- make_tidy_data(read_in(path))
  nest_write_each(df_cleaned, new.dir)
  if_doesnot_exist_write(
    write_tsv,
    translate_colnames(nest(df_cleaned, data = -var)$var, .table),
    paste0(new.dir, "/readme.txt")
  )
}

