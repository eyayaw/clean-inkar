
# Kreise reference
kreise_codes <- readxl::read_xlsx("data/Referenz Gemeinden-GVB-Kreise_NUTS.xlsx", sheet = "KRS")

names(kreise_codes)[names(kreise_codes) == "...12"] <- "ktyp4_label"
kreise_codes <- kreise_codes[-1, c("krs17", "krs17name", "ksitz", "kslk", "kreg17",
                                   "kreg17name", "st_kreg", "kslk_kreg", "ktyp4",
                                   "ktyp4_label")]

labels <- c(
  "Kreise2017", "Kreise2017", "Sitz der Kreisverwaltung",
  "Kreisfreie Stadt=1/Landkreis=2 - Ebene Kreise", "Kreisregion", "Kreisregion",
  "Status der Kreisregion (1=ja 2=nein)","Kreisfreie Stadt=1/Landkreis=2 - Ebene Kreisregion",
  "siedlungsstruktureller Kreistyp 2017", "siedlungsstruktureller Kreistyp 2017"
)

attr(kreise_codes, "label") = labels

# write to csv
write.csv(kreise_codes, "./data/Kreise-reference.csv")
