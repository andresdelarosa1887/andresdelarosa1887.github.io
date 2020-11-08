---
title: Consultar las Proyecciones Macroeconómicas del FMI (Panorama Económico Mundial) para la República Dominicana y el Mundo
author: Andrés de la Rosa
date: 2020-10-27 14:10:00 +0800
categories: [Presentaciones, Tutoriales]
tags: [BCRD, FMI, r-programming]
image: /assets/img/Tutoriales/IngresosyGastos.png
toc: true
---

Es de conocimiento general que los economistas, financistas e incluso el público en general tienden a evaluar con cierto grado de escepticismo las proyecciones de variables macroeconómicas. Dentro de las fuentes locales comunes, se encuentran los informes económicos del Banco Central, los del Ministerio de Planificación y Economía y los de economistas independientes. Sin embargo, estos son generalmente publicados dentro de textos y formatos limitantes a la automatización de consulta y actualizaciones.

Una alternativa eficiente y confiable sería utilizar los datos del Fondo Monetario Internacional que son publicados a través del [World Economic Outlook](https://www.imf.org/en/Publications/SPROLLs/world-economic-outlook-databases#sort=%40imfdate%20descending) (WEO) en formato SDMX en donde se encuentran proyecciones de las principales variables económicas hasta el 2025.

Estos datos son publicados y actualizados dos veces al año. En octubre y en abril. Además, si se desean evaluar las proyecciones anteriores de las variables estudiadas se pueden consultar en este [enlace](https://www.imf.org/external/pubs/ft/weo/data/WEOhistorical.xlsx).

Este conjunto de datos está estandarizados bajo el formato SDMX y posee un listado de códigos que puede ser consultado [aquí](https://www.imf.org/~/media/Files/Publications/WEO/WEO-Database/2020/02/weooct2020-sdmxdsd.ashx).

Para la República Dominicana el WEO provee 31 indicadores económicos distintos para los que se tienen proyecciones al 2025.

Algunos de estos son:
- Crecimiento real del PIB
- Inflación
- Deuda bruta como porcentaje del PIB y en moneda nacional
- Deuda neta como porcentaje del PIB y en moneda nacional
- Exportaciones/Importaciones en moneda nacional
- Déficit corriente

Para consultar los datos, primero llamamos a la base de datos del World Economic Outlook en formato SDMX que se encuentra colgadas en un zip file en el link utilizado debajo.


```
pacman::p_load(readsdmx,readxl,tidyverse,  scales,
               data.table, stringr, lubridate, zoo,
               parsedate,httr,readxl,rsdmx, utils)

tf <- tempfile(tmpdir = tdir <- tempdir()) 
download.file("https://www.imf.org/~/media/Files/Publications/WEO/WEO-Database/2020/02/weooct2020-sdmxdata.ashx", tf)

sdmx_files <- unzip(tf, exdir = tdir)
sdmx <- readSDMX(sdmx_files[1], isURL = FALSE)
stats <- as.data.frame(sdmx) #Esto puede durar algunos minutos

View(stats)
```

![Desktop View](/assets/img/Tutoriales/VistaTabla.png){: width="500" class="right"}

Esta base de datos se compone de 480,792 registros y 13 columnas. De donde existen datos para 208 países o grupos de países, por ejemplo, economías avanzadas, Latinoamerica y el Caribe, Economías Emergentes, etc.

En este conjunto de datos, las variables más importante son REF_AREA y CONCEPT que hacen referencia a los países o grupos de países y a las definiciones de las variables, respectivamente.

Para obtener las definiciones de estas referencias consultamos la lista de códigos provista por el FMI en formato Excel, hacemos algunas transformaciones y cruzamos las descripciones con la base de datos grande.


```
## Descargamos la base con los codelist que nos permitirán traducir los códigos, esta viene en excel

CodelistsFMIURL <- "https://www.imf.org/~/media/Files/Publications/WEO/WEO-Database/2020/02/weooct2020-sdmxdsd.ashx" 

GET(CodelistsFMIURL, write_disk(tf <- tempfile(fileext = ".xlsx")))

##Consultamos las hojas de los excel con la informacion
CodelistRefArea <- read_excel(tf, sheet = "REF_AREA")
CodelistCONCEPT <- read_excel(tf, sheet = "CONCEPT")

##Limpiamos un poco los excel para cruzar la información 
##Para el codelist de ubicaciones de Referencia
CodelistRefArea <- CodelistRefArea[8:nrow(CodelistRefArea),]
colnames(CodelistRefArea) <- c("REF_AREA", "PAISoGRUPO")

##Para el codelist de las variables
CodelistCONCEPT <- CodelistCONCEPT[8:155, 1:2]
colnames(CodelistCONCEPT) <- c("CONCEPT", "INDICADOR")
```

Unimos las descripciones con la base grande.

```
stats  <- left_join(stats, CodelistCONCEPT, by="CONCEPT")
stats <-  left_join(stats, CodelistRefArea, by="REF_AREA")
```

Listo. Ya tenemos la base completa con las descripciones. Consultemos algunos indicadores para la República Dominicana.

```
RepublicaDominicana <- stats %>%
filter(REF_AREA=="243" #Codigo de referencia de RD
& CONCEPT %in%  c("GGXWDG_NGDP", #Deuda bruta como %del PIB
         "GGR_NGDP", #Ingresos del gobierno como % del PIB
         "GGX_NGDP") #Gastos del gobierno como % del PIB
&  OBS_VALUE !="n/a") #Los valores nulos en este formato son n/a
```

![Desktop View](/assets/img/Tutoriales/DeudadelGobierno.gif){: width="500" class="right"}


Como podemos ver, es bastante conveniente consultar simultáneamente las proyecciones de varios indicadores económicos si deseamos crear un aplicativo que consuma la información o la creación de una base de datos.