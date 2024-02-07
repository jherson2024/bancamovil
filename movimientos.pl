#!C:\xampp\perl\bin\perl.exe
use strict;
use warnings;
use CGI;
use DBI;
my $host     = "localhost";
my $port     = "3306";
my $db_name     = "bancamovil";
my $user     = "user01";
my $password = "1234";
my $dbh = DBI->connect("DBI:mysql:database=$db_name;host=$host;port=$port", $user, $password, { PrintError => 0, RaiseError => 1 });
my $cgi = CGI->new;
my $numero = $cgi->param("numero");
my $clave = $cgi->param("clave");

my $cgi = CGI->new;
my $nombre_completo = $cgi->param("nombre_completo");
my $numero_cuenta = $cgi->param("numero_cuenta");
my $saldo = $cgi->param("saldo");
my $moneda = $cgi->param("moneda");
my $tarjeta_id = $cgi->param("tarjeta_id");
my $cuenta_movimiento = $cgi->param("cuenta_movimiento");
my $monto = $cgi->param("monto");

my $alerta = "";
$saldo+=0;
$monto+=0;
if($monto<$saldo){
my $tipo=-1;
my $consulta_cuenta_id = $dbh->prepare("SELECT id FROM cuentas WHERE tarjeta_id=?;");
$consulta_cuenta_id->execute($tarjeta_id);
my ($cuenta_id) = $consulta_cuenta_id->fetchrow_array;  
if($monto>0){
my $mi_cuenta = $dbh->prepare("INSERT INTO movimientos(tarjeta_id,cuenta_id,monto,tipo)
 VALUES(?,?,?,?);"); 
$mi_cuenta->execute($tarjeta_id,$cuenta_id,0+$monto,$tipo);
}

# Consulta datos de la cuenta a hacer el movimiento
 my $consulta_su_tarjeta_id = $dbh->prepare("SELECT tarjeta_id FROM cuentas WHERE numero=?;");
$consulta_su_tarjeta_id->execute($cuenta_movimiento);
my ($su_tarjeta_id) = $consulta_su_tarjeta_id->fetchrow_array;
if (defined $su_tarjeta_id) {
    my $consulta_su_cuenta_id = $dbh->prepare("SELECT id FROM cuentas WHERE numero=?;");
$consulta_su_cuenta_id->execute($cuenta_movimiento);
my ($su_cuenta_id) = $consulta_su_cuenta_id->fetchrow_array;
    my $su_cuenta = $dbh->prepare("INSERT INTO movimientos(tarjeta_id,cuenta_id,monto,tipo)
 VALUES(?,?,?,?);");
$su_cuenta->execute($su_tarjeta_id,$su_cuenta_id,$monto,$tipo*-1,$su_tarjeta_id);
    $alerta="Movimiento hecho";
} elsif($monto>0){
    $alerta="No se encontro la cuenta a hacer movimiento!";
} 
}elsif($monto>0){
$alerta = "Saldo insuficiente!";
}

my $lista="";
my $mis_movimientos = $dbh->prepare("SELECT tipo,monto,realizado FROM movimientos WHERE tarjeta_id=?;");
$mis_movimientos->execute($tarjeta_id);
while (my ($signo, $cantidad, $fecha) = $mis_movimientos->fetchrow_array) {
    if($signo==1){
        $signo="+";
        $lista = $lista . "<p style=\"color:green;\">&nbsp;&nbsp;$signo&nbsp;$cantidad&nbsp;&nbsp;&nbsp;&nbsp;$fecha</p>";
    }else{
        $signo="-";
        $lista = $lista . "<p style=\"color:red;\">&nbsp;&nbsp;$signo&nbsp;$cantidad&nbsp;&nbsp;&nbsp;&nbsp;$fecha</p>";
    }
}

print $cgi->header('text/html');

print <<EOF;
<!DOCTYPE html>
<html>
<head>
    <title>movimientos</title>
    <link rel="stylesheet" href="estilo.css">
</head>
<body>
    <div id="opciones">
        <button type="button" id="estado" onclick="estado()">Estado</button>
        <button type="button" id="movimientos" onclick="movimientos()">Movimientos</button>
    </div>
    <form action="movimientos.pl">
        <p id="titulo">Hacer un movimiento</p>
        <p class="especificaciones">Numero de cuenta</p>
        <input type="text" name="cuenta_movimiento">
        <p class="especificaciones">Monto</p>
        <input type="text" name="monto">
        <input class="noMostrar" name="nombre_completo" value="$nombre_completo">
        <input class="noMostrar" name="numero_cuenta" value="$numero_cuenta">
        <input class="noMostrar" name="saldo" value="$saldo">
        <input class="noMostrar" name="moneda" value="$moneda">
        <input class="noMostrar" name="tarjeta_id" value="$tarjeta_id">
        <input id="enviar" type="submit" value="Realizar">
    </form>
    <div id="lista">
        <p id="tituloLista">Ultimos movimientos</p>
        $lista
    </div>
    <img src="imagenes/tarjeta.webp">
    <p id="alerta">$alerta</p>
    <button type:"button" id="salir" onclick="salir()">CERRAR SECION</button>
</body>

<script>
    function estado() {
    var urlEstado = "estado.pl?nombre_completo=" + encodeURIComponent("$nombre_completo") +
        "&numero_cuenta=" + encodeURIComponent("$numero_cuenta") +
        "&saldo=" + encodeURIComponent("$saldo") +
        "&moneda=" + encodeURIComponent("$moneda") +
        "&tarjeta_id=" + encodeURIComponent("$tarjeta_id");
    window.location.href = urlEstado;
    }
    function movimientos() {
        var urlEstado = "movimientos.pl?nombre_completo=" + encodeURIComponent("$nombre_completo") +
        "&numero_cuenta=" + encodeURIComponent("$numero_cuenta") +
        "&saldo=" + encodeURIComponent("$saldo") +
        "&moneda=" + encodeURIComponent("$moneda") +
        "&tarjeta_id=" + encodeURIComponent("$tarjeta_id") +
        "&cuenta_movimiento=" + encodeURIComponent("$cuenta_movimiento") +
        "&monto=" + encodeURIComponent("$monto");
    window.location.href = urlEstado; 
    }
    function salir(){
        window.location.href = "banca.html"; 
    }
</script>
</html>
EOF
$dbh->disconnect;
exit;