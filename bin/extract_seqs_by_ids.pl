#!/usr/bin/perl
#
#       extract_seqs_by_ids.pl
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

my ($help,$fasta_in,$ids_file,$file_out,$inverse,$precursor_shape,@exprs,%ids_seqs,$regular_expression);

GetOptions("help|?" => \$help,
           "fasta_in:s" => \$fasta_in,
           "ids_file:s" => \$ids_file,
           "file_out:s" => \$file_out,
           "inverse:s" => \$inverse,
           "precursor_shape:s" => \$precursor_shape,
           "regular_expression:s" => \$regular_expression)
or
pod2usage(-message=>"Try `$0' for more information.", -exitval => 2,-verbose=> 0);
  
pod2usage(-exitval =>1, -verbose => 2) if ($help);

if((!$fasta_in || !-f($fasta_in)) ){
  print "--fasta_in parameter missing or is not a valid file path: try extract_seqs_by_ids.pl --help\n";
  exit;
}
if((!$file_out && !-f($file_out)) ){
  print "--file_out parameter missing : try extract_seqs_by_ids.pl --help\n";
  exit;
}
if(!$ids_file || !-f($ids_file)){
  print "--ds_file parameter missing or is not a valid file path: try extract_seqs_by_ids.pl --help\n";
  exit;
}
if(uc($inverse) eq 'YES' || uc($inverse) eq 'Y'){
	$inverse = 1;
}else{
	$inverse = 0;
}
if(uc($regular_expression) eq 'YES' || uc($regular_expression) eq 'Y'){
	$regular_expression = 1;
}else{
	$regular_expression = 0;
}


# read the input ids file
open(IDS,$ids_file) or die "impossible d'ouvrir le fichier $ids_file\n";

while(<IDS>){
	chomp;
	push(@exprs,qr/$_$/);
	$ids_seqs{$_}++;
}
close IDS;

my $first = Bio::SeqIO->new(-file => $fasta_in,'-format'=>'Fasta');
my $out_fasta = Bio::SeqIO->new(-file => ">".$file_out , '-format' => 'Fasta');

# read the input fasta file
while (my $seq = $first->next_seq) {
	my $id = $seq->id();
# 	print $id."\t";
	if(uc($precursor_shape) eq 'YES' || uc($precursor_shape) eq 'Y'){
		$id =~ s/([a-zA-Z]{3}-[a-zA-Z]{3}-\w+)-(\d+)$/$1/;
# 		print $id."\n";
	}
	my $found = 0;
	if($regular_expression){
		# seach the ids_file in the identifier
		foreach my $expr (@exprs){
			if($id =~ /$expr/){
				$found++;
				last;
			}
		}
	}else{
		if($ids_seqs{$id}){
			$found++;
		}
	}
	if($found>0 && !$inverse){
		$out_fasta->write_seq($seq);
	}elsif($found == 0 && $inverse){
		$out_fasta->write_seq($seq);
	}
}


=head1 NAME

 extract_seqs_by_ids.pl

=head1 SYNOPSIS

 extract_seqs_by_ids.pl --fasta_in <fasta file> --ids_file <string> --file_out <file_out_path> [--begining <yes|no> --inverse <yes|no>] 
 
=head1 OPTIONS

	--fasta_in	fasta file containing sequences we want to extract
	
	--ids_file	file containing words that will be searched in the id of the sequences we want to extract (one id peer line)
	
	--file_out	out fasta file
	
	--precursor_shape	searched ids doesn't contain the location tag (-1, -2, -3, -N) it will be skipped in the sequence_id research
	
	--inverse	inverse the sequence selection (like grep -v)
	
	--regular_expression	yes|no


=head1 DESCRIPTION

  This tool will read the fasta file and extract sequences where identifiers contain the searched words.
           
=head1 AUTHORS

Sylvain Marthey <sylvain.marthey@inra.fr>

=head1 VERSION

1.1

=head1 DATE

01/01/2019

=head1 KEYWORDS

fasta, identifier, filtering

=head1 EXAMPLE

extract_seqs_by_ids.pl --fasta_in mirbase.fa --ids_file bta --file_out mirbase_bta.fa

=cut
