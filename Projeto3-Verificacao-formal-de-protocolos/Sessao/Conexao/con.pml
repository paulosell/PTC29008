mtype = {CR, CC, CA, data}
chan canal1 = [1] of {mtype}
chan canal2 = [1] of {mtype}

int conectados;

active proctype nodo1(){
    int retries = 0;
disc:
    do
     :: canal1!CR -> goto hand1;
     :: canal2?CR -> canal1!CC; goto hand2;
    od



hand1:
printf("Nodo 1 em hand1\n");

    do
     :: canal2?CR -> canal1!CC; goto hand1;
     :: canal2?CC -> canal1!CA; printf("Nodo 1 em CON\n"); goto con;  
     :: canal2?CA -> printf("Nodo 1 em CON\n"); goto con;  
     :: timeout  -> 
        if
         :: (retries < 4) -> canal1!CR;  retries = retries + 1; goto hand1;
         :: else          -> retries = 0; printf("Erro\n"); goto disc;
        fi
    od


hand2:
printf("Nodo 1 em hand2\n");

    do
     :: canal2?CA   -> printf("Nodo 1 em CON\n"); goto con;
     :: canal2?data -> printf("Nodo 1 em CON\n"); goto con;
     :: timeout    -> goto disc;
    od



con:    
conectados++;
con2:
    do
     :: canal2?CR   -> canal1!CC; goto con2;
     :: canal1!data -> goto con2;
     :: canal2?data -> printf("NODO1 RECEBEU DADO\n"); -> goto con2;
     :: timeout    -> canal1!data;
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
printf("Nodo 2 em hand1\n");


    do
     :: canal1?CR -> canal2!CC; goto hand1;
     :: canal1?CC -> canal2!CA; printf("Nodo 2 em CON\n"); goto con;  
     :: canal1?CA -> printf("Nodo 2 em CON\n"); goto con;  
     :: timeout  -> 
        if
         :: (retries < 4) -> canal2!CR;  retries = retries + 1; goto hand1;
         :: else          -> retries = 0; printf("Erro\n"); goto disc;
        fi
    od


hand2:
printf("Nodo 2 em hand2\n");

    do
     :: canal1?CA   -> printf("Nodo 2 em CON\n"); goto con;
     :: canal1?data -> printf("Nodo 2 em CON\n"); goto con;
     :: timeout    -> goto disc;
    od

con:
conectados++;
con2:
    do
     :: canal1?CR   -> canal2!CC; goto con2;
     :: canal2!data -> goto con2;
     :: canal1?data -> printf("NODO2 RECEBEU DADO\n"); -> goto con2;
     :: timeout    -> canal2!data ;
    od

}

ltl conexao { [] <> (conectados == 2) }