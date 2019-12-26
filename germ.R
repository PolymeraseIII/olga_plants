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
path4 <- "/home/mati/git/olga_plants/plots/pubr"
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
###---------------DATA EXPLORATION-----------------
setwd(path2)
my_theme <- theme_pubr() + theme(axis.text.x = element_text(angle = 60), 
                                 axis.text.x.bottom = element_text(size = 10, vjust=0.65),
                                 axis.text.y.left = element_text(size = 10),
                                 legend.position = "right")

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
name2 <- c("Jęczmień", "Owies", "Pszenica", "Rzeżucha")
dd <- unique(plant$day)
for (i in seq_along(name)) {
  sw <- plant %>% filter(Plant == name[i]) %>% select(shoot_length) %>% unlist()
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
    labs(title = name2[i], subtitle = subt, y = "Próbka", x = "Kwantyl teoretyczny") 
  ggsave(p, file=paste(name[i], "_qqplot", ".png", sep=''), scale=2)
}

###------------------CHAPTER IV----------------------
###---------DATA ANALYSIS AND VISUALIZATION----------
setwd(path4)
symbols <- list(cutpoints = c(0, 0.0001, 0.001, 0.01, 0.05, 1), 
                symbols = c("****", "***", "**", "*", "ns"))
my_comparisons <- list(c("0", "1.5625"), c("0", "3.125"), c("0", "6.25"), c("0", "12.5"), 
                       c("0", "25"), c("0", "50"), c("0", "100"))
cbp1 <- c("#999999", "#E69F00", "#56B4E9", "#009E73",
          "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

for (i in seq_along(name)) {
p <- plant %>% filter(Plant == name[i] & shoot_length != 0) %>%
  ggplot(aes(x = Concentration, y = shoot_length)) + 
  stat_summary(fun.y = median, geom = "bar", fill = "#FC4E07", width = 0.7) +
  stat_summary(fun.data = median_iqr, geom = "pointrange") +  
  stat_compare_means(ref.group = "0", symnum.args = symbols, 
                     method = "wilcox.test", label = "p.signif") + 
  #geom_jitter(fill = "#00AFBB", alpha = 0.3, width = 0.4) + 
  facet_wrap(.~day) + 
  ylim(-8, 27) + 
  my_theme + 
  labs(x = "Stężenie [%]", y = "Długość pędu [cm]")
ggsave(p, file=paste(name[i], "_pubr", ".png", sep=''), scale=2)
}

## signif - plotting proportion of values which are significant
## multiple wilcox testing and assignment

a <- vector()
b <- vector()
c <- vector()
d <- vector()
e <- vector()
f <- vector()

conc <- unique(plant$Concentration)
conc <- conc[conc != 0]
plant$Concentration <- as.character(plant$Concentration)

for (i in seq_along(name)) {
  for (j in 1:length(dd)) {
    for (k in 1:length(conc)) {
      if(j <= length(dd)) {
        data1 <- plant %>% filter(Plant == name[i], day == dd[j], Concentration == 0) %>% 
          select(shoot_length) %>% unlist()
        data2 <- plant %>% filter(Plant == name[i], day == dd[j], Concentration == conc[k]) %>% 
          select(shoot_length) %>% unlist()
        if (var(data1) != 0 & var(data2) != 0) {
          w <- wilcox.test(data1, data2) 
          a[paste(i, j, k)] <- name[i]
          b[paste(i, j, k)] <- dd[j]
          c[paste(i, j, k)] <- 0
          d[paste(i, j, k)] <- conc[k]
          e[paste(i, j, k)] <- w$p.value
          f[paste(i, j, k)] <- w$statistic
        }
      }
    }
  }
}
## creating a data frame:
wx <- data.frame(plant = a, day = as.factor(b), ref = c, conc = d, p_val = e, w_stat = f)
wx$conc <- as.factor(wx$conc)
levels(wx$conc) <- c("1.5625", "3.125", "6.25", "12.5", "25", "50", "100")

#discreting p value of significance
for (i in seq_along(wx$p_val)) {
  if (wx$p_val[i] < 0.05)
    wx$p_disc[i] <- "< 0.05"
  else if (wx$p_val[i] >= 0.05 & wx$p_val[i] < 0.1)
    wx$p_disc[i] <- "> 0.05 and < 0.1"
  else if ((wx$p_val[i] >= 0.1 & wx$p_val[i] < 0.25))
    wx$p_disc[i] <- "> 0.1 and < 0.25"
  else 
    wx$p_disc[i] <- "> 0.25"
}

#changing labels of plant\
wx$plant <- as.character(wx$plant)
for (i in seq_along(wx$plant)) {
  if (wx$plant[i] == "jeczmien")
    wx$plant[i] <- "Jęczmień"
  else if (wx$plant[i] == "owies")
    wx$plant[i] <- "Owies"
  else if (wx$plant[i] == "rzeżucha")
    wx$plant[i] <- "Rzeżucha"
  else 
    wx$plant[i] <- "Pszenica"
}

## plotting
p <- ggplot(wx, aes(conc, day, fill = p_disc)) + 
  geom_raster() + 
  facet_wrap(.~plant) + 
  my_theme + 
  labs(x = "Stężenie", y = "Dzień") + 
  scale_fill_brewer(name = "Poziom istotności", 
                    labels = c("mniejszy niż 0.05", "pomiędzy 0.05, a 0.1", 
                               "pomiędzy 0.1 a 0.25", "większy niż 0.25"), 
                    palette = 18)
ggsave(p, file="pval_pubr.png", scale=2)

#rm(list = ls())
