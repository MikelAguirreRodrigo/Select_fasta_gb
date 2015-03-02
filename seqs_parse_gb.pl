#!/usr/bin/perl -w

use strict;
use warnings;
$|=1;

####################### CREAR EL FASTA PARA HACE EL BLAST
open (FASTA, '+>fasta.fa')||die "ERROR: no se puede leer o crear el archivo fasta\n";
open (GENE, '+>gene.txt')||die "ERROR: no se puede leer o crear el archivo gene\n";
open (FITO, 'fitoplankton.txt')||die "ERROR: no se puede leer o crear el archivo fasta\n"; # Crear un txt con los taxones
my @fito = <FITO>;
chomp(@fito);
#my $fitop = join('|', @fito);
open (ZOOP, 'zooplankton.txt')||die "ERROR: no se puede leer o crear el archivo fasta\n";
my @zoop = <ZOOP>;
chomp(@zoop);


#my $zoopl = join('|', @zoop);
#########################
system ('wget ftp://ftp.ncbi.nih.gov/genbank/gbinv*');
#system ('wget ftp://ftp.ncbi.nih.gov/genbank/gbpln*');
#system ('wget ftp://ftp.ncbi.nih.gov/genbank/gbvrt*');

system ('gzip -d gb*.seq.gz');

my $errflag = 0;
my $file = '';
my $arch = '';

my @files = ("gbinv");	# FITO = gbpln, ZOOP = gbinv, 

foreach my $u(@files){
	############################### LEER LOS ARCHIVOS DE UNO EN UNO
	my $i = 1;
	while ($i){
		$file = "$u$i.seq";
	
	############################# Bucle para cada archivo a parsear

		open( MICRO, $file )||die "ERROR: no se puede leer o crear el archivo $file \n" && exit;
		print "Analizando archivo $file\n";
		# Procesamiento fichero

			#limpiar variables
			my $line      = '';
			my $letters   = '';
			my $esp2    = '';
			my $e    = '';
			my $esp1  = '';
			my $pmid      = '';
			my $fecha     = '';
			my $isolation = '';
			my $gen       = '';
			my $seq       = '';
			my $se1       = '';
			my $tit       = '';
			my $title     = '';
			my $hitz      = '';
			my $autore    = '';
			my $_         = '';
			my $num       = '';
			my $sekuen    = '';
			my $DNA       = '';
			my $sequ      = '';
			my $journal   = '';
			my $fine = '';
			my $t1 = '';
			my $country = '';
			my $host = '';
			my $coor = '';
			my $metadata = '';
			my $au = '';
			my $titu = '';
			my $zen = 0;
			my $titaut = '';
			my $ano='';
			my $o = 0;
			my $fi = '';
			my $res = '';

			foreach (<MICRO>) {
				my $line = $_;
				chomp($line);

				# EL NOMBRE DE LA ESPECIE #########################################################
				if ( $line =~ /\s+ORGANISM\s+(.+)/ ) {
					$e = 1;
				}
				if ($e){
					$esp1 = $_;
					chomp($esp1);
					$esp2 .= $esp1;
					if ($o ==2){
						$esp2 =~ s/\s{11}//g;
						$esp2 =~ s/\s/_/g;
						$esp2 =~ s/__ORGANISM__//g;
				
						$e = '';
					}
					$o++;
				}

				# EL NOMBRE DEL GEN #########################################################
				if ( $line =~ /\s+\/product="(.+)"/ ) {
					$gen = $1;
				}

				# LA SECUENCIA ##############################################################
				if ( $line =~ /^ORIGIN/ ) {
					$se1 = 1;
				}
				if ($se1){
						$sekuen = $_;
						chomp ($sekuen);
						$seq .= $sekuen;
					if ($_ =~ /\/\//) { 
						$se1 = 0;
						$seq =~ s/ORIGIN//g;
						$seq =~ s/\d//g;
						$seq =~ s/\s//g;
						$seq =~ s/\/\///g;
					}
				}

				if ( $line =~ /^\/\// ){    #cuando acabe cada entrada (con //) guarda los datos en la BD
					if ($u =~ /gbpln/){
						#Solo las entradas
						if ($gen && $esp2){
							foreach $fi(@fito){
								if ($esp2 =~ /$fi/){
									print FASTA ">($gen)$esp2\n$seq\n\n";
									print GENE "$gen\n";
								}
							}
						}
					}
					if ($u =~ /gbinv|gbver/){
						#Solo las entradas 
						if ($gen =~ /18S/){
							$gen =~ s/\s/_/g;
							if ($gen && $esp2){
								foreach $fi(@zoop){
									if ($esp2 =~ /$fi/){
										print FASTA ">($gen)$esp2\n$seq\n\n";
										print GENE "$gen\n";
									}
								}
							}
						}
					}

					#limpiar variables
					$esp2   = '';
					$e   = '';
					$pmid      = '';
					$fecha     = '';
					$isolation = '';
					$gen       = '';
					$seq       = '';
					$tit       = '';
					$se1       = '';
					$letters   = '';
					$title     = '';
					$hitz      = '';
					$autore    = '';
					$o    = 0;
					$journal   = '';
					$esp1  = '';
					$fine = '';
					$t1 = '';
					$host = '';
					$coor = '';
					$country = '';
					$metadata = '';
					$titu = '';
					$au = '';
					$zen = 0;
					$titaut = '';
				}
			}    #cierra las expresiones regulares del parseador

		close(MICRO);
	
	$i++;
	}
}
##################### Fin del bucle de cada archivo
	#Cerrar todas las transaciones con las tablas
#	$sthmicro->finish() unless ($DBI::err);
#	warn "Error de consulta: " . $DBI::errstr if ($DBI::err);

	#Cerrar la conecsion con la base de datos y el archivo
#	$dbh->disconnect() || warn " Fallo al desconectar . Error : $DBI::errstr \n ";
close(FITO);
close(ZOOP);
close(FASTA);
close(GENE);
exit;
