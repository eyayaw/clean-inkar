
# Clean [Inkar Datasets](https://www.inkar.de/)

This project contains code to cleanup inkar datasets.

Inkar datasets come in an untidy format, you can check them
[here](https://www.inkar.de/WizardStart). Or, here is an example dataset:
[./data/latest/Economy/Economy-performance/Wirtschaftliche-Leistung.csv](./data/latest/Economy/Economy-performance/Wirtschaftliche-Leistung.csv)

``` r
source('clean-and-separate.R')
# example file
path = "data/latest/Economy/Economy-performance/Wirtschaftliche-Leistung.csv"
df = read_in(path)
tidy_df = make_tidy_data(df)
```

## Before

``` r
df
```

    # A tibble: 402 × 201
       Kennziffer Raumeinheit Aggregat Bruttoinlandsprodukt…¹ Bruttoinlandsprodukt…²
       <chr>      <chr>       <chr>                     <dbl>                  <dbl>
     1 <NA>       <NA>        <NA>                     2000                   2001
     2 01001      Flensburg,… krsfr. …                   31.1                   31.3
     3 01002      Kiel, Stadt krsfr. …                   33.7                   34.4
     4 01003      Lübeck, St… krsfr. …                   26.5                   27
     5 01004      Neumünster… krsfr. …                   27.5                   27.3
     6 01051      Dithmarsch… Landkre…                   22.4                   23.4
     7 01053      Herzogtum … Landkre…                   18                     16.8
     8 01054      Nordfriesl… Landkre…                   23.4                   24.3
     9 01055      Ostholstein Landkre…                   18.4                   18.8
    10 01056      Pinneberg   Landkre…                   21.4                   23.1
    # ℹ 392 more rows
    # ℹ abbreviated names: ¹​`Bruttoinlandsprodukt je Einwohner...4`,
    #   ²​`Bruttoinlandsprodukt je Einwohner...5`
    # ℹ 196 more variables: `Bruttoinlandsprodukt je Einwohner...6` <dbl>,
    #   `Bruttoinlandsprodukt je Einwohner...7` <dbl>,
    #   `Bruttoinlandsprodukt je Einwohner...8` <dbl>,
    #   `Bruttoinlandsprodukt je Einwohner...9` <dbl>, …

## After

``` r
tidy_df
```

    # A tibble: 79,398 × 6
       Kennziffer Raumeinheit      Aggregat     var                      year  value
       <chr>      <chr>            <chr>        <chr>                    <chr> <dbl>
     1 01001      Flensburg, Stadt krsfr. Stadt Bruttoinlandsprodukt je… 2000   31.1
     2 01001      Flensburg, Stadt krsfr. Stadt Bruttoinlandsprodukt je… 2001   31.3
     3 01001      Flensburg, Stadt krsfr. Stadt Bruttoinlandsprodukt je… 2002   32
     4 01001      Flensburg, Stadt krsfr. Stadt Bruttoinlandsprodukt je… 2003   32.1
     5 01001      Flensburg, Stadt krsfr. Stadt Bruttoinlandsprodukt je… 2004   34.1
     6 01001      Flensburg, Stadt krsfr. Stadt Bruttoinlandsprodukt je… 2005   35
     7 01001      Flensburg, Stadt krsfr. Stadt Bruttoinlandsprodukt je… 2006   36.2
     8 01001      Flensburg, Stadt krsfr. Stadt Bruttoinlandsprodukt je… 2007   36.2
     9 01001      Flensburg, Stadt krsfr. Stadt Bruttoinlandsprodukt je… 2008   36.6
    10 01001      Flensburg, Stadt krsfr. Stadt Bruttoinlandsprodukt je… 2009   35.3
    # ℹ 79,388 more rows
