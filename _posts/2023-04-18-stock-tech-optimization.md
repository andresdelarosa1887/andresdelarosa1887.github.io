---
title: Optimization of a Technology Stock Portfolio using R with PerformanceAnalytics and TidyQuant - (Part 1)
author: Andrés de la Rosa
date: 2023-03-03 14:10:00 +0800
categories: [Finance, Tutoral]
tags: [R, Financial, Tidyquant]
image: /assets/img/proyectos_financieros/finance_image.jpg
toc: true
---

The modern portfolio theory proposed by Harry Markowitz tells us that there is an optimal allocation of financial instrument weights that maximizes our portfolio's return while controlling its volatility, given a level of risk.

In this tutorial, we will learn how to use R to optimize a portfolio with a basic strategy and compare its performance with two benchmarks (FAANG and the S&P500) using a group of random technology companies' stocks in the US with the same initial investment weight.

###  Benchmarks (Comparison Indices)
To analyze how good our portfolio optimization was (using historical data), it is recommended to compare observed returns with some reference. For this purpose, the S&P500 is usually used as a benchmark, which is a stock index that measures the performance of the stocks of 500 large companies traded on the US stock exchanges.

Also, since in this analysis we will be optimizing a portfolio of technology sector companies, it is convenient to use the FAANG group of stocks composed of Facebook (FB), Amazon (AMZN), Apple (APPL), Netflix (NFLX), and Alphabet (GOOG) as a reference, which have become leaders in the sector over the last few decades.

Information Retrieval
To retrieve the daily information of this set of stocks, we will use the tq_get function of the tidyquant package. This function returns data related to the stock given the search period, in this case, from January 1, 2018, to December 15, 2020, such as the opening price, the maximum, the minimum, the closing price, and an adjusted price. It also includes the traded volume.


```
#Required Packages
pacman::p_load(xts, zoo, PerformanceAnalytics, quantmod, plotly,
               tidyverse, dplyr, PortfolioAnalytics, tidyquant,ROI,
               ROI.plugin.quadprog, ROI.plugin.glpk, timetk, ggeasy)
```

For our analysis, we will only need the adjusted price of the day, the stock ticker, and the date. From these variables, we will obtain the daily return using tq_transmute. Then we will convert it into an XTS object.


```
##Fecha inicial de nuestro análisis
fecha_inicial <- "2018-01-01"
#Consultamos nuestro primer benchmark  S&P 500
xtsSP500_daily_returns <- tq_get("SP500", get = "economic.data",
                from = fecha_inicial,to = Sys.Date())%>% 
  tq_transmute(select = price,
               mutate_fun = periodReturn,   
               period="daily", 
               type="arithmetic") %>%
  select(date,daily.returns) %>%
  tk_xts(silent = TRUE)
##Consultamos el Grupo de acciones FAANG y obtenemos los retornos en formato XTS##
FAANG <- c("AAPL", "GOOG", "AMZN", "FB", "NFLX")
xtsFAANG_daily_returns <- FAANG %>% 
  tq_get(get = "stock.prices",
         from = fecha_inicial, to = Sys.Date()) %>% 
  group_by(symbol) %>% 
  tq_transmute(select = adjusted,
               mutate_fun = periodReturn,   
               period="daily", 
               type="arithmetic") %>%
  select(symbol, date, daily.returns) %>%
  spread(symbol,daily.returns) %>%
  tk_xts(silent = TRUE)
```

When we retrieve this information, we obtain two xts objects with the daily returns of each FAANG stock and the SP500, saved in xtsFAANG_daily_returns and xtsSP500_daily_returns, respectively.

Let's evaluate what the xtsFAANG_daily_returns object contains.

<img src="/assets/img/finance_in_R/stocks_return.jpg"/> 

