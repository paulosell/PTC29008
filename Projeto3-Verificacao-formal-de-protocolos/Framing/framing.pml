mtype = {flag, esc, comum}
chan serial = [1] of {mtype}
 
active proctype TX() {
  int bytes
 

  serial!flag;
  serial!comum;
  serial!esc; serial!comum;
  serial!comum;
  serial!comum;
  serial!comum;
  serial!esc; serial!comum;
  serial!flag 
  serial!comum;
  serial!comum;
  serial!comum;
  serial!flag ;

}


active proctype RX(){
    int bytes
    mtype msg;

ocioso:
    do
     :: serial?flag  -> bytes = 0; goto recep;
     :: serial?comum -> goto ocioso;
     :: serial?esc   -> goto ocioso;
    od

recep:
    do
     :: serial?flag ->
      if
       :: (bytes > 0) -> printf("Quadro completo recebido por RX\n"); goto ocioso;
       :: else        -> goto recep;
      fi
     :: serial?comum ->
      if
       :: (bytes < 4) -> bytes = bytes+1; printf("Tamanho do quadro %d \n", bytes); goto recep;
       :: else        -> printf("Overflow no RX\n"); goto ocioso;
      fi
     :: serial?esc -> goto escape;
     :: timeout    -> goto ocioso;
    od

escape:
    do
     :: serial?comum -> bytes = bytes+1; goto recep;
     :: serial?flag -> goto ocioso;
     :: serial?esc  -> goto ocioso;
     :: timeout     -> goto ocioso;
    od
}


