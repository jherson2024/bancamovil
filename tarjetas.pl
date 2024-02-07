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

my $tabla="tarjetas";
my $consulta_filas = $dbh->prepare("SELECT COUNT(*) FROM $tabla");
$consulta_filas->execute();
my ($filas) = $consulta_filas->fetchrow_array;
my $id=$filas+1;
my $insertar = $dbh->prepare("INSERT INTO tarjetas(id,numero,clave)
 VALUES(?,?,?);");
$insertar->execute($id,$numero,$clave);
print $cgi->header('text/html');
  print <<EOF;
<!DOCTYPE html>
<html>
    <head>
        <title>sobre</title>
    </head>
    <style>
        body {
            background-color: #f0f0f0;
            color: #333;
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
        }

        #contenido {
            max-width: 600px;
            margin: 50px auto;
            background-color: #fff;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            text-align: center;
        }

        #titulo {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 10px;
        }

        #id {
            color: #888;
        }

        img {
            width: 50%;
            max-width: 200px;
            height: auto;
            border-radius: 5px;
            margin-top: 20px;
        }
    </style>
<body>
    <div id="contenido">
        <p id="titulo">Sobre de tarjeta</p>
        <p id="id">ID de tarjeta: $id</p>
         <img src="imagenes/tarjetabn.jpg">
    </div>
</body>
</html>
EOF

$dbh->disconnect;
exit;