#!C:\xampp\perl\bin\perl.exe
use strict;
use warnings;
use DBI;
use CGI;
my $host     = "localhost";
my $port     = "3306";
my $db_name     = "bancamovil";
my $user     = "user01";
my $password = "1234";
my $dbh = DBI->connect("DBI:mysql:database=$db_name;host=$host;port=$port", $user, $password, { PrintError => 0, RaiseError => 1 });
my $cgi = CGI->new;
my $numero = $cgi->param("numero");
my $clave = $cgi->param("clave");
my $cuenta_movimiento="0";
my $monto="0";

my $tabla="tarjetas";
my $consulta_filas = $dbh->prepare("SELECT COUNT(*) FROM $tabla WHERE numero=? AND clave=?");
$consulta_filas->execute($numero,$clave);
my ($filas) = $consulta_filas->fetchrow_array;
if($filas>0){
    my $consulta_tarjeta_id = $dbh->prepare("SELECT id FROM tarjetas WHERE numero=?");
    $consulta_tarjeta_id->execute($numero);
    my ($tarjeta_id) = $consulta_tarjeta_id->fetchrow_array;
    my $consulta_cliente_id = $dbh->prepare("SELECT cliente_id FROM cuentas WHERE tarjeta_id=?");
    $consulta_cliente_id->execute($tarjeta_id);
    my ($cliente_id) = $consulta_cliente_id->fetchrow_array;
    my $consulta_numero_cuenta = $dbh->prepare("SELECT numero FROM cuentas WHERE tarjeta_id=?");
    $consulta_numero_cuenta->execute($tarjeta_id);
    my ($numero_cuenta) = $consulta_numero_cuenta->fetchrow_array;
    my $consulta_nombre = $dbh->prepare("SELECT nombres,paterno,materno FROM clientes WHERE id=?");
    $consulta_nombre->execute($cliente_id);
    my ($nombre,$paterno,$materno) = $consulta_nombre->fetchrow_array;
    my $nombre_completo="$nombre $paterno $materno";
    my $consulta_saldo = $dbh->prepare("SELECT SUM(monto * CASE tipo WHEN '1' THEN 1 ELSE -1 END) AS saldo_total
    FROM movimientos WHERE tarjeta_id=?");
    $consulta_saldo->execute($tarjeta_id);   
    my ($saldo) = $consulta_saldo->fetchrow_array;  
    my $consulta_moneda = $dbh->prepare("SELECT moneda FROM cuentas WHERE tarjeta_id=?");
    $consulta_moneda->execute($tarjeta_id);
    my ($moneda) = $consulta_moneda->fetchrow_array;
    if($moneda eq "s"){
        $moneda="soles";
    }else{
        $moneda="dolares";
    }
    $saldo+=0;
    print $cgi->header('text/html');
print <<EOF;
<!DOCTYPE html>
<html>
    <head>
        <title>estado</title>
    </head>
    <style>
body {
            background-color: #fff; 
            color: #000; 
            font-family: Arial, sans-serif;
        }
        #opciones {
            background-color: #000; 
            padding: 10px; 
            text-align: center; 
        }
        button {
            color: #fff;
            margin: 0 10px; 
            padding: 8px 16px; 
            border: none; 
            border-radius: 5px; 
            cursor: pointer; 
        }
        #estado {
            background-color: #dfc440; 
            color: #000000; 
        }
        #movimientos{
            background-color: #9e9c8c;
        }
        #contenido {
            width: 300px; 
            margin: 50px auto; 
            padding: 20px;
            border: 1px solid #000; 
            border-radius: 10px; 
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        #nombre,#saldo {
            font-size: 16px;
        }
        img{
            position: relative;
            bottom: 10px;
            width: 30%;
            height: 30%;
        }
        #nombre {
          font-size: 20px;
          font-weight: bold;
          color: #333; 
         }
        #numero {
          font-size: 16px;
          color: #666; 
        }
        #saldo {
           font-size: 18px;
           color: #009900; 
        }
        #salir{
            position: absolute;
            top: 60px;
            left:100px;
            padding: 9px 18px;
            font-size: 14px;
            background-color: orange;
            color: #fff;
            border: none;
            border-radius: 4px;
        }
    </style>
<body>
    <div id="opciones">
        <button id="estado" onclick="estado()">Estado</button>
        <button id="movimientos" onclick="movimientos()">Movimientos</button>
    </div>
    <div id="contenido">
        <p id="nombre">$nombre_completo</p>
        <p id="numero">Numero cuenta: $numero_cuenta</p>
        <p id="saldo">Saldo: $saldo $moneda</p>
    </div>
    <img src="imagenes/tarjeta.webp">
    <button id="salir" onclick="salir()">CERRAR SECION</button>
</body>
<script>
    function estado() {
    var urlEstado = "estado.pl?nombre_completo=" + encodeURIComponent('$nombre_completo') +
        "&numero_cuenta=" + encodeURIComponent('$numero_cuenta') +
        "&saldo=" + encodeURIComponent('$saldo') +
        "&moneda=" + encodeURIComponent('$moneda') +
        "&tarjeta_id=" + encodeURIComponent('$tarjeta_id');
    window.location.href = urlEstado;
    }
    function movimientos(){
       var urlEstado = "movimientos.pl?nombre_completo=" + encodeURIComponent('$nombre_completo') +
        "&numero_cuenta=" + encodeURIComponent('$numero_cuenta') +
        "&saldo=" + encodeURIComponent('$saldo') +
        "&moneda=" + encodeURIComponent('$moneda') +
        "&tarjeta_id=" + encodeURIComponent('$tarjeta_id') +
        "&cuenta_movimiento=" + encodeURIComponent('$cuenta_movimiento') +
        "&monto=" + encodeURIComponent('$monto');
    window.location.href = urlEstado; 
    }
    function salir(){
        window.location.href = "banca.html"; 
    }
    </script>
</html>
EOF

}else{
    print "Content-type: text/html\n";
    print "Location: banca.html\n\n";
}

$dbh->disconnect;
exit;