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