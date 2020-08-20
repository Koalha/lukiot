## Tämä skripti muokkaa lähtöaineistoa siten, että sitä on mahdollista mallintaa järjestysasteikollisella logistisella regressiolla.
library(tidyverse)
library(readxl)

## Keskiarvorajat 2017
d <- read_excel("data/Ammatillisen_koulutuksen_lukiokoulutuksen_yhteishaku_pisterajat_2017.xlsx")
names(d)[1] <- "koulun_nimi"
names(d)[2] <- "alin_ka_17"

## Poistetaan steinerlukiot ja IB-linjat ja kaikki taidehömppä, joka nostaa rajoja yli 10
d %>% arrange(desc(alin_ka_17))
d <- d %>% filter(alin_ka_17 <= 10)
d$koulun_nimi <- tolower(d$koulun_nimi)

# Kevään ylioppilaskirjoitukset
# https://www.ylioppilastutkinto.fi/tietopalvelut/tilastot/koulukohtaisia-tunnuslukuja
yo <- read_csv2("data/kevat2020_ylioppilaskirjoitukset.csv", col_types = paste(rep("c",51), collapse = ""))
yo <- yo %>% select(koulun_nimi,sukup,A)
yo$koulun_nimi <- tolower(yo$koulun_nimi)

koulut <- yo$koulun_nimi %>% unique

## Mille kouluille on keskiarvoraja: 288 lukiolle.
# Kaikille ei ole. Iltalukiot, aikuislukiot, lukiot, joissa on vain erikoislinjoja.
# Aineisto suomenkielisille äidinkielen arvosanoille - ei ruotsinkielisiä kouluja.
koulut[koulut %in% d$koulun_nimi] # on 188 lukiota
koulut[!koulut %in% d$koulun_nimi] # ei - 113 lukiota

# yhdistä, poista puuttuvat rivit, tallenna.
out <- yo %>% left_join(d)
out <- out %>% na.omit

# dir.create("results/clean_data",recursive = TRUE)
write_csv(out,"results/clean_data/aidinkieli_k20.csv")
