# Developing on the mosquitto online broker
import paho.mqtt.client as mqtt
import time

user = ""
passwd = ""

Broker = "test.mosquitto.org"
Port = 1883
KeepAlive = 60


def on_connect(client, userdata, flags, rc):
    print("Conectado com codigo " + str(rc))
    client.subscribe("parafernalia1", qos=0)
    client.subscribe("parafernalia2", qos=0)

def on_message(client, userdata, msg):
    print(msg.topic+" "+str(msg.payload))


client = mqtt.Client(protocol=mqtt.MQTTv31)
client.on_connect = on_connect
client.on_message = on_message

client.username_pw_set(user, passwd)

client.connect(Broker, Port, KeepAlive)
client.loop_start()

# Primeiro publish é geralmente ignorado
client.publish(user + "/asdf", payload="1", qos=0, retain=False)

print("Servidor iniciou")
while (True):
    pass

client.loop_stop()
client.disconnect()

print("done")
