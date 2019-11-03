import argparse
import os
import re


def funcion_busqueda(mystr,comp_dict):
	paper=[]
	string=re.split('\. [A-Z]',mystr)
	for i in string:
		sentence=i.split(" ")
		paper.append(sentence)

	asociaciones=[]
	for word in comp_dict:
		for sentence in paper:
			for token in sentence:
				if(word==token):
					if sentence not in asociaciones:
						asociaciones.append(sentence)


	with open(os.path.join(args.outputPath,"Association_"+file), mode="w") as oFile:
		for oracion in asociaciones:
			for palabra in oracion:
				oFile.write("{} ".format(palabra))
			oFile.write("\n")


	




if __name__ == '__main__':
	parser=argparse.ArgumentParser\
	    (description='Este script genera los datos de entrenamiento y de prueba')
	 
	
	parser.add_argument('--path', dest='myPath', required=True, help='Ingrese la ruta del directorio de entrada.')
	parser.add_argument('--outputpath', dest='outputPath', required=True,help='Ingrese la ruta del archivo de salida junto con su nombre y extension.')
	parser.add_argument('--dict',dest='dictionary',required=True,help='Ingrese la ruta del diccionario.')
	args=parser.parse_args()

	with open(args.dictionary) as Dict:
		comp_dict=Dict.readlines()
		comp_dict=[x.replace('\n', '').replace(' ', '') for x in comp_dict]


	lista=[]
	for path,dirs,files in os.walk(args.myPath):
		for file in files:
			if file.endswith(".txt"):
				with open(os.path.join(path,file),mode='r') as iFile:
					lines=iFile.readlines()
					mystr=' '.join([line.strip() for line in lines])
					funcion_busqueda(mystr,comp_dict)






	


















