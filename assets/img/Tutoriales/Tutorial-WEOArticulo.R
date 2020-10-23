pacman::p_load(readsdmx,readxl,tidyverse,  scales,
               data.table, stringr, lubridate, zoo,
               odbc, parsedate, DBI,httr,readxl,rsdmx, utils, DBI)

## Descargamos  el zip file con la base de datos completa del Work Economic Outlook
tf <- tempfile(tmpdir = tdir <- tempdir()) #temp file and folder
download.file("https://www.imf.org/~/media/Files/Publications/WEO/WEO-Database/2020/02/weooct2020-sdmxdata.ashx", tf)
sdmx_files <- unzip(tf, exdir = tdir)

sdmx <- readSDMX(sdmx_files[1], isURL = FALSE)
stats <- as.data.frame(sdmx)

nrow(stats)
ncol(stats)
levels(as.factor(stats$REF_AREA))

## Descargamos la base con los codelist que nos permitirán traducir los códigos, estas vienen en excel
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

##Unimos los datos completos con las descripciones buscadas
stats  <- left_join(stats, CodelistCONCEPT, by="CONCEPT")
stats <- left_join(stats, CodelistRefArea, by="REF_AREA")

##Con estos ultimos pasos ya tenemos la base de datos completa del World Economic Outlook##
##El codigo de referencia de la República dominicana es 243
RepublicaDominicana <- stats %>% filter(REF_AREA=="243"  ##Codigo de referencia de la República Dominicana
                                        & CONCEPT %in%  c("GGXWDG_NGDP",  ##Deuda Bruta como porcentage del PIB
                                                          "GGR_NGDP", ##Ingresos del gobierno como porcentaje del PIB 
                                                          "GGX_NGDP") &  ##Gastos del gobierno como porcentaje del PIB
                                          OBS_VALUE !="n/a") ##Los valores nulos en este formato son n/a


##Existen 31 indicadores económicos disponibles para la República Dominicana con proyecciones al 2025
length(levels(as.factor(RepublicaDominicana$INDICADOR)))
View(levels(as.factor(RepublicaDominicana$INDICADOR)))


##Grafico Ingresos vs. Gastos como Porcentaje del PIB 
RepublicaDominicana2 <-  RepublicaDominicana %>% filter(CONCEPT %in% c("GGR_NGDP", "GGX_NGDP"))
levels(as.factor(RepublicaDominicana2$INDICADOR))

RepublicaDominicana2 <- as_tibble(RepublicaDominicana2)

ggplot(RepublicaDominicana2, aes(x=as.factor(TIME_PERIOD),y=as.numeric(OBS_VALUE), group=INDICADOR)) +
  geom_line(aes(color=INDICADOR, linetype=INDICADOR), size=5.2) +
  geom_vline(xintercept= 24, linetype='dashed', size=1.5) +
  geom_point(aes(color=INDICADOR), size=6) + 
  scale_color_manual(values =  c("General government total expenditure"= "#3050D1", "General government revenue"= "gray50")) +
  scale_linetype_manual(values = c( "General government total expenditure"= "solid", "General government revenue"="twodash")) +
  labs(title="Ingresos y Gastos del Gobierno de la República Dominicana", subtitle=  "Como % del PIB- Según el FMI") +
  labs(caption="Andrés de la Rosa \n Proyecciones a partir del 2020, últimos datos entregados: 2019")+
  xlab(label="Año")+
  ylab(label="% del PIB") +
  # transition_reveal(along = Año) +
  theme(plot.title = element_text(size=40, hjust=0.5, color="black", face="bold"),
        plot.subtitle = element_text(size=38, face="bold", hjust=0.5),
        axis.title.y = element_text(size=16, color="black"),
        plot.caption = element_text(size=14, hjust=0.5),
        axis.text.y= element_text(size=14, color="black", face="bold"),
        axis.text.x= element_text(size=14, color="black", face="bold"),
        legend.position="bottom",
        legend.text= element_text(size=18),
        legend.title = element_text(size=14, face="bold"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank()) 



animate(publicidad_contratos, nframes = 300,  width = 900, height = 600) 





##Deuda bruta como Porcentaje del PIB 
RepublicaDominicana2 <-  RepublicaDominicana %>% filter(CONCEPT %in% c("GGXWDG_NGDP"))
levels(as.factor(RepublicaDominicana2$INDICADOR))

RepublicaDominicana2 <- as_tibble(RepublicaDominicana2)

pacman::p_load(tidyverse, scales,gifski, tidyr,
               reshape, animation, gganimate, ggplot2, readxl, dplyr, haven, tweenr)

deuda_del_gobierno <- ggplot(RepublicaDominicana2, aes(x=as.factor(TIME_PERIOD),y=as.numeric(OBS_VALUE), group=INDICADOR)) +
  geom_line(aes(color=INDICADOR, linetype=INDICADOR), size=5.2) +
  geom_vline(xintercept= 24, linetype='dashed', size=1.5) +
  geom_point(aes(color=INDICADOR), size=6) + 
  scale_color_manual(values =  c("General government gross debt"= "#3050D1")) +
  scale_linetype_manual(values = c("General government gross debt"= "solid")) +
  labs(title="Deuda Bruta del Gobierno de la República Dominicana", subtitle=  "Como % del PIB- Según el FMI") +
  labs(caption="Andrés de la Rosa \n Proyecciones a partir del 2020, últimos datos entregados: 2019")+
  xlab(label="Año")+
  ylab(label="% del PIB") +
  transition_reveal(along = as.numeric(TIME_PERIOD)) +
  theme(plot.title = element_text(size=35, hjust=0.5, color="black", face="bold"),
        plot.subtitle = element_text(size=30, face="bold", hjust=0.5),
        axis.title.y = element_text(size=16, color="black"),
        plot.caption = element_text(size=14, hjust=0.5),
        axis.text.y= element_text(size=14, color="black", face="bold"),
        axis.text.x= element_text(size=11, color="black", face="bold"),
        legend.position="bottom",
        legend.text= element_text(size=18),
        legend.title = element_text(size=14, face="bold"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank()) 




animate(deuda_del_gobierno, nframes = 300,  width = 1040, height = 600) 
anim_save("DeudadelGobierno.gif")




