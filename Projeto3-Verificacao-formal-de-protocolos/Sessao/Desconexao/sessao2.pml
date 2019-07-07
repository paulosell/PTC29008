mtype = {DR, DC, data}

chan canal1 = [1] of {mtype}
chan canal2 = [1] of {mtype}
int desconectados;

active proctype nodo1(){
    int retries = 0;
    

con:
    do
     :: canal1!DR   -> printf("nodo1 enviou DR e solicitou desconexao\n");           goto half1;
     :: canal2?DR   -> canal1!DR; printf("nodo1 recebeu DR/enviou DR indo para half2\n");      goto half2;
     :: timeout     -> goto disc;
    od


half1:
    do
     :: canal2?DR   -> canal1!DC; printf("nodo1 recebeu DR/enviou DC indo para disc\n");                 goto disc;
     :: timeout    -> 
        if
         :: (retries < 4) -> canal1!DR; retries = retries + 1; printf("nodo1 timeout em half1 reenviando DR\n"); goto half1;  
         :: (retries >= 4)          -> goto disc;
        fi 
    od

half2:

    do
     :: canal2?DR -> canal1!DR; printf("nodo1 recebendo DR e enviando DR\n"); goto half2;
     :: canal2?DC -> printf("nodo1 recebeu DC e foi para disc\n");           goto disc;
     :: timeout  -> printf("timeout em nodo1, indo para disc\n");           goto disc;
    od

disc:
desconectados++; 
printf("nodo1 em disc\n"); 
   


}

active proctype nodo2(){
    int retries = 0;
    

con:
    do
     :: canal2!DR   -> printf("nodo2 enviou DR e solicitou desconexao\n");           goto half1;
     :: canal1?DR   -> canal2!DR; printf("nodo2 recebeu DR/enviou DR indo para half2\n");      goto half2;
     :: timeout    -> goto disc;
    od

half1:

    do
     :: canal1?DR   -> canal2!DC; printf("nodo2 recebeu DR/enviou DC indo para disc\n");                 goto disc;
     :: timeout    -> 
        if
         :: (retries < 5) -> canal2!DR; retries = retries + 1; printf("nodo2 timeout em half1 reenviando DR\n"); goto half1;  
         :: (retries >= 5)          -> goto disc;
        fi
    od

half2:

    do
     :: canal1?DR -> canal2!DR; printf("nodo2 recebendo DR e enviando DR\n"); goto half2;
     :: canal1?DC -> printf("nodo2 recebeu DC e foi para disc\n");           goto disc;
     :: timeout  -> printf("timeout em nodo2, indo para disc\n");           goto disc;
    od

disc:
desconectados++;
printf("nodo2 em disc\n"); 

    
   
}

ltl desconexao { [] <> (desconectados == 2) }
