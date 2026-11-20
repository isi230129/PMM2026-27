library(tidyverse)
rawdata <- read.csv("Data/betriebsdaten.csv")
view(rawdata)ergleich <- daten |> filter(maschine %in% c("M1", "M3"))
t.test(masse_mm ~ maschine, data = vergleich)
vergleich <- rawdata |> filter(maschine %in% c("M1", "M3"))
 t.test(masse_mm ~ maschine, data = vergleich)
 chargen <- rawdata |>
   +     group_by(maschine, charge) |>
   +     summarise(mm = mean(masse_mm, na.rm = TRUE), .groups = "drop") |>
   +     pivot_wider(names_from = maschine, values_from = mm)
 
    chargen$M3 - chargen$M1