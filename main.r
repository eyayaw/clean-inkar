source('./clean-and-separate.R')

## example file
# path = "data/latest/Economy/Economy-performance/Wirtschaftliche-Leistung.csv"
# df = read_in(path)
# df = make_tidy_data(df)
# nest_write_each(df, dir = separated(dirname(path), "separated/"))

# get all csv files
files = dir("data/latest/", ".*.csv$", recursive = TRUE, full.names = TRUE)
# exclude Metadata-.*csv files
files = grep("metadata-.*", files, value = TRUE, ignore.case = TRUE, invert = TRUE)
# Exclude those in ./**/separated/
files = grep("separated", files, value = TRUE, ignore.case = TRUE, invert = TRUE)
# it may ask you for a y/n for overwriting existing files
for (file in files) {
  df = (read_in(file))
  df = make_tidy_data(df)
  # if you wan to save to a dir called "seperated"
  # run the following lines
  save_to_dir = file.path(dirname(file), "separated")
  if (!dir.exists(save_to_dir)){
    dir.create(save_to_dir, recursive = TRUE)
  }
  nest_write_each(df, save_to_dir)
  }
