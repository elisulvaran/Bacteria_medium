#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import re
import os 
import argparse as arg


# In[ ]:


parser=arg.ArgumentParser(description="Programa para obtener oraciones que contengan unidades de concentración")
parser.add_argument('-p', dest='path', type=str, metavar='path', 
                    help="Path of carpet with files")
parser.add_argument('-d', dest='dicty', type=str, metavar='dict', 
                    help="Path of file with concentrations")
parser.add_argument('-o', dest='out', type=str, metavar='out', 
                    help="Output path")
arg=parser.parse_args()


# In[ ]:


print("-p ../Bacteria -d ../dict.txt -o ../Bacteria_Concentrations")


# In[ ]:


path=arg.path
dicty=arg.dicty
out=arg.out


# In[ ]:


files=[]
for i in os.listdir(path):
    if i.endswith('.txt'):
    	if i.startswith('Association_Medium_'):
        	files.append(i)
        	print(i)


with open(dicty) as dicty:
    dicty=dicty.readlines()
    dicty=[x.replace('\n', '').replace(' ', '') for x in dicty]


# In[ ]:


for file in files:
    sents=[]
    as_con=[]
    with open(os.path.join(path,file), encoding="utf8") as ifile:
        for line in ifile:
            sents.append(line.split(" "))
    
    for sent in sents:
        for word in sent:
            for i in dicty:
                if (i == word):
                    if sent not in as_con:
                        as_con.append(sent)



      
    with open(os.path.join(out,"Association_Concentration_"+file.strip('Association_Medium_')+"t"), mode="w") as oFile:
        for sent in as_con:
            for word in sent:
                oFile.write("{} ".format(word))

