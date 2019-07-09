/*
    Verificação de encerramento de sessão entre dois pares comunicantes a partir da 
    premissa de que os pares estão conectados e se comunicando. Ambos processao são iguais, 
    com exceção dos canais de comunicação.
*/

mtype = {DR, DC, data}

chan canal1 = [1] of {mtype}
chan canal2 = [1] of {mtype}
int desconectados;

active proctype nodo1(){
    int retries = 0;

con:

    /*
        Estado inicial de conexão. O nodo pode ou enviar a solicitação de desconexão
        ou receber uma solicitação de desconexão. 
    */

    do
     :: canal1!DR   -> goto half1;              // Caso o nodo solicite a desconexao,
                                                // ele vai para o estado "half1" 
     :: canal2?DR   -> canal1!DR; goto half2;   // Caso o nodo receba solicitação de desconexão,
                                                // ele vai para o estado "half2"
     :: timeout     -> goto disc;
    od


half1:

    /*
        Estado "half1". Neste estado o nodo espera receber do par comunicante uma mensagem DR.
        Caso não receba dentro das tentativas de retransmissão, o nodo vai para o estado de 
        desconexão. 
    */

    do
     :: canal2?DR  -> canal1!DC; goto disc; // Nodo recebe DR do par comunicante e vai para o 
                                            // estado de desconexão após enviar DC
     :: timeout    -> 
        if
         :: (retries < 4)  -> canal1!DR; retries = retries + 1;  goto half1;  
         :: (retries >= 4) -> goto disc;
        fi 
    od

half2:

   /*
        Estado "half2". Neste estado o nodo espera receber do par comunicante uma mensagem DC ou DR.
        Caso receba um DC, isto indica que o outro par está indo para seu estado de desconexão. Isto implica
        em ambos os pares irem para o estado de desconexão. Caso receba um DR, o nodo envia um DR também
        e aguarda.
    */

    do
     :: canal2?DR -> canal1!DR;  goto half2; // Recebe DR. Reenvia DR e aguarda
     :: canal2?DC -> goto disc;              // Recebe DC e vai para "disc"
     :: timeout   -> goto disc;
    od

disc:   // Nodo no estado de desconexão. A variável abaixo indica que um dos nodo está desconectado
desconectados++;    

}

active proctype nodo2(){
    int retries = 0;

con:

    do
     :: canal2!DR  -> goto half1;
     :: canal1?DR  -> canal2!DR; goto half2;
     :: timeout    -> goto disc;
    od

half1:

    do
     :: canal1?DR  -> canal2!DC; goto disc;
     :: timeout    -> 
        if
         :: (retries < 5)  -> canal2!DR; retries = retries + 1;  goto half1;  
         :: (retries >= 5) -> goto disc;
        fi
    od

half2:

    do
     :: canal1?DR -> canal2!DR;  goto half2;
     :: canal1?DC -> goto disc;
     :: timeout   -> goto disc;
    od

disc:
desconectados++;

}

    /*
        Formula para verificar se os nodos conseguem encerrar sessão. Quando cada nodo entra no estado de
        desconexão, a variável "desconectados" é incrementada. Se a variável é igual a 2, ambos os pares comunicantes estao no 
        estado de desconexão
    */
ltl desconexao {  <> (desconectados==2)}
