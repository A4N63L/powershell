# Compatible con Windows PowerShell 5.1 y PowerShell 7.
# Analizar los argumentos explícitamente permite devolver 2 ante uso inválido.
if ($args.Count -eq 1 -and [string]$args[0] -cnotmatch '^-' ) {
    $texto = [string]$args[0]
} elseif ($args.Count -eq 2 -and [string]$args[0] -ieq '-Puerto') {
    $texto = [string]$args[1]
} else {
    [Console]::Error.WriteLine('Uso: comprobar_puerto.ps1 [-Puerto] PUERTO (1 a 65535)')
    exit 2
}

if ($texto -cnotmatch '^[0-9]+$') {
    [Console]::Error.WriteLine('Error: el puerto debe ser un entero decimal de 1 a 65535.')
    exit 2
}
# Normalizar antes de convertir también admite muchos ceros iniciales.
$normalizado = $texto.TrimStart([char]'0')
if ($normalizado.Length -eq 0 -or $normalizado.Length -gt 5) {
    [Console]::Error.WriteLine('Error: el puerto debe estar entre 1 y 65535.')
    exit 2
}
$numeroPuerto = [int]$normalizado
if ($numeroPuerto -gt 65535) {
    [Console]::Error.WriteLine('Error: el puerto debe estar entre 1 y 65535.')
    exit 2
}

$cliente = $null
$espera = $null
$codigo = 2
try {
    $cliente = New-Object System.Net.Sockets.TcpClient
    # API disponible en .NET Framework: conexión asíncrona y espera acotada.
    $conexion = $cliente.BeginConnect('127.0.0.1', $numeroPuerto, $null, $null)
    $espera = $conexion.AsyncWaitHandle
    if ($espera.WaitOne(2000, $false)) {
        $cliente.EndConnect($conexion)
        $codigo = 0
    } else {
        $codigo = 1
    }
} catch [System.Net.Sockets.SocketException] {
    $codigo = 1
} catch {
    [Console]::Error.WriteLine("Error al comprobar el puerto: $($_.Exception.Message)")
    $codigo = 2
} finally {
    # Cerrar incluso ante timeout o excepción.
    if ($null -ne $cliente) { $cliente.Close() }
    if ($null -ne $espera) { $espera.Close() }
}

if ($codigo -eq 0) {
    Write-Output "Puerto TCP $numeroPuerto en 127.0.0.1: ABIERTO"
} elseif ($codigo -eq 1) {
    Write-Output "Puerto TCP $numeroPuerto en 127.0.0.1: CERRADO"
}
exit $codigo
