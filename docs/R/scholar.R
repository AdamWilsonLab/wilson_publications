library(scholar)
library(jsonlite)
library(stringdist)
library(stringr)
library(tidyjson)
#library(jsonview)

## Download google scholar citations
id="zgVlijsAAAAJ"
pubs=get_publications(id)
pubs$title=as.character(pubs$title)

## Download impactstory information
download.file("https://impactstory.org/api/person/0000-0003-3362-7806.json",
              destfile = "is.json")

#is=fromJSON("_data/is.json")
#is=attr(read_json("_data/is.json"),which="JSON")[[1]]
#is=read_json("_data/is.json")
is=read_json("is.json",format='json')$..JSON[[1]]
#is=attr(read_json("_data/is.json",format='json'),which="..JSON")[[1]]

#json_tree_view(is)

  ## Get fuzzy string matches
dm=stringdistmatrix(sapply(is$products,function(x) x[["title"]]),
                    pubs$title)
dm_min=apply(dm,
             1,
             min)

dm2=apply(dm,
          1,
          which.min)

dm2[dm_min>15]=NA

if(F){
for(i in 1:length(is$products)){
  writeLines(paste(i,":    ",dm_min[i]))
  writeLines(pubs$title[dm2][i])
  writeLines(is$products[[i]]$title)
}
}

  for(i in 1:length(is$products)){
    is$products[[i]]$citations=ifelse(is.na(pubs$cites[dm2][i]),
                                      0,pubs$cites[dm2][i])
    is$products[[i]]$citationlink=as.character(pubs$cid[dm2])[i]
    for(l in 1:length(is$products[[i]]$posts)){
      is$products[[i]]$posts[l]$title=NULL}
    }


#remove problematic parts of pubs list
is$badges=NULL
is$overview_badges=NULL

#is$products$citations=pubs$cites[dm2]
#is$products$citationlink=as.character(pubs$cid[dm2])

# clean up double quotes in title fields
#lapply(is$products$posts,function(x) 

# clean up json
is_out=toJSON(is,auto_unbox=T,pretty=T)
is_out=enc2native(is_out)
is_out=iconv(is_out, "us-ascii", "us-ascii",sub="")
#is_out=gsub("[\\]","",is_out)
#is_out=gsub("href=\"","href='",is_out)
#is_out=gsub("\"\"","",is_out)
#is_out=gsub("\">","'>",is_out)

if(!validate(is_out)) stop("JSON is not valid")

## write the file
write(is_out,
    file="pubs.json")
file.remove("is.json")

