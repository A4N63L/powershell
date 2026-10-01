# Comprobación de puertos TCP

Práctica: recibir un puerto decimal de 1 a 65535 y comprobar una conexión TCP a `127.0.0.1`, con espera aproximada de dos segundos. Se aceptan ceros iniciales como decimales. No se usa ping.

## Estructura y requisitos

- `linux/Dockerfile`: Ubuntu 24.04 y netcat-openbsd; copia el script ejecutable y lo configura como ENTRYPOINT. COPY conserva su permiso ejecutable registrado en Git.
- `linux/comprobar_puerto.sh`: validación de un único argumento y conexión mediante `nc -z -w 2`.
- `windows/comprobar_puerto.ps1`: comprobación con TcpClient, timeout y liberación de recursos, escrita para Windows PowerShell 5.1 y PowerShell 7.

Linux Mint necesita Docker Engine funcionando; Python 3 permite la demostración. Para ejecutar Bash directamente se necesita Bash y netcat-openbsd. Windows necesita Windows PowerShell 5.1 o PowerShell 7.

## Linux Mint

Desde la raíz del repositorio:

```bash
docker build -t practica-puertos ./linux
docker run --rm --network host practica-puertos 8000
echo $?
```

Demostración reproducible (si 8000 está ocupado, elegir otro puerto en todos los comandos):

```bash
python3 -m http.server 8000 --bind 127.0.0.1 &
servidor=$!
sleep 1
docker run --rm --network host practica-puertos 8000
echo $?  # 0, ABIERTO
kill "$servidor"  # detener únicamente nuestro servidor
wait "$servidor" 2>/dev/null
docker run --rm --network host practica-puertos 8000
echo $?  # 1, CERRADO
```

Probar también sin argumento, `abc`, `0`, `65536`, dos argumentos y `0008000`. Los primeros casos deben devolver 2; el último comprueba el puerto 8000.

TCP comprueba que se puede establecer una conexión, no que la aplicación funcione correctamente. Localhost pertenece al entorno de red del proceso: normalmente dentro de Docker es el contenedor. En Docker Engine convencional sobre Linux, `--network host` comparte la red del host y permite comprobar el servidor de Mint. En este equipo Docker no es rootless. En entornos rootless ese modo puede apuntar a la red del daemon, sin compartir el localhost real de Mint.

## Windows y PowerShell

Desde la raíz, en Windows:

```powershell
powershell.exe -NoProfile -File .\windows\comprobar_puerto.ps1 -Puerto 8000
$LASTEXITCODE
# También admite el puerto posicional:
powershell.exe -NoProfile -File .\windows\comprobar_puerto.ps1 8000
```

Si la política de ejecución bloquea el archivo, usar únicamente para ese proceso:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\windows\comprobar_puerto.ps1 -Puerto 8000
```

Esto no modifica permanentemente las políticas; políticas impuestas por la organización pueden prevalecer.

Alternativa para probar PowerShell 7 en Linux, compartiendo la red de Mint:

```bash
docker run --rm --network host -v "$PWD/windows:/scripts:ro" \
  mcr.microsoft.com/powershell:7.4-ubuntu-22.04 \
  pwsh -NoProfile -File /scripts/comprobar_puerto.ps1 -Puerto 8000
echo $?
```

Una prueba con PowerShell sobre Linux no equivale a una prueba real en Windows.

## Salidas

| Código | Resultado |
|---|---|
| 0 | `Puerto TCP 8000 en 127.0.0.1: ABIERTO` |
| 1 | `Puerto TCP 8000 en 127.0.0.1: CERRADO` |
| 2 | Uso inválido, dependencia ausente o error de ejecución |

**CERRADO** significa que no se estableció la conexión dentro del límite; puede incluir rechazo o filtrado. Docker puede devolver sus propios errores (por ejemplo 125) antes de ejecutar el script: no representan un puerto cerrado.

## Verificación real (1 de octubre de 2026)

Se verificaron Git, Python 3 y Docker Engine 29.1.3 no rootless. Tras varios tiempos de espera con el driver `vfs`, la construcción de `practica-puertos` terminó correctamente. Con un servidor temporal iniciado mediante `python3 -m http.server 8000 --bind 127.0.0.1`, Bash en Docker con `--network host` devolvió ABIERTO y código 0 para `8000` y `0008000`. Después de detener únicamente ese servidor, devolvió CERRADO y código 1 para el mismo puerto.

Dentro de la imagen también se verificaron sin argumento, `abc`, `0`, `65536`, argumentos extra y dependencia `nc` ausente: todos devolvieron 2. Bash pasó la revisión sintáctica; las pruebas directas sobre Mint también aprobaron estos casos y múltiples ceros iniciales. No quedó el servidor temporal en ejecución.

No hay `pwsh` local. Se intentó descargar la imagen oficial `mcr.microsoft.com/powershell:7.4-ubuntu-22.04`; la etiqueta fue aceptada y una capa terminó de descargarse, pero la descarga completa agotó los tiempos de espera. Por tanto, falta ejecutar PowerShell tanto en Linux como en Windows; no se presentan esas pruebas como aprobadas.

Subir este repositorio a GitHub no entrega automáticamente el enlace al profesor: el alumno debe enviarlo personalmente.
