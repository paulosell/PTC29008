from coapc import coap
import response
import poller


cl = coap("::1")
#r = cl.do_get(coap.CON, 'other', 'separate')
r = cl.do_post(coap.CON, 1 ,'other','separate')
print("Tipo:", r.getType())
print("Code:", r.getCode())
print("Message ID:", int.from_bytes(r.getMid(), 'big'))
print("Token:", int.from_bytes(r.getToken(), 'big'))
print("Payload:", r.getPayload().decode('utf-8'))
