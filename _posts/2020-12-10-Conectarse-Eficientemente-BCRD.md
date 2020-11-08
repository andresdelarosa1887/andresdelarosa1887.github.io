---
title: Conectarse Eficientemente a las Estadísticas Generadas por el Banco Central de la República Dominicana (SDMX)
author: Andrés de la Rosa
date: 2020-10-12 14:10:00 +0800
categories: [Presentaciones, Tutoriales]
tags: [BCRD, r-programming]
image: /assets/img/Tutoriales/lentes_programacion.jpg
toc: true
---

Las estadísticas económicas publicadas por el Banco Central de la República Dominicana (BCRD) son de los datos más demandado y utilizados por economistas, investigadores, empresas, bancos, etc. Estas son publicadas a través de la página web del BCRD en formato Excel.

Si se desea desarrollar un servicio con estos datos con los fines de crear una base de datos o un aplicativo, leer los archivos Excel se hace bastante complejo debido al diseño de los mismos.

Por suerte, el BCRD está adherido a los estándares de publicación del Enhanced General Data Dissemination System (e-GDDS) promovido por el Fondo Monetario Internacional.
Los datos publicados se encuentran en el formato Statistical Data and Metadata eXchange (SDMX) y pueden ser accedidos en el National Summary Data Page (NSDP) que esta colgado en la página web del BCRD, que también está diseñada de acuerdo a este mismo estándar .
Bajo este estándar, los datos se actualizan con la misma frecuencia que los excel públicos y el calendario de publicación del Banco Central.

Lo bueno es que como es un estándar mundial, los indicadores económicos pueden ser cruzados con los de otros países, la información está adherida a buenos estándares de calidad y tiene buena documentación.

Por otra parte, el BCRD tiene una API que pudiera ser más oportuna, pero para lograr esta conexión se debe enviar una comunicación directa a las autoridades.

A continuación se comparte un breve tutorial en R para acceder a los datos de cuentas nacionales utilizando el paquete readsdmx, en el caso de python se puede utilizar la libreria pandaSDMX.



INDICATOR es la variable más importante de este set y debe ser definida cruzando con las definiciones de los indicadores provistas por el FMI. Los codelists de cada conjunto de datos se encuentra en el siguiente [link](http://dsbb.imf.org/images/excels/ECOFIN-Economic%20Indicator%20Codelist.xlsx).

![Desktop View](/assets/img/Tutoriales/tableBC.png){: width="500" class="right"}

Del conjunto de datos consultados existen 83 indicadores, de los que se tiene información histórica en diferentes periodicidades.


```
length(levels(as.factor(CuentasNacionales$INDICATOR)))
> 83
```

Luego de haber identificado las descripciones de los indicadores con los mencionados codelists consultamos al PIB real codificado como NGDP_R_XDC y graficamos.

```
grafico <- CuentasNacionales%>% filter(INDICATOR=="NGDP_R_XDC")
#Sustraemos el año de la variable TIME_PERIOD
grafico$ANO <- substr(grafico$TIME_PERIOD, 1,4)
#Agrupamos los datos
grafico <- grafico %>% filter(ANO>2000) %>%
  select(ANO, OBS_VALUE) %>% group_by(ANO) %>% summarise(PIB= mean(as.numeric(OBS_VALUE)))
#Graficamos
ggplot(data=grafico, aes(x=ANO,
                         y=as.numeric(PIB), group=1)) +
  geom_line() + 
  ggtitle("Producto Interno Bruto \n Índices de volumen encadenados, referenciados al año 2007 (Promedio Anual)") +
  ylab("PIB") + xlab("Año")
```

![Desktop View](/assets/img/Tutoriales/pobGraph.png){: width="500" class="right"}

El indicador consultado vendría siendo el excel equivalente compartido [aquí](https://cdn.bancentral.gov.do/documents/estadisticas/sector-real/documents/pib_2007.xlsx?v=1602394133150).


![Desktop View](/assets/img/Tutoriales/show_BC.png){: width="500" class="right"}

Como podemos ver, es bastante conveniente consultar la información a través de un estándar de formato abierto ya que permite la automatización efectiva de cualquier tarea que involucre la consulta de las estadísticas económicas del BCRD.