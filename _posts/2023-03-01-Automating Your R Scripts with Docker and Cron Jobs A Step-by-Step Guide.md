---
title: Automating Your R Scripts with Docker and Cron Jobs: A Step-by-Step Guide
author: Andrés de la Rosa
date: 2023-03-03 09:10:00 +0800
categories: [Docker, Tutoral]
tags: [BCRD, FMI, r-programming]
image: /assets/img/automating_r_script/cloud_images.jpg
toc: true
---

Sometimes we want automatize a script on the cloud or an on-premise server without using local task schedulers. To achieve this, lets use containers and a cron job!

A Docker is a tool that allows us to deploy and run applications using containers. A container has all the parts of the environment that you need to run your software, such as libraries and dependencies in our R script.

The advantage of Docker is its portability, meaning that you can create your environment and deploy it on any cloud or another computer.

Steps
1. Create a directory (folder) for the project.
2. Inside the new directory Create a Dockerfile, a file that will have all the necessary instructions to create the R environment, download its dependencies and packages to execute the script.


```
FROM rocker/tidyverse:latest

##We copy the file inside the container
COPY /install_packages.R /install_packages.R
COPY /script_to_run.R /script_to_run.R

## We install the packages
RUN Rscript /install_packages.R

## We execute the script
CMD ["Rscript", "script_to_run.R"]
```

In this case we’ll use the last tidyverse docker image configured by rocker. If you want an specific R version you have to specify it after :

3. Create R script named install_packages.R that will be called by the Dockerfile when building to download the packages that we will be using in our task.

```
install.packages("tidyverse")
install.packages("xts")
install.packages("zoo")
install.packages("tidyquant")
install.packages("timetk")
install.packages("lubridate")
```

4. Create your script. Here I use the function suppressPackageStartupMessages to get a cleaner terminal result. In this case we are getting daily returns for the selected stocks on the vector FAANG.

```
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(xts))
suppressPackageStartupMessages(library(zoo))
suppressPackageStartupMessages(library(tidyquant))
suppressPackageStartupMessages(library(lubridate))
suppressPackageStartupMessages(library(zoo))
suppressPackageStartupMessages(library(timetk))


initial_date <- floor_date(Sys.Date() - weeks(1), "week")

FAANG <- c("AAPL", "GOOG", "AMZN", "NFLX")
xtsFAANG_daily_returns <- FAANG %>% 
  tq_get(get = "stock.prices",
         from = initial_date, to = Sys.Date()) %>% 
  group_by(symbol) %>% 
  tq_transmute(select = adjusted,
               mutate_fun = periodReturn,   
               period="daily", 
               type="arithmetic") %>%
  select(symbol, date, daily.returns) %>%
  spread(symbol,daily.returns) %>%
  tk_xts(silent = TRUE)

xtsFAANG_daily_returns[nrow(xtsFAANG_daily_returns), ]*100
```

5. Go to your proyect directory on the terminal.

```
cd ../Documents/project_directory
```


6. Build the container

```
sudo docker build -t auto_script .
```


Its going to take a while building the tidyverse image. Don’t forget the . at the end of the command. This tells our terminal that the Dockerfile its inside the proyect directory and its named Dockerfile.


7. Run the container

```
run sudo docker run auto_script
```

You should be able to see this result on your terminal.


<img src="/assets/img/automating_r_script/bash_results.jpg"/> 


If you want the script to be run on a daily basis you can create a bash shell script file named process.sh that runs the container on a cron job.

```
#!/bin/sh 
sudo docker run  auto_script
```

Configure the cron job by opening contrab -e in the terminal and setting up the job like this:

```
0 18 * * 1-5 process.sh > process.txt
```

This commands will run process.sh every weekday at 6:ooPM and write the log to the file process.txt.

This is a nice webpage to configure your cron job given your specific needs https://crontab-generator.org/

Finally, this steps can be taken on a mac or linux computer or a VM instance with those operating systems.
