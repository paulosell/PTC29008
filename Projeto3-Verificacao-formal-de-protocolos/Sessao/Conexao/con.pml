/*
    Verificação de estabelecimento de sessão entre dois pares comunicantes a partir da 
    premissa de que os pares estão desconectados. Ambos processao são iguais, 
    com exceção dos canais de comunicação.
*/

mtype = {CR, CC, CA, data}
chan canal1 = [1] of {mtype}
chan canal2 = [1] of {mtype}
int conectados;

active proctype nodo1(){
    int retries = 0;

disc:

    /*
        Estado inicial de conexão. O nodo pode ou enviar a solicitação de desconexão
        ou receber uma solicitação de desconexão. 
    */

    do
     :: canal1!CR -> goto hand1;            // Nodo pode querer iniciar a sessão ou
     :: canal2?CR -> canal1!CC; goto hand2; // receber uma solicitação de conexão
    od



hand1:

    /*  
        Estado pré conexão após nodo iniciar sessão. Nodo aguarda receber CC para poder ir para o estado de conectado
    */

    do
     :: canal2?CR -> canal1!CC; goto hand1;
     :: canal2?CC -> canal1!CA; goto con;  
     :: canal2?CA -> goto con;  
     :: timeout   -> 
        if
         :: (retries < 4) -> canal1!CR;  retries = retries + 1; goto hand1;
         :: else          -> retries = 0; goto disc;
        fi
    od


hand2:

    /*
        Estado pré conexão após nodo receber solicitação de conexão. Nodo CA ou dados para ir para estado de conexão
    */

    do
     :: canal2?CA   -> goto con;
     :: canal2?data -> goto con;
     :: timeout     -> goto disc;
    od

con:        
    /*
        Estado de conexão. A variável indica que um dos nodos está conectado
    */
conectados++;

con2:
    do
     :: canal2?CR   -> canal1!CC; goto con2;
     :: canal1!data -> goto con2;
     :: canal2?data -> goto con2;
     :: timeout     -> canal1!data;
    od

}


active proctype nodo2(){
    int retries = 0;

disc:

    do
     :: canal2!CR -> goto hand1;
     :: canal1?CR -> canal2!CC; goto hand2;
    od



hand1:

    do
     :: canal1?CR -> canal2!CC; goto hand1;
     :: canal1?CC -> canal2!CA; goto con;  
     :: canal1?CA -> goto con;  
     :: timeout   -> 
        if
         :: (retries < 5) -> canal2!CR; retries = retries + 1; goto hand1;
         :: else          -> retries = 0; goto disc;
        fi
    od


hand2:

    do
     :: canal1?CA   -> goto con;
     :: canal1?data -> goto con;
     :: timeout     -> goto disc;
    od

con:
conectados++;

con2:
    do
     :: canal1?CR   -> canal2!CC; goto con2;
     :: canal2!data -> goto con2;
     :: canal1?data -> goto con2;
     :: timeout     -> canal2!data ;
    od 

}

    /*
        Formula para verificar se os nodos conseguem estabelecer sessão. Quando cada nodo entra no estado de
        conexão, a variável "conectados" é incrementada. Se a variável é igual a 2, ambos os pares comunicantes estao no 
        estado de conexão
    */
ltl conexao { [] <> (conectados == 2) }
