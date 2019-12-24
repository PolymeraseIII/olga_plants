###------------------CHAPTER I-----------------------
###------------------LOADING DATA--------------------
#read in required packages
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(magrittr)
library(ggpubr)
library(ggthemes)

#set the working directory from which the files will be read from
path <- "/home/mati/git/olga_plants/data"
path2 <- "/home/mati/git/olga_plants/plots"
path3 <- "/home/mati/git/olga_plants/plots/normality"
setwd(path)

#create a list of the files from your target directory
file_list <- list.files(path = path)

#initiate a blank data frame, each iteration of the loop will append the data from the given file to this variable
plant <- data.frame()

#had to specify columns to get rid of the total column
for (i in 1:length(file_list)){
  temp_data <- read_csv(file_list[i]) #each file will be read in, specify which columns 
                                      #you need read in to avoid any errors
  plant <- rbind(plant, temp_data) #for each iteration, bind the new data to the building dataset
}
rm(temp_data, i, file_list, path)

###------------------CHAPTER II----------------------
###------------------DATA TIDYING--------------------
##removing na's:
plant <- plant[complete.cases(plant), ]
##removing unused variables
plant <- select(plant, -c("ID_inline", "Repetition"))
##tidying data
plant1 <- gather(select(plant, 1:13), "day", "shoot_length", 4:13)
plant2 <- gather(select(plant, 1:3, 14:23), "day", "germ", 4:13)

plant1 <- separate(plant1, day, c("g1","g2", "day"), "_")
plant2 <- separate(plant2, day, c("g1", "day"), "_")

plant <- merge(select(plant1, 1:3, 6:7), select(plant2, 1:3, 5:6), 
               by = c("ID", "day", "Concentration", "Plant"))
plant <- select(plant, -"ID")
plant <- arrange(plant, day, Concentration)
rm(plant1, plant2)

## changing types:
plant$day <- as.numeric(plant$day)
plant$Concentration <- as.factor(plant$Concentration)
###------------------CHAPTER III---------------------
###---------------DATA VISUALIZATION-----------------
setwd(path2)
my_theme <- theme_pubr() + theme(axis.text.x = element_text(angle = 60), 
                                 axis.text.x.bottom = element_text(size = 10, vjust=0.65),
                                 axis.text.y.left = element_text(size = 10))

name <- unique(plant$Plant)

for (i in seq_along(name)) {
  p <- plant %>% filter(Plant == name[i]) %>% 
    ggplot(aes(x = Concentration, y = shoot_length)) + 
    stat_summary(fun.y = mean, geom = "bar") + 
    stat_summary(fun.data = mean_ci, geom = "errorbar") + 
    facet_wrap(.~day) + 
    my_theme + 
    labs(title = name[i], y = "Długość pędu", x = "Stężenie")
  ggsave(p, file=paste(name[i], ".png", sep=''), scale=2)
}

##excluding irrelevant observations
plant <- filter(plant, Plant %in% c("jeczmien", "owies", "pszenica", "rzeżucha"))

## testing data for normality
setwd(path3)
name <- unique(plant$Plant)
dd <- unique(plant$day)
for (i in seq_along(name)) {
  sw <- plant %>% filter(Plant == name[i] & day == dd[j]) %>% select(shoot_length) %>% unlist()
    if (var(sw) != 0)
      sw <- shapiro.test(sw)

  subt <- paste(paste(sw$method, "W =", sep = "; "), 
    paste(round(sw$statistic, 3), "p.value =", sep = "; "), round(sw$p.value, 3), sep = " ")
  p <- plant %>% filter(Plant == name[i] & shoot_length != 0) %>%
    ggplot(aes(sample = shoot_length)) + 
    stat_qq() + 
    stat_qq_line() +
    facet_wrap(.~day) + 
    my_theme + 
    labs(title = name[i], subtitle = subt, y = "Próbka", x = "Kwantyl teoretyczny") 
  ggsave(p, file=paste(name[i], "_qqplot", ".png", sep=''), scale=2)
}
