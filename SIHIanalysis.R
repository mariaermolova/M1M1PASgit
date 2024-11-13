library(tidyverse)
library(lattice)
library(latticeExtra)
library(gridExtra) # adjust plots in a grid
library(lme4) # linear mixed models
library(kableExtra)
library(nlme)
library(performance)
setwd("W:/Projects/2019-04 M1M1PAS Project/analysis")

MEPdata <- read.csv('MEPdata.csv', header=TRUE, sep=',', dec='.')
MEPdata$Subject <- factor(MEPdata$Subject)
MEPdata$Intervention <- factor(MEPdata$Intervention)
MEPdata$Time <- factor(MEPdata$Time,levels=c("Pre","0","30","60"))
MEPdata$Channel <- factor(MEPdata$Channel)
MEPdata$Intensity <- as.numeric(MEPdata$Intensity)
MEPdata$Response <- as.numeric(MEPdata$Response)

FDIdata <- subset(MEPdata, Channel == "FDIl")

FDIdata %>%
  #filter(Intervention == c("negpos","posneg","negneg","random")) %>%
  ggplot(aes(x = Time,  
             y = Response,
             group = Intensity,  
             color = Intensity)) +    
  geom_point(size = 3) + 
  geom_line(size=1) +
  #geom_errorbar(aes(ymax=measure_mean+measure_sd, ymin=measure_mean-measure_sd), width=.1, size = 1) +
  theme(legend.position="top") +
  facet_wrap(~ Intervention + Subject)

sum_FDIdata <- FDIdata %>%   
  group_by(Intervention, Time, Intensity, Subject) %>%  
  summarize(measure_med = median(Response),
            measure_mean = mean(Response),
            measure_sd = sd(Response),
            measure_se = measure_sd/n(),
            n_samples = n()) %>%
  ungroup() 

sum_FDIdata <- FDIdata %>%   
  group_by(Intervention, Time, Intensity) %>%  
  summarize(measure_med = median(Response),
            measure_mean = mean(Response),
            measure_sd = sd(Response),
            measure_se = measure_sd/n(),
            n_samples = n()) %>%
  ungroup() 

sum_FDIdata <- FDIdata %>%   
  group_by(Intervention, Intensity, Subject) %>%  
  summarize(measure_mean = mean(ResponseNorm)) %>%
  ungroup()

subsum_FDIdata <- sum_FDIdata %>%   
  group_by(Intervention, Intensity) %>%  
  summarize(sihi_med = median(measure_mean),
            sihi_mean = mean(measure_mean),
            sihi_sd = sd(measure_mean),
            sihi_se = sihi_sd/n(),
            n_samples = n()) %>%
  ungroup()

sum_FDIdata <- FDIdata %>%   
  group_by(Intervention, Time, Subject) %>%  
  summarize(measure_mean = mean(ResponseNorm)) %>%
  ungroup()

subsum_FDIdata <- sum_FDIdata %>%   
  group_by(Intervention, Time) %>%  
  summarize(sihi_med = median(measure_mean),
            sihi_mean = mean(measure_mean),
            sihi_sd = sd(measure_mean),
            sihi_se = sihi_sd/n(),
            n_samples = n()) %>%
  ungroup()

sum_FDIdata %>%
  filter(Intervention == c("random")) %>%
  ggplot(aes(x = Time,  
             y = measure_med,
             group = Intensity,  
             color = Intensity)) +    
  geom_point(size = 3) + 
  geom_line(size=1) +
  #geom_errorbar(aes(ymax=measure_mean+measure_sd, ymin=measure_mean-measure_sd), width=.1, size = 1) +
  theme(legend.position="top") +
  facet_wrap(~ Subject)

sum_FDIdata %>%
  filter(Time == c("60")) %>%
  ggplot(aes(x = Intervention,  
             y = measure_med,
             group = Intensity,  
             color = Intensity)) +    
  geom_point(size = 3) + 
  geom_line(size=1) +
  #geom_errorbar(aes(ymax=measure_mean+measure_sd, ymin=measure_mean-measure_sd), width=.1, size = 1) +
  theme(legend.position="top") +
  facet_wrap(~ Subject)

sum_FDIdata %>%
  filter(Time == c("60")) %>%
  ggplot(aes(x = Intensity,  
             y = measure_med,
             group = Intervention,  
             color = Intervention)) +    
  geom_point(size = 3) + 
  geom_line(size=1) +
  #geom_errorbar(aes(ymax=measure_mean+measure_sd, ymin=measure_mean-measure_sd), width=.1, size = 1) +
  theme(legend.position="top") +
  facet_wrap(~ Subject)

sum_FDIdata %>%
  filter(Intervention == c("random")) %>%
  ggplot(aes(x = Intensity,  
             y = measure_med,
             group = Time,  
             color = Time)) +    
  geom_point(size = 3) + 
  geom_line(size=1) +
  scale_color_manual(values = c("Pre" = "black", "0" = "blue", "30" = "magenta", "60" = "red")) +
  #geom_errorbar(aes(ymax=measure_mean+measure_sd, ymin=measure_mean-measure_sd), width=.1, size = 1) +
  theme(legend.position="top") +
  facet_wrap(~ Subject)

sum_FDIdata %>%
  #filter(Intervention == c("random")) %>%
  ggplot(aes(x = Time,  
             y = measure_med,
             group = Intensity,  
             color = Intensity)) +    
  geom_point(size = 3) + 
  geom_line(size=1) +
  #geom_errorbar(aes(ymax=measure_mean+measure_sd, ymin=measure_mean-measure_sd), width=.1, size = 1) +
  theme(legend.position="top") +
  facet_wrap(~ Intervention)

sum_FDIdata %>%
  #filter(Intervention == c("negpos","posneg","negneg","random")) %>%
  ggplot(aes(x = Intensity,  
             y = measure_med,
             group = Time,  
             color = Time)) +    
  geom_point(size = 3) + 
  geom_line(size=1) +
  scale_color_manual(values = c("Pre" = "black", "0" = "blue", "30" = "magenta", "60" = "red")) +
  #geom_errorbar(aes(ymax=measure_mean+measure_sd, ymin=measure_mean-measure_sd), width=.1, size = 1) +
  theme(legend.position="top") +
  facet_wrap(~ Intervention)

sum_FDIdata %>%
  filter(Time == c("60")) %>%
  ggplot(aes(x = Intensity,  
             y = measure_med,
             group = Intervention,  
             color = Intervention)) +    
  geom_point(size = 3) + 
  geom_line(size=1) +
  #geom_errorbar(aes(ymax=measure_mean+measure_sd, ymin=measure_mean-measure_sd), width=.1, size = 1) +
  theme(legend.position="top") +
  facet_wrap(~ Time)

sum_FDIdata %>%
  filter(Time == c("60")) %>%
  ggplot(aes(x = Intervention,  
             y = measure_med,
             group = Intensity,  
             color = Intensity)) +    
  geom_point(size = 3) + 
  geom_line(size=1) +
  #geom_errorbar(aes(ymax=measure_mean+measure_sd, ymin=measure_mean-measure_sd), width=.1, size = 1) +
  theme(legend.position="top") +
  facet_wrap(~ Time)

subsum_FDIdata %>%
  ggplot(aes(x = Intensity,  
             y = sihi_mean,
             group = Intervention,  
             color = Intervention)) +    
  geom_point(size = 3) + 
  geom_line(size=1) +
  geom_errorbar(aes(ymax=sihi_mean+sihi_sd, ymin=sihi_mean-sihi_sd), width=.1, size = 1) +
  theme(legend.position="top")

subsum_FDIdata %>%
  ggplot(aes(x = Time,  
             y = sihi_mean,
             group = Intervention,  
             color = Intervention)) +    
  geom_point(size = 3) + 
  geom_line(size=1) +
  geom_errorbar(aes(ymax=sihi_mean+sihi_sd, ymin=sihi_mean-sihi_sd), width=.1, size = 1) +
  theme(legend.position="top")

slopes <- FDIdata %>%
  group_by(Subject, Intervention, Time) %>%
  summarize(slope = coef(lm(Response ~ Intensity))[2])

ggplot(subset(FDIdata,Subject=="sub-002"), aes(x = Intensity, y = Response)) +
  geom_point() +
  geom_abline(slope = coef(lm(Response ~ Intensity))[2]) +
  facet_wrap(~ Intervention + Time)

ggplot(slopes, aes(x = Time, y = slope, group = Intervention, colour = Intervention))+
  geom_point()+
  geom_line()+
  facet_wrap(~ Subject)

ggplot(slopes, aes(x = Time, y = slope, group = Subject, colour = Subject))+
  geom_point()+
  geom_line()+
  facet_wrap(~ Intervention)

ggplot(subset(FDIdata,Subject=="sub-016"), aes(x = Intensity, y = Response)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE) +
  facet_wrap(~ Intervention + Time)

ggplot(subset(FDIdata,Subject=="sub-016"), aes(x = Intensity, y = Response)) +
  geom_point() +
  geom_smooth(method = "loess", se = TRUE) +
  facet_wrap(~ Intervention + Time)

sum_slopes <- slopes %>%   
  group_by(Intervention, Time) %>%  
  summarize(measure_med = median(slope),
            measure_mean = mean(slope),
            measure_sd = sd(slope),
            measure_se = measure_sd/n(),
            n_samples = n()) %>%
  ungroup() 

sum_slopes %>%
  #filter(Intervention == c("negpos","posneg","negneg","random")) %>%
  ggplot(aes(x = Time,  
             y = measure_med,
             group = Intervention,  
             color = Intervention)) +    
  geom_point(size = 3) + 
  geom_line(size=1) +
  geom_errorbar(aes(ymax=measure_med+measure_sd, ymin=measure_med-measure_sd), width=.1, size = 1) +
  theme(legend.position="top")

sum_slopes %>%
  #filter(Intervention == c("negpos","posneg","negneg","random")) %>%
  ggplot(aes(x = Intervention,  
             y = measure_med,
             group = Time,  
             color = Time)) +    
  geom_point(size = 3) + 
  geom_line(size=1) +
  geom_errorbar(aes(ymax=measure_med+measure_sd, ymin=measure_med-measure_sd), width=.1, size = 1) +
  theme(legend.position="top")

xy.time <- xyplot(slope ~ Time, data = slopes, type = c("a", "p"), pch = 20,
                  group = Subject, xlab = "Time", ylab = "slope", lwd = 2)

xy.int <- xyplot(slope ~ Intervention, data = slopes, type = c("a", "p"), pch = 20,
                 group = Subject, xlab = "Intervention", ylab = "slope", lwd = 2)


qq.data <- qqmath(~ slope, data = slopes,
                  ylab = "slope",
                  prepanel = prepanel.qqmathline,
                  distribution = qnorm,
                  panel = function(x, ...) {
                    #panel.qqmathci(x, ...)
                    panel.qqmathline(x, ...)
                    panel.qqmath(x, ...)
                  })

hist.plot <- hist(slopes$slope, xlab = "slope")

grid.arrange(grobs = list(xy.time, xy.int, qq.data), hist.plot, ncol = 2, nrow = 2)

model <- lmerTest::lmer(slope ~ Intervention*Time + (1|Subject),
                         data = slopes, REML = T,
                         control = lmerControl(optCtrl = list(maxfun = 1e6)))
model <- lmerTest::lmer(slope ~ Intervention*Time + (1|Subject/Intervention),
                        data = slopes, REML = T,
                        control = lmerControl(optCtrl = list(maxfun = 1e6)))
anova_output <- anova(model) #f-values
anova_output
anova_pretty <- kable(anova_output, digits = 3)

model1 <- lme4::lmer(slope ~ Intervention*Time + (1|Subject),
                     data = slopes, REML = T,
                     control = lmerControl(optCtrl = list(maxfun = 1e6)))

model2 <- lme4::lmer(slope ~ Intervention*Time + (1|Subject/Intervention),
                     data = slopes, REML = T,
                     control = lmerControl(optCtrl = list(maxfun = 1e6)))

anova(model1,model2)

xy.time <- xyplot(Response ~ Time, data = FDIdata, type = c("a", "p"), pch = 20,
                  group = Subject, xlab = "Time", ylab = "Response", lwd = 2)

xy.int <- xyplot(Response ~ Intervention, data = FDIdata, type = c("a", "p"), pch = 20,
                 group = Subject, xlab = "Intervention", ylab = "Response", lwd = 2)

xy.intens <- xyplot(Response ~ Intensity, data = FDIdata, type = c("a", "p"), pch = 20,
                 group = Subject, xlab = "Intensity", ylab = "Response", lwd = 2)


qq.data <- qqmath(~ Response, data = FDIdata,
                  ylab = "Response",
                  prepanel = prepanel.qqmathline,
                  distribution = qnorm,
                  panel = function(x, ...) {
                    #panel.qqmathci(x, ...)
                    panel.qqmathline(x, ...)
                    panel.qqmath(x, ...)
                  })

hist.plot <- hist(FDIdata$Response, xlab = "Response")

grid.arrange(grobs = list(xy.time, xy.int, xy.intens, qq.data), ncol = 2, nrow = 2)

FDIdata$ResponseNorm <- sqrt(sqrt(FDIdata$Response))
FDIdata$ResponseNorm <- (FDIdata$ResponseNorm - mean(FDIdata$ResponseNorm))/sd(FDIdata$ResponseNorm)

xy.time <- xyplot(ResponseNorm ~ Time, data = FDIdata, type = c("a", "p"), pch = 20,
                  group = Subject, xlab = "Time", ylab = "Response", lwd = 2)

xy.int <- xyplot(ResponseNorm ~ Intervention, data = FDIdata, type = c("a", "p"), pch = 20,
                 group = Subject, xlab = "Intervention", ylab = "Response", lwd = 2)

xy.intens <- xyplot(ResponseNorm ~ Intensity, data = FDIdata, type = c("a", "p"), pch = 20,
                    group = Subject, xlab = "Intensity", ylab = "Response", lwd = 2)


qq.data <- qqmath(~ ResponseNorm, data = FDIdata,
                  ylab = "Response",
                  prepanel = prepanel.qqmathline,
                  distribution = qnorm,
                  panel = function(x, ...) {
                    #panel.qqmathci(x, ...)
                    panel.qqmathline(x, ...)
                    panel.qqmath(x, ...)
                  })

hist.plot <- hist(FDIdata$ResponseNorm, xlab = "Response")

grid.arrange(grobs = list(xy.time, xy.int, xy.intens, qq.data), ncol = 2, nrow = 2)

model1 <- lme4::lmer(ResponseNorm ~ Intervention*Time*Intensity + (1|Subject),
                     data = FDIdata, REML = F,
                     control = lmerControl(optCtrl = list(maxfun = 1e6)))

model3 <- lme4::lmer(ResponseNorm ~ Intervention*Time*Intensity + (1|Subject/Intervention),
                     data = FDIdata, REML = F,
                     control = lmerControl(optCtrl = list(maxfun = 1e6)))


anova(model1,model3)

model <- lmerTest::lmer(ResponseNorm ~ Intervention*Time*Intensity + (1|Subject),
                     data = FDIdata, REML = T,
                     control = lmerControl(optCtrl = list(maxfun = 1e6)))
car::Anova(model)

model1 <- lme4::lmer(Response ~ Intervention + Time + Intensity + Intervention:Time:Intensity + (1|Subject),
                     data = FDIdata, REML = F,
                     control = lmerControl(optCtrl = list(maxfun = 1e6)))

model3 <- lme4::lmer(Response ~ Intervention + Time + Intensity + Intervention:Time:Intensity + (1|Subject/Intervention),
                     data = FDIdata, REML = F,
                     control = lmerControl(optCtrl = list(maxfun = 1e6)))


anova(model1,model3)

model <- lmerTest::lmer(ResponseNorm ~ Intervention + Intensity
                        + Time:Intensity + (1|Subject/Intervention),
                        data = FDIdata, REML = T,
                        control = lmerControl(optCtrl = list(maxfun = 1e6)))
anova(model)
check_collinearity(model)
check_model(model)
