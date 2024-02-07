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
my $moneda = $cgi->param("moneda");
my $cliente_id = $cgi->param("cliente_id");
my $tarjeta_id = $cgi->param("tarjeta_id");

my $tabla="cuentas";
my $consulta_filas = $dbh->prepare("SELECT COUNT(*) FROM $tabla");
$consulta_filas->execute();
my ($filas) = $consulta_filas->fetchrow_array;
my $id=$filas+1;
my $insertar = $dbh->prepare("INSERT INTO cuentas(id,numero,moneda,cliente_id,tarjeta_id)
 VALUES(?,?,?,?,?);");
$insertar->execute($id,$numero,$moneda,$cliente_id,$tarjeta_id);
print "Content-type: text/html\n";
print "Location: cuentas.html\n\n";

$dbh->disconnect;
exit;