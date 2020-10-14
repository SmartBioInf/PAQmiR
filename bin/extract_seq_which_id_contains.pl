#!/usr/bin/perl
#
#       extract_seq_which_id_contains.pl
#
#       Copyright 2020 Sylvain Marthey <sylvain.marthey@inrae.fr>
#       
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 3 of the License, or
#       (at your option) any later version.
#       
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#       
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, see <http://www.gnu.org/licenses/>.

use strict;
use Getopt::Long;
use Pod::Usage;
use Bio::Seq;
use Bio::SeqIO;

my ($help,$fasta_in,$word,$file_out,$inverse,$begining,$expr);

GetOptions("help|?" => \$help,
           "fasta_in:s" => \$fasta_in,
           "word:s" => \$word,
           "file_out:s" => \$file_out,
           "inverse:s" => \$inverse,
           "begining:s" => \$begining)
or
pod2usage(-message=>"Try `$0' for more information.", -exitval => 2,-verbose=> 0);
  
pod2usage(-exitval =>1, -verbose => 2) if ($help);

if((!$fasta_in && !-f($fasta_in)) ){
  print "--fasta_in parameter missing : try extract_seq_which_id_contains.pl --help\n";
  exit;
}
if((!$file_out && !-f($file_out)) ){
  print "--file_out parameter missing : try extract_seq_which_id_contains.pl --help\n";
  exit;
}
if((!$word) ){
  print "--file_out_path parameter missing : try extract_seq_which_id_contains.pl --help\n";
  exit;
}
if(uc($inverse) eq 'YES' || uc($inverse) eq 'Y'){
	$inverse = 1;
}else{
	$inverse = 0;
}
if(uc($begining) eq 'YES' || uc($begining) eq 'Y'){
	$expr = qr/^$word/;
}else{
	$expr = qr/$word/;
}

my $first = Bio::SeqIO->new(-file => $fasta_in);
my $out_fasta = Bio::SeqIO->new(-file => ">".$file_out , '-format' => 'Fasta');

# read the input fasta file
while (my $seq = $first->next_seq) {
	# seach the word in the identifier
	if($seq->id() =~ /$expr/){
		if(!$inverse){
			$out_fasta->write_seq($seq);
		}
	}elsif($inverse){
		$out_fasta->write_seq($seq);
	}
}


=head1 NAME

 extract_seq_which_id_contains.pl

=head1 SYNOPSIS

 extract_seq_which_id_contains.pl --fasta_in <fasta file> --word <string> --file_out <file_out_path> [--begining <yes|no> --inverse <yes|no>] 
 
=head1 OPTIONS

	--fasta_in	fasta file containing sequences we want to extract
	
	--word	word that will be searched in the id of the sequences we want to extract
	
	--file_out	out fasta file
	
	--begining	search the word only in the begining of the sequence identifier
	
	--inverse	inverse the sequence selection (like grep -v)


=head1 DESCRIPTION

  This tool will read the fasta file and extract sequences where identifiers contain the searched word.
           
=head1 AUTHORS

Sylvain Marthey <sylvain.marthey@jouy.inra.fr>

=head1 VERSION

1.1

=head1 DATE

01/01/2013

=head1 KEYWORDS

fasta, identifier, filtering

=head1 EXAMPLE

extract_seq_which_id_contains.pl --fasta_in mirbase.fa --word bta --file_out mirbase_bta.fa

=cut
