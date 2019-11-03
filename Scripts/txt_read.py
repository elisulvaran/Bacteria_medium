import argparse
import os

parser=argparse.ArgumentParser\
    (description='Este script genera los datos de entrenamiento y de prueba')


parser.add_argument('--path', dest='myPath', required=True, help='Ingrese la ruta del directorio de entrada.')
#parser.add_argument('--outputpath', dest='outputPath', required=True,help='Ingrese la ruta del archivo de salida junto con su nombre y extension.')
args=parser.parse_args

for path,dirs,files,in os.walk(args.myPath):
	print(dirs)