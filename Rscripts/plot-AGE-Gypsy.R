library(ggplot2)
aa=read.table("./AGE-Gypsy.txt")

aap=ggplot(aa,aes(V2))+geom_histogram(aes(V2, ..density..),binwidth = 100000, color = "#faf5f5", fill = "#288BA8") + 
geom_vline(aes(xintercept=mean(V2)), col = "black", size=0.5)+
geom_vline(aes(xintercept=median(V2)), col = "black",linetype="dashed", size=0.3)+
geom_density (linetype="dashed", alpha=.4, fill="#288BA8")+xlim(0,NA)+theme_light()+
labs(title="LTR Gypsy insertion time",x="Mya", y = "Number of Elements", alpha=.6, hjust = 0.5)

pdf(file="AGE-Gypsy.pdf",width=5,height=3)
aap
dev.off()



