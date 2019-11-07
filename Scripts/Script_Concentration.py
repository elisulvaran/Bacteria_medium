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
out=out.dicty


# In[ ]:


files=[]
for i in os.listdir(path):
    if i.endswith('.txt'):
        files.append(i)
        print(i)


# In[ ]:


for i in files:
    sents=[]
    as_con=[]
    with open(os.path.join(path,i), encoding="utf8") as file:
        for line in file:
            sents.append(line.split(" "))
    
    for sent in sents:
        for word in sent:
            for i in dicty:
                if (i == word):
                    if sent not in as_con:
                        as_con.append(sent)
        
    with open(os.path.join(out,"Association_Concentration_"+file), mode="w") as oFile:
        for sent in as_con:
            for word in sent:
                oFile.write("{} ".format(word))
            oFile.write("\n")

