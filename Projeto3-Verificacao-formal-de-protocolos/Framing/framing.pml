mtype = {flag, esc, comum}
chan serial = [1] of {mtype}
 
active proctype TX() {
  int bytes
  int i
 


envia:
    do
     :: true -> 
         serial!flag;
         serial!comum;
         serial!comum;
         serial!comum;
         serial!comum;
         serial!flag;
         goto envia;
     :: (i < 3) -> 
         serial!flag;
         serial!esc;
         serial!comum;
         serial!comum;
         serial!comum;
         serial!comum;
         serial!comum; 
         i++;        
         goto envia;       
      :: (i < 3) -> 
         serial!flag;
         serial!comum;
         serial!comum;
         serial!comum;
         serial!comum;         
         serial!comum;
         serial!flag;   
         i++;    
         goto envia;  
    od

}


active proctype RX(){
    int bytes
    mtype msg;
    bool quadro;

ocioso:
quadro = false;
    do
     :: serial?flag  -> bytes = 0; goto recep;
     :: serial?comum -> goto ocioso;
     :: serial?esc   -> goto ocioso;
    od

recep:
quadro = false;
    do
     :: serial?flag ->
      if
       :: (bytes > 0) -> printf("Quadro completo recebido por RX\n"); quadro = true; goto ocioso;
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
quadro = false;
    do
     :: serial?comum -> bytes = bytes+1; goto recep;
     :: serial?flag -> goto ocioso;
     :: serial?esc  -> goto ocioso;
     :: timeout     -> goto ocioso;
    od
}

ltl quadro_completo { [] <> (RX:quadro == true) }


