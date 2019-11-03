import argparse
import os
import re



#def funcion_busqueda(mystr):
#	mystr=re.split('\. [A-Z]',mystr)




if __name__ == '__main__':
	parser=argparse.ArgumentParser\
	    (description='Este script genera los datos de entrenamiento y de prueba')
	 
	
	parser.add_argument('--path', dest='myPath', required=True, help='Ingrese la ruta del directorio de entrada.')
	parser.add_argument('--outputpath', dest='outputPath', required=True,help='Ingrese la ruta del archivo de salida junto con su nombre y extension.')
	args=parser.parse_args()


	lista=[]
	for path,dirs,files in os.walk(args.myPath):
		for file in files:
			if file.endswith(".txt"):
				with open(os.path.join(path,file),mode='r') as iFile:
					lines=iFile.readlines()
					mystr=' '.join([line.strip() for line in lines])
					#lista.append(mystr)

	#mystr=re.split('\. [A-Z]',mystr)
	#print(len(mystr))

	
	with open(os.path.join(args.outputPath,"Gelria.txt"), mode="w") as oFile:
		oFile.write("{}".format(mystr))


















