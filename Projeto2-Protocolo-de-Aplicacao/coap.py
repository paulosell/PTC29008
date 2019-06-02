import coapc
import response
import poller


cl = coapc.COAP("::1")
r = cl.do_get("time")
print("Tipo:", r.getType())
print("Code:", r.getCode())
print("Message ID:", int.from_bytes(r.getMid(), 'big'))
print("Token:", int.from_bytes(r.getToken(), 'big'))
print("Payload:", r.getPayload().decode('utf-8'))
