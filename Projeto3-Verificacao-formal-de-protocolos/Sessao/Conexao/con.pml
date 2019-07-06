mtype = {CR, CC, CA, data}
chan canal1 = [1] of {mtype}
chan canal2 = [1] of {mtype}
 

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
conectado:
    do
     :: canal2?CR   -> canal1!CC; goto con;
     :: canal1!data -> goto con;
     :: canal2?data -> printf("NODO1 RECEBEU DADO\n"); -> goto con;
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
 
    do
     :: canal1?CR   -> canal2!CC; goto con;
     :: canal2!data -> goto con;
     :: canal1?data -> printf("NODO2 RECEBEU DADO\n"); -> goto con;
     :: timeout    -> canal2!data ;
    od

}

ltl teste { []<>  ((true U nodo1@con)  && (true U nodo2@con))}

