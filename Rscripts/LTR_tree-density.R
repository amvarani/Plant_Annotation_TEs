#!/bin/env Rscript
args = commandArgs(T)
treefile = args[1]
mapfile = args[2]
dataplot = args[3]
dataplot2 = args[4]
outfig = args[5]
if (is.na(outfig)) {outfig = paste0(treefile, '.pdf')}

branch_color = 'Clade'
library(ape)
library(phangorn)
library(ggplot2)
library(ggtree)
library(treeio)
library(svglite)
library(phytools)
library(ggtreeExtra)
library(dplyr)
library(ggnewscale)
library(ggrepel)
#library(caret)

dplot = read.table(dataplot, sep="\t")
dplot2 = read.table(dataplot2, sep="\t")
map = read.table(mapfile, head=T, fill=T, comment.char='!', sep="\t")
ring <- dplot
ring2 <- dplot2
tree <- midpoint(read.tree(file = treefile))


min_max_norm <- function(x) {
    (x - min(x)) / (max(x) - min(x))
  }







split_id <- function(x) {
	x = strsplit(x, '#')[[1]][1]
	return(x)
}
format_id <- function(x1, x2, x3, x4) {
	x1 = sapply(x1, split_id)	
	x1 = gsub('\\W+', '_', x1)
	x = paste(x1, x2, x3, x4, sep='_')
	return(x)
}


if (branch_color == 'Clade') {
	clades = sort(unique(map$Clade))
	head(tree)
	tree$tip.label = gsub('\\W+', '_', tree$tip.label)
	#print(clades)
	grp = list()
	for (clade in clades){
			if (clade=='unknown') { next }
			labels = map[which(map$Clade==clade), ]
			clade = paste(labels$Superfamily, labels$Clade, sep='/')[1]
			labels = format_id(labels$X.TE, labels$Order, labels$Superfamily, labels$Clade)
			if (! any(labels %in% tree$tip.label)) {next}
			#print(clade)
			grp[[clade]] = labels
	}
	clades = sort(names(grp))
	tree3 = groupOTU(tree, grp, 'Clade') 

	p = ggtree(tree3 , aes(color=Clade) , branch.length='none',  layout='circular' ) + geom_rootedge(rootedge = 3) + geom_rootpoint() + geom_tiplab(size=1) + 

      geom_fruit(
          data=ring,
          geom=geom_col,
          mapping=aes(y=V1, x=min_max_norm(V2)),
          fill="#fb011a",
          alpha=0.8,
          color="#8e8b8b",
          size=0.1,
          offset=0.45,
          axis.params=list(
          axis       = "x",
          text.size  = 1,
          hjust      = 1,
          vjust      = 1.5,
          nbreak     = 3,
          ),
          grid.params=list()
      ) +  new_scale_fill() +
      
 
      geom_fruit(
          data=ring2,
          geom=geom_col,
          mapping=aes(y=V1, x=min_max_norm(V2)),
          fill="#7801fb",
          alpha=0.8,
          color="#8e8b8b",
          size=0.1,
          offset=0.05,
          axis.params=list(
          axis       = "x",
          text.size  = 1,
          hjust      = 1,
          vjust      = 1.5,
          nbreak     = 3,
          ),
          grid.params=list()
      ) + 
      


	
	  theme(legend.position="right")  +
	  scale_fill_manual(values=c('#f9c00c','#00b9f1','#7200da','#f9320c','#980000','#00ffff','#0000ff','#ff0000','#4a86e8','#ff9900','#ffff00','#00ff00','#9900ff','#ff00ff','#20124d','#274e13','#000000','#cccccc','#7f6000','#a64d79','#6aa84f','#fff2cc','#47a952','#3ea6b6','#a5b805','#8f9276','#ca8d7c')) + scale_colour_discrete(limits=clades, labels=clades) +
	  guides(colour=guide_legend(order = 1), fill=guide_legend(order = 2))

} else {	# branch_color == 'Taxon'
	taxa = sort(unique(map$Taxon))
	grp = list()
	for (taxon in taxa){
			labels = map[which(map$Taxon==taxon), ]
			labels = labels$label
			grp[[taxon]] = labels
	}
	tree3 = groupOTU(tree, grp, 'Taxon')
	map3 = data.frame(label=map$label, Clade=map$Clade)
	p = ggtree(tree3 , aes(color=Taxon) , branch.length='none', layout='circular' ) %<+% map3 + geom_rootpoint() +  geom_tiplab(size=1) + 


      geom_fruit(
          data=ring,
          geom=geom_col,
          mapping=aes(y=V1, x=V2),
          fill="#f99b7f", 
          axis.params=list(
          axis       = "x",
          text.size  = 1,
          hjust      = 1,
          vjust      = 1.5,
          nbreak     = 3,
          ),
          grid.params=list()
      ) +  new_scale_fill() +
      
 
      geom_fruit(
          data=ring2,
          geom=geom_col,
          mapping=aes(y=V1, x=V2),
          fill="#f9d87f", 
          axis.params=list(
          axis       = "x",
          text.size  = 1,
          hjust      = 1,
          vjust      = 1.0,
          nbreak     = 3,
          ),
          grid.params=list()
      ) + 
      



	
	  theme(legend.position="right")  + 
	  scale_colour_manual(values=c('#f9c00c','#00b9f1','#7200da','#f9320c','#980000','#00ffff','#0000ff','#ff0000','#4a86e8','#ff9900','#ffff00','#00ff00','#9900ff','#ff00ff','#20124d','#274e13','#000000','#cccccc','#7f6000','#a64d79','#6aa84f','#fff2cc','#47a952','#3ea6b6','#a5b805','#8f9276','#ca8d7c'),limits=taxa, labels=taxa) +
	  geom_tippoint(aes(fill=Clade), pch=21, stroke=0, size=1.2, color='#00000000') +
	  scale_fill_hue(l=35) +
	  guides(colour=guide_legend(order = 1), fill=guide_legend(order = 2))

}
position = c(1.35,0.9)
p = p + theme(plot.margin=margin(0,0,0,0)) +
	theme(legend.position=position, legend.justification=position) +
	theme(legend.background=element_blank(), legend.key=element_blank()) +
	theme(legend.text=element_text(size=12), legend.title=element_text(size=14))


ggsave(outfig, p, width=13.5, height=8.4, dpi=300, units="in")
