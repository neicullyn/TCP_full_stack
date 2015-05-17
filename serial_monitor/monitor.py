import serial
ser = serial.Serial(6)
print ser.name
ser.close()
