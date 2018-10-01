# OrgaDeCompus


Como ejecutar el emulador y el programa en el:

+ Ir a la carpeta gxemul-6620-20070927

+ En una terminal(1) nueva ejecutar

	```./xgxemul -e 3max -d netbsd-pmax.img```

	En esa terminal ingresar con el usuario "root" y pass "orga6620"

+ En otra terminal(2) de linux

	 ```sudo ifconfig lo:0 172.20.0.1```

+ En la terminal(1) que corrimos el primer comando (donde esta corriendo NETBSD) ejecutar:

	```ssh -R 2222:127.0.0.1:22 USUARIO@172.20.0.1```

	donde dice 'USUARIO' reemplazar con tu usuario de linux.

+ La terminal(1) no nos sirve mas ya que abrimos un tunel ssh a linux (no queremos eso) NO LA CIERRES, minimizala.

+ En una terminal(3) nueva de linux necesitamos conectarnos a NETBSD, para eso:

	```ssh -p 2222 root@127.0.0.1```

	y nos pide la pass que es "orga6620"

+ Ahora tenemos una terminal(3) de linux si aparece algo como "Terminal type?" escribir "vt100" (por lo menos en mi caso era ese el tipo, sino fijarse en la terminal(1) que dice el Terminal type.

+ Copiamos el tp a NETBSD para eso en otra terminal(4) nueva de linux hacemos por ejemplo:

    ```scp -P2222 -r DIRECTORIOACOPIAR root@127.0.0.1:```

+ En la terminal(3) que tenemos el tunel a NETBSD, podemos ejecutar comandos como cd o ls para ir hasta donde esta el tp y compilar el programa haciendo: `make`

En caso no encontrarnos en el emulador y correr el comando make en el directirio correspondiente; se mostrara por pantalla un error de compilacion en la version assembler .S, pero de todos modos el programa se va a terminar compilando con la version de quicksort de C.
