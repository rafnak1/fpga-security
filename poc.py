# Proof of concept da biblioteca paho-mqtt

import paho.mqtt.client as mqtt
import time

user = "grupo2-bancadaA2"
passwd = "L@Bdygy2A2"

Broker = "labdigi.wiseful.com.br"
Port = 80
KeepAlive = 60

def on_connect(client, userdata, flags, rc):
    print("Conectado com codigo " + str(rc))
    client.subscribe(user+"/asdf", qos=0)

def on_message(client, userdata, msg):
    print(msg.topic+" "+str(msg.payload))


client = mqtt.Client(protocol=mqtt.MQTTv31)
client.on_connect = on_connect
client.on_message = on_message

client.username_pw_set(user, passwd)

client.connect(Broker, Port, KeepAlive)
client.loop_start()

# Teste de publish
print("publicando")
# Primeiro publish é geralmente ignorado
client.publish(user + "/asdf", payload="1", qos=0, retain=False)
client.publish(user + "/asdf", payload="1", qos=0, retain=False)

# Teste de percepção de mudanças no tópico
print("listening...")
time.sleep(10)

client.loop_stop()
client.disconnect()

print("done")
