/*
    Verificação de recuperação de sincronismo do mecanismo de enquadramento. O
    processo TX envia aleatoriamente quadros completos ou quadros com erros. O 
    processo RX deve ser capaz de se recuperar o sincronismo em algum momento do 
    futuro
*/


mtype = {flag, esc, comum}
chan serial = [1] of {mtype}
 
active proctype TX() {
  int bytes
  int i
 

envia:

    /*
        Laço para que o envio de quadros pelo transmissor ocorra de forma cíclica
    */
    do
     :: true ->             // Enquanto a variavel 'i' seja menor que 10, o processo
         serial!flag;       // TX pode enviar quadros completos ou quadros com erros
         serial!comum;      // e quando a variável 'i' chegar em 10, o processo de 
         serial!comum;      // enquadramento deve sincronizar e se manter desta forma
         serial!comum;
         serial!comum;
         serial!flag;
         goto envia;
     :: (i < 10) -> 
         serial!flag;
         serial!esc;
         serial!comum;
         serial!comum;
         serial!comum;
         serial!comum;
         serial!comum; 
         i++;        
         goto envia;       
      :: (i < 10) -> 
         serial!flag;
         serial!comum;
         serial!comum;
         serial!comum;
         serial!comum;         
         serial!comum;
         serial!flag;   
         i++;    
         goto envia;  
      :: (i < 10) -> 
         serial!flag;
         serial!esc;
         serial!esc;  
         i++;    
         goto envia;  
    od

}


active proctype RX(){
    int bytes
    mtype msg;
    bool quadro;

ocioso:

    /*
        Estado ocioso da máquina de estados do receptor. Neste estado a variavel
        booleana 'quadro' é sempre falsa. Esta variável indica quando um quadro
        é recebido pelo receptor
    */

quadro = false;
    do
     :: serial?flag  -> bytes = 0; goto recep;  // A saída deste estado só ocorre
     :: serial?comum -> goto ocioso;            // quando o receptor recebe um byte
     :: serial?esc   -> goto ocioso;            // de 'flag'
    od

recep:

    /*
        Estado de recepção da máquina de estados do enquadramento. Variavel 'quadro'
        é false até que receba um byte 'flag' 
    */

quadro = false;
    do
     :: serial?flag ->
      if
       :: (bytes > 0) -> quadro = true; goto ocioso;    // Caso receba o byte 'flag'
       :: else        -> goto recep;                    // e o número de bytes recebidos seja
      fi                                                // maior que 0, a variavel 'quadro' vai para
     :: serial?comum  ->                                // true indicando que um quadro foi recebido
      if
       :: (bytes < 4) -> bytes = bytes+1; goto recep;
       :: else        -> goto ocioso;
      fi
     :: serial?esc -> goto escape;
     :: timeout    -> goto ocioso;
    od

escape:
    
    /*
        Estado de escape. Caso receba um byte comum neste estado, retorna para
        estado de recepção. Caso contrário, descarta o byte e volta para ocioso.
        Variavel 'quadro' é sempre falsa neste estado      
    
    */
    
quadro = false;
    do
     :: serial?comum -> bytes = bytes+1; goto recep;    
     :: serial?flag  -> goto ocioso;
     :: serial?esc   -> goto ocioso;
     :: timeout      -> goto ocioso;
    od
}

    /*
        Formula que verifica se a variavel 'quadro' sempre eventualmente é verdadeira,
        indicando que o transmissor e receptor estão sincronizados
    */
ltl quadro_completo { [] <> (RX:quadro == true) }


