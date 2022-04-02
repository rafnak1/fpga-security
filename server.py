import paho.mqtt.client as mqtt
import time

user = "grupo2-bancadaA2"
passwd = "L@Bdygy2A2"

Broker = "labdigi.wiseful.com.br"
Port = 80
KeepAlive = 60

# tópicos temporários!
var2topic = {
    # 7 entradas
    'com0'   : 'S0',
    'com1'   : 'S1',
    'com2'   : 'S2',
    'com3'   : 'S3',
    'trig'   : 'S4',
    'alarme' : 'S5',
    'abriu'  : 'S6',
    # 8 saídas
    'BDnormal0' : 'E0'
}


def on_connect(client, userdata, flags, rc):
    global in_var2topic
    print("Conectado com codigo " + str(rc))
    client.subscribe(user+"/asdf", qos=0)
    for topic in in_var2topic.values:
        client.subscribe(user+"/"+topic, qos=0)

def on_message(client, userdata, msg):
    global in_var2topic, user
    print(msg.topic+" "+str(msg.payload))

    com = [False for i in range(4)]
    if msg.topic = user+"/S0":
        com[0] = msg.payload == b'1'
    if msg.topic = user+"/S1":
        com[1] = msg.payload == b'1'
    if msg.topic = user+"/S2":
        com[2] = msg.payload == b'1'
    if msg.topic = user+"/S3":
        com[3] = msg.payload == b'1'

    # Sinais internos
    ID = 0
    BDn = [[False for j in range(4)] for i in range(16)]
    BDp = [[False for j in range(4)] for i in range(16)]
    sizeN = [0 for _ in range(16)]
    sizeP = [0 for _ in range(16)]

    if msg.topic == user+"/trig" and msg.payload == '1':
        ID = sum([com[i]*2**i for i in range(3, -1, -1)])
        publish4()


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

