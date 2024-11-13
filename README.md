[![Open in Codespaces](https://classroom.github.com/assets/launch-codespace-2972f46106e565e64193e422d61a12cf1da4916b45550586e14ef0a7c637dd04.svg)](https://classroom.github.com/open-in-codespaces?assignment_repo_id=16814396)
# SESION DE LABORATORIO N° 05: Ingesta de datos mediante AWS Kinesis Data Firehose

### Nombre: ALBERT KENYI APAZA CCALLE
### msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
### TERRAFORM https://developer.hashicorp.com/terraform/install
## OBJETIVOS
  * Desarrolla una solución de inteligencia de negocios de ingesta de datos para un datalake.

## REQUERIMIENTOS
  * Conocimientos: 
    - Bash o Powershell.
    - AWS CLI.
  * Hardware:
    - Virtualization activada en el BIOS.
    - CPU SLAT-capable feature.
    - Al menos 4GB de RAM.
  * Software:
    - Docker Desktop 
    - AWS CLI 2.x.x
    - Python 3.10 o superior
## CONSIDERACIONES INICIALES
  * Obtener y copiar los valores de acceso a nube (CLOUD ACCESS - AWS CLI) ubicados en el curso de LEARNER LAB de AWS Academy
    ```
    [default]
    aws_access_key_id=.....
    aws_secret_access_key=....
    aws_session_token=......
    ```
  * Clonar el repositorio mediante git para tener los recursos necesarios en una ubicación que no sea del sistema.
  * Colocar su nombre en el archivo
  * La arquitectura a desarrollar es la siguiente:
    
![image](https://github.com/user-attachments/assets/22c6bdbc-a74d-48d6-a643-622fba062bc2)

Para este flujo near real time, leeremos un dataset descargado de Kaggle. Este conjunto de datos contiene las lecturas de temperatura de los dispositivos IOT instalados fuera y dentro de una sala. https://www.kaggle.com/atulanandjha/temperature-readings-iot-devices
    
## DESARROLLO

1. Iniciar la aplicación Powershell o Windows Terminal en modo administrador
2. En el terminal, ejecutar el siguiente comando para crear la carpeta y archivos de conexion a AWS
```Powershell
md $env:USERPROFILE\.aws
New-Item -Path $env:USERPROFILE\.aws -Name credentials -ItemType File
New-Item -Path $env:USERPROFILE\.aws -Name config -ItemType File
```
3. En el terminal, ejecutar el siguiente comando para editar el archivo de credenciales.
```Powershell
notepad $env:USERPROFILE\.aws\credentials
```
> Pegar los valores previamente obtenidos CLOUD ACCESS - AWS CLI y guardar los cambios en el archivos
4. En el terminal, ejecutar el siguiente comando para editar el archivo de configuracion.
```Powershell
notepad $env:USERPROFILE\.aws\config
```
> Pegar el siguiente contenido y guardar los cambios.
```
[default]
region=us-east-1
output = json
```
5. Cerrar y volver a abrir el terminal de Powershell
6. En el terminal, ejecutar el siguinete comando para crear un bucket en S3 en AWS.
```Bash
aws s3api create-bucket --bucket aws-iot-sensor-albertapazaccallee --region us-east-1 --create-bucket-configuration LocationConstraint=us-east-1
```
> Donde: [iniciales]: son las iniciales de su nombre
7. En el terminal, para verificar la creación del bucket ejecutar el siguiente comando:
```Bash
aws s3 ls
```
8. En el terminal, proceder a ejecutar el siguiente comando, para obtener el rol de usuario que se utilizara para la comunicación entre los servicios S3 y Data Firehose
```Bash
aws iam get-role --role-name LabRole
```
> El resultado debera ser similar al siguiente, buscar y anotar el valor de "arn:aws:iam::183789758787:role/LabRole"
```JSon
"Role": {
        "Path": "/",
        "RoleName": "LabRole",
        "RoleId": "AROAXLLHDI25QPA6H2SBJ",
        "Arn": "arn:aws:iam::505411749563:role/LabRole",
        "CreateDate": "2024-06-15T16:23:03+00:00",
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "AWS": "arn:aws:iam::[numero_identificacion]:role/LabRole",
                        "Service": [
                            "logs.amazonaws.com",
```
9. En el Terminal, ejecutar el siguiente comando para crear el servicio de Kinesis DataFireHose.
```Bash
aws s3api create-bucket --bucket aws-iot-sensor-albertapazaccallee --region us-east-1
```
> Donde: [iniciales]: son las iniciales de su nombre
>        [numero_identificacion]: es el numero de identificación obtenido en el paso previo
10. En el Terminal, ejecutar el siguiente comando para instalar las dependencias de python.
```Bash
python -m pip install urllib3
python -m pip install boto3
python -m pip install pandas
```
11. Abrir Visual Studio Code, apuntando a la carpeta clonada del laboratorio o utilizacion la sentencia ```code .```
12. En el VS Code, crear el archivo FirehoseWriteIoTSensors.py, con el siguiente contenido.
```Python
import boto3
import time
import json
import pandas as pd

DeliveryStreamName = 'StreamSensorIoT'
firehose = boto3.client('firehose')

record = {}
df = pd.read_csv("IOT-temp.csv")

for index, row in df.iterrows():
	record = {
	'id': row['id'],
	'room_id': row['room_id'],
	'noted_date' :  row['noted_date'],
	'temp' : row['temp'],
	'out_in' : row['out_in'] 
	}

	response = firehose.put_record(
		DeliveryStreamName = DeliveryStreamName,
		Record = {
			'Data': json.dumps(record)
		}
	)
	print('Dato de sensor enviado a Kinesis Data Firehose : \n' + str(record))
	time.sleep(.5)
```
14. En el Terminal, proceder a ejecutar el archivo python creado con el siguiente comando:
```Bash
python .\FirehoseWriteIoTSensors.py
```
> El resultado se visualizará similar al siguiente:
```Bash
Dato de sensor enviado a Kinesis Data Firehose :
{'id': '__export__.temp_log_196134_bd201015', 'room_id': 'Room Admin', 'noted_date': '08-12-2018 09:30', 'temp': 29, 'out_in': 'In'}
Dato de sensor enviado a Kinesis Data Firehose :
{'id': '__export__.temp_log_196131_7bca51bc', 'room_id': 'Room Admin', 'noted_date': '08-12-2018 09:30', 'temp': 29, 'out_in': 'In'}
Dato de sensor enviado a Kinesis Data Firehose :
{'id': '__export__.temp_log_196127_522915e3', 'room_id': 'Room Admin', 'noted_date': '08-12-2018 09:29', 'temp': 41, 'out_in': 'Out'}
Dato de sensor enviado a Kinesis Data Firehose :
{'id': '__export__.temp_log_196128_be0919cf', 'room_id': 'Room Admin', 'noted_date': '08-12-2018 09:29', 'temp': 41, 'out_in': 'Out'}
Dato de sensor enviado a Kinesis Data Firehose :
{'id': '__export__.temp_log_196126_d30b72fb', 'room_id': 'Room Admin', 'noted_date': '08-12-2018 09:29', 'temp': 31, 'out_in': 'In'}
Dato de sensor enviado a Kinesis Data Firehose :
{'id': '__export__.temp_log_196125_b0fa0b41', 'room_id': 'Room Admin', 'noted_date': '08-12-2018 09:29', 'temp': 31, 'out_in': 'In'}
```
15. En el Terminal, esperar unos 10 minutos, cancelar el comando anterior y ejecutar el siguiente comando para visualizar los resultados
```Bash
aws s3 ls s3://aws-iot-sensor-albertapazaccallee --recursive
```
> El resultado se presentara similar al siguiente:
```
2024-10-26 10:20:20      11642 2024/10/26/15/StreamSensorIoT-1-2024-10-26-15-19-19-4c63cc9b-99cf-4dd8-a09f-dd670d08a26f
2024-10-26 10:21:21      12706 2024/10/26/15/StreamSensorIoT-1-2024-10-26-15-20-15-b44f1c25-7009-48af-90b6-50768279a525
2024-10-26 10:22:22      12568 2024/10/26/15/StreamSensorIoT-1-2024-10-26-15-21-16-a55b07b1-630f-4f57-87f3-e8ebfced4d42
2024-10-26 10:23:22      12578 2024/10/26/15/StreamSensorIoT-1-2024-10-26-15-22-16-c085d0a1-910c-47eb-8c72-0a96661ddb9d
2024-10-26 10:24:22      12586 2024/10/26/15/StreamSensorIoT-1-2024-10-26-15-23-17-850f78b3-c8e5-4311-abcc-88e2c3e71130
```
16. En el Terminal, guardar y subir todos los cambios y evidencias, y proceder a eliminar los recursos utilizados con el siguiente comando.
```Bash
aws firehose delete-delivery-stream --delivery-stream-name StreamSensorIoT
aws s3 rm s3://aws-iot-sensor-albertapazaccallee --recursive
aws s3 rb s3://aws-iot-sensor-albertapazaccallee
``` 

## ACTIVIDAD
1. Editar este archivo y colocar sus iniciales en donde corresponda y el numero de identificacion del rol.
2. Crear una carpeta infra, y dentro de esta crear uno o varios scripts Terraform para realizar la creación del servicio S3 Bucket y Data FireHose, con las mismas caracteristicas de los servicios creados en el laboratorio.
