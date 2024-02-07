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
my $usuario = $cgi->param("usuario");
my $clave = $cgi->param("clave");

my $tabla="usuarios";
my $consulta_filas = $dbh->prepare("SELECT COUNT(*) FROM $tabla WHERE usuario=? AND clave=?");
$consulta_filas->execute($usuario,$clave);
my ($filas) = $consulta_filas->fetchrow_array; 

if($filas>0){
    print "Content-type: text/html\n";
    print "Location: clientes.html\n\n";
}else{
    print "Content-type: text/html\n";
    print "Location: index.html\n\n";
}

$dbh->disconnect;
exit;