file=open("/Users/elisulvaran/Desktop/Chemical_compounds.txt",'r')


lines=file.readlines()
string=' '.join([line.strip() for line in lines])
tokens=string.split(' ')

lista=[]
for token in tokens:
	if token not in lista:
		lista.append(token)

ofile=open("/Users/elisulvaran/Desktop/dictionary.txt",'w')
for i in lista:
	ofile.write("{}\n".format(i))

file.close()
ofile.close()