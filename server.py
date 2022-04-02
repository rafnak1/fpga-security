# Nota: aqui, vetores de bits são representados da seguinte maneira:
# [True, False, True, False] convertido para inteiro unsigned ficaria
# 10, não 5.

import paho.mqtt.client as mqtt
import time

user = "grupo2-bancadaA2"

#passwd = "L@Bdygy2A2"
passwd = ""

#Broker = "labdigi.wiseful.com.br"
#Port = 80
Broker = "test.mosquitto.org"
Port = 1883

KeepAlive = 60

DELAY = 1.1

# 7 entradas
in_var2topic = {
    "com0"   : "S0",
    "com1"   : "S1",
    "com2"   : "S2",
    "com3"   : "S3",
    "trig"   : "S4",
    "alarme" : "S5",
    "abriu"  : "S6"}

# 8 saídas
out_var2topic = {
    "BDnormal0" : "E0",
    "BDnormal1" : "E1",
    "BDnormal2" : "E2",
    "BDnormal3" : "E3",
    "BDpanico0" : "E4",
    "BDpanico1" : "E5",
    "BDpanico2" : "E6",
    "BDpanico3" : "E7"}


# Dados das senhas
BDn = [[ True, False, False, False], # Matrix 16x4 bits
       [False, True , False, False],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],]

BDp = [[False, False,  True, False], # Matrix 16x4 bits
       [False, False, False,  True],
       [False, False, False,  True],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],
       [False, False, False, False],]

sizeN = sum([any(d) for d in BDn])
sizeP = sum([any(d) for d in BDp])


# variáveis globais
com = [False for i in range(4)]
trigger = False


# 10 -> [True, False, True, False]
def int2bin(n):
    r = []
    for p in [8, 4, 2, 1]:
        r.append(bool(n // p))
        n %= p
    return r

def on_connect(client, userdata, flags, rc):
    global in_var2topic

    print("Conectado com codigo " + str(rc))

    client.subscribe(user+"/asdf", qos=0)  # Teste de conexão

    for topic in in_var2topic.values():
        client.subscribe(user+"/"+topic, qos=0)


def on_message(client, userdata, msg):
    global in_var2topic, out_var2topic, user, com, BDn, BDp, sizeN, sizeP, DELAY, trigger

    print(msg.topic+" "+str(msg.payload))

    for s,i in zip(["0","1","2","3"], [3,2,1,0]):
        if msg.topic == user+"/"+in_var2topic["com"+s]: com[i] = msg.payload == b'1'

    if (msg.topic == user+"/"+in_var2topic['trig']) and (msg.payload == b'1'):
        trigger = True


client = mqtt.Client(protocol=mqtt.MQTTv31)
client.on_connect = on_connect
client.on_message = on_message

client.username_pw_set(user, passwd)

client.connect(Broker, Port, KeepAlive)
client.loop_start()

# Primeiro publish é geralmente ignorado
client.publish(user + "/asdf", payload="1", qos=0, retain=False)

print("Servidor iniciou")

while True:
    time.sleep(.05)
    if trigger == True:
        ID = sum([com[i]*2**(3-i) for i in range(4)])
        print("ID = "+str(ID))

        print("publicando 1")

        out = int2bin(sizeN - 1)
        for s, i in zip(["0","1","2","3"], [3,2,1,0]):
            client.publish(user+"/"+out_var2topic["BDnormal"+s], payload=str(int(out[i])), qos=0, retain=False)

        out = int2bin(sizeP - 1)
        for s, i in zip(["0","1","2","3"], [3,2,1,0]):
            client.publish(user+"/"+out_var2topic["BDpanico"+s], payload=str(int(out[i])), qos=0, retain=False)

        time.sleep(DELAY)

        for i_d in range( max(sizeN, sizeP) ):

            print("publicando 2")

            out = BDn[i_d]
            for s, i in zip(["0","1","2","3"], [3,2,1,0]):
                client.publish(user+"/"+out_var2topic["BDnormal"+s], payload=str(int(out[i])), qos=0, retain=False)

            out = BDp[i_d]
            for s, i in zip(["0","1","2","3"], [3,2,1,0]):
                client.publish(user+"/"+out_var2topic["BDpanico"+s], payload=str(int(out[i])), qos=0, retain=False)

            time.sleep(DELAY)

        # Limpa os canais
    #        for s in zip(["0","1","2","3"]):
    #            client.publish(user+"/"+out_var2topic["BDnormal"+s], payload="0", qos=0, retain=False)
    #
    #        for s in zip(["0","1","2","3"]):
    #            client.publish(user+"/"+out_var2topic["BDpanico"+s], payload="0", qos=0, retain=False)
        
        trigger = False
        print("fim do procedimento")

