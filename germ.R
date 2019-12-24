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
    geom_bar(stat = "identity") + 
    facet_wrap(.~day) + 
    my_theme + 
    labs(title = name[i], y = "Długość pędu", x = "Concentration")
  ggsave(p, file=paste(name[i], ".png", sep=''), scale=2)  
  print(p)
}
