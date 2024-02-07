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
my $dni = $cgi->param("dni");
my $nombres = $cgi->param("nombres");
my $apellido1 = $cgi->param("apellido1");
my $apellido2 = $cgi->param("apellido2");

my $tabla="clientes";
my $consulta_filas = $dbh->prepare("SELECT COUNT(*) FROM $tabla");
$consulta_filas->execute();
my ($filas) = $consulta_filas->fetchrow_array;
my $id=$filas+1;

my $insertar = $dbh->prepare("INSERT INTO clientes(id,dni,nombres,paterno,materno)
 VALUES(?,?,?,?,?);");
$insertar->execute($id,$dni,$nombres,$apellido1,$apellido2);

my $consulta_fecha = $dbh->prepare("SELECT creado FROM $tabla WHERE id=$id");
$consulta_fecha->execute();
my ($fecha) = $consulta_fecha->fetchrow_array;

my $nombre_completo="$nombres $apellido1 $apellido2";

print $cgi->header('text/html');
  print <<EOF;
<!DOCTYPE html>
<html>
    <head>
        <title>Constancia registro Cliente</title>
    </head>
    <style>
 body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }
        #documento {
            width: 23%;
            margin: 20px auto;
            background-color: #fff;
            padding: 20px;
            border: 1px solid #ccc;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        #titulo {
            font-size: 20px;
            font-weight: bold;
            color: #333;
        }
        p {
            margin: 10px 0;
            color: #555;
        }
        img {
            width: 10%;
            height: 10%;
        }
    </style>
<body>
    <div id="documento">
        <p id="titulo">Constancia de registro cliente</p>
        <p>Cliente: $nombre_completo</p>
        <p>ID de cliente: $id</p>
        <p>DNI: $dni</p>
        <p>Fecha de registro: $fecha</p>
        <img src="imagenes/tarjetabn.jpg">
    </div>
</body>
</html>
EOF

$dbh->disconnect;
exit;