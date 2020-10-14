#!/usr/bin/perl 
#
#       parse_miRDeep2_output.pl
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

# v1.2 -> v 1.3 : - correct a bug in new precursors annotation (in version 1.2 the know miRNA where not priority over the putatives matures )
#                 - add new informatiosn in log file concerning the new precursors annotations
# v1.3 -> v 1.4 15/10/2015 : - correct a bug in precursor shape detection (previously pre likeb ta-chrUn_GJ059918v1_46266 not allowed)

use strict;
use Getopt::Long;
use Pod::Usage;
# use Data::Dumper;

my ($help,$mature_arf,$expression_file,$debug,$EXP,$structure,$man);

# on recupere les options
GetOptions("help|?" => \$help,
	   "man"    =>  \$man,
           "mature_arf:s" => \$mature_arf,
           "debug:s" => \$debug,
	   "expression_file:s" => \$expression_file,
	   "structure_file:s" => \$structure
           )
or
pod2usage(-message=>"Try `$0' for more information.", -exitval => 2,-verbose=> 0);

pod2usage(-exitval =>1, -verbose => 2) if ($help);
# on test si les parametres ont bien ete rentres
if ($expression_file eq "-" ) {
    $EXP = "STDIN";
} else {
    open($EXP, "< $expression_file") or pod2usage(-message=>"--expression_file parameter missing or is not a valid file path.Try `$0 --help' for more information.",
              -exitval => 2,-verbose=> 0);
}
  
if ($mature_arf eq "" || !-f($mature_arf))
  {
     pod2usage(-message=>"--mature_arf parameter missing or is not a valid file path.\nTry `$0 --help' for more information.",
              -exitval => 2,-verbose=> 0);
  }
if ($structure eq "" || !-f($structure))
  {
     pod2usage(-message=>"--structure_file parameter missing or is not a valid file path.\nTry `$0 --help' for more information.",
              -exitval => 2,-verbose=> 0);
  }
 
my $pre_shape = qr/(\w{3})-([^-]+(-|_)\d+)_?([a-z]{0,2})(-\d{1,2})?/; # mirbase v19 mmu-mir-181a-1 ||  mmu-X_157_mt-1
# old v1.3 my $putatif_pre_shape = qr/(\w{3})-([^_]+_\d+)(-\d{1,2})?/; # mirDeep2 species + putatif ID + location
my $putatif_pre_shape = qr/(\w{3})-([^_]+(_\w+)?_\d+)(-\d{1,2})?/; # mirDeep2 species + putatif ID + location (bta-chr3_34604 || bta-chr3_34604 || bta-chrUn_GJ059918v1_46266)

my $mature_shape = qr/(\w{3})-([^-]+(-|_)\d+)(_[a-z]{0,2})?([a-z]{0,2})(-\d{1,2})?(-\d{1}p)?/; # mirbase v19 ex: mmu-miR-181a-1-3p ||  mmu-X_157_mt-1-3p
# old v1.2 $mature_shape = qr/(\w{3})-([^-]+(-|_)\d+)_?([a-z]{0,2})(-\d{1,2})?(-\d{1}p)?/;

my %pre_arf;
my %matures_arf;
my %seqs;
my $id;

print STDERR "Read the structure file mapping file $structure file.\n";
# lecture du fichier de structure pour récupérer les séquences des précurseurs
open(STR,$structure) or die "impossible d'ouvrir le fichier $structure\n";
while(<STR>){
        if(/^\>(\S+)/){
            $id = $1;
        }elsif(/^pri_seq\s+(\S+)/){
            $seqs{$id}{"pri_seq"}=$1;
        }
}
close STR;

print STDERR "Read the mature mapping file $mature_arf.\n";
# lecture du fichier de mapping des matures sur les pre
open(ARF,$mature_arf) or die "impossible d'ouvrir le fichier $mature_arf\n";
while(<ARF>){
	my @line  =split(/\t/,$_);
	if($line[0] =~ /^$mature_shape$/){
# 		if($debug){print "mature id : ".$line[0]." start: ".$line[7]." precurseur_id ".$line[5]." precurseur_seq :".$seqs{$line[5]}{"pri_seq"}." pecurseur_size :".length($seqs{$line[5]}{"pri_seq"})."\n";}
		if($line[7]>(length($seqs{$line[5]}{"pri_seq"})/2)){
			$pre_arf{$line[5]}{$line[0]}='-3p';
		}else{
			$pre_arf{$line[5]}{$line[0]}='-5p';
		}
	}else{
		print STDERR "! ".$line[0]." n'a pas une forme de mature reconnue\n";
		if($line[7]>(length($seqs{$line[5]}{"pri_seq"})/2)){
			$pre_arf{$line[5]}{$line[0]}='-3p';
		}else{
			$pre_arf{$line[5]}{$line[0]}='-5p';
		}
	}
	$matures_arf{$line[0]} = $line[4];
}
close ARF;
print STDERR "# ".scalar(keys(%matures_arf))." matures mapped to the ".scalar(keys(%pre_arf))." precursor\n";
  
  
my %pre;
my %pre_autre;
my %pre_put;
my %matures;
my %vus;
my $i=1;

print STDERR "\nRead the expression file $expression_file.\n";
# lecture du fichier de quantification
while(<$EXP>){
	# skip header line
	chomp;
	my @line  = split(/\t/,$_);
	my $put;
	if($line[0] eq '#miRNA'){
		$_ =~ s/precursor/precursor\tpredicted_position/;
		print $_."\tmature_seq"."\n";
		next;
	}
	# read the pre id
	my $precursor = parse_precursor_id($line[2]);
# 	if($debug && !$$precursor{pre_prefix}){print "skip ".$line[2]." precursor\n"};
	next if (!$$precursor{pre_prefix});
	# read the mature id 
	my $mir = parse_mature_id($line[0]);
# 	if($debug && !$$mir{mir_id}){print "skip ".$line[0]." mature\n";}
	next if (!$$mir{mir_id});
	# assign line informations to couple mature-precursor
	$matures{$line[0]}{$line[2]} = $_;
	
# 	if($debug){print "check if ".$line[2]." has a putatif precursor shape\n";}
	# check if it's a putatif pre-miRNA
	if($line[2] =~ /^$putatif_pre_shape$/){
# 		if($debug){print $line[2]." is a precursor putatif\n"};
		$put=1;
		
	}
	
	# on test si le pre est un putatif, si c'est le cas on prend un des matures qui a le meilleur comptage. Quand plusieurs matures ont le meme comptage on va prendre par ordre de préférence : meme nom puis meme espèce (dans le cas des putatifs on ne gère pas le nom puisqu'ils ont par defaut un nom qui ne correspond pas à des miRNA)
	if($put){
			# si on a pu localiser sa position dans le fichier arf d'alignement
			if($pre_arf{$line[2]}{$line[0]} eq '-5p'){
				compare_matures(\%pre_put,$line[0],$line[1],$line[2],'5p');
			}elsif($pre_arf{$line[2]}{$line[0]} eq '-3p'){
				compare_matures(\%pre_put,$line[0],$line[1],$line[2],'3p');
			}else{
				die "error with miR ".$line[0]." the 5p/3p position haven't be asign correctly";
			}
	# on test si le mature corrspond au pre (sans tenir compte ici des multilocalisations)
	}elsif(lc($$mir{mir_id}) eq lc($$precursor{pre_prefix})){
			# si on a pu localiser sa position dans le fichier arf d'alignement
			if($pre_arf{$line[2]}{$line[0]} eq '-5p'){
				if(!$pre{$line[2]}{"-5p"} || $pre{$line[2]}{"-5p"} < $line[1]){
					$pre{$line[2]}{"-5p"} = $line[1];
					$pre{$line[2]}{"5p"} = $line[0];
				}
			}elsif($pre_arf{$line[2]}{$line[0]} eq '-3p'){
				if(!$pre{$line[2]}{"-3p"} || $pre{$line[2]}{"-3p"} < $line[1]){
					$pre{$line[2]}{"-3p"} = $line[1];
					$pre{$line[2]}{"3p"} = $line[0];
				}
			}else{
				die "error with miR ".$line[0]." the 5p/3p position haven't be asign correctly";
			}
# 			print $line[2]."\t".$i."\n";
			$i++;
	}else{
			# si on a pu localiser sa position dans le fichier arf d'alignement
			if($pre_arf{$line[2]}{$line[0]} eq '-5p'){
				compare_matures(\%pre_autre,$line[0],$line[1],$line[2],'5p');
			}elsif($pre_arf{$line[2]}{$line[0]} eq '-3p'){
				compare_matures(\%pre_autre,$line[0],$line[1],$line[2],'3p');
			}else{
				die "error with miR ".$line[0]." the 5p/3p position haven't be asign correctly";
			}
	}
	$vus{$line[2]}++;
}

# print  "########### Total number \%pre : ".scalar(keys(%pre))."\n\n";
# print  "########### Total number \%pre_autre : ".scalar(keys(%pre_autre))."\n\n";
# print  "########### Total number \%pre_put : ".scalar(keys(%pre_put))."\n\n";

my @nb5and3;
my @nb5alone;
my @nb5andNew3;
my @nb3alone;
my @nb3andNew5;

my @nb5Putand3Put;
my @nb5Knand3Put;
my @nb5Putand3Kn;
my @nb5Knand3Kn;
my @nb5alonePut;
my @nb5aloneKn;
my @nb3alonePut;
my @nb3aloneKn;

close EXP;


print STDERR "\nPrint the results.\n";

foreach my $k(keys(%vus)){
	if($pre{$k}{'-5p'} && $pre{$k}{'-3p'}){
# 		if($debug){print "-5p -3p\t";}
		$matures{$pre{$k}{"5p"}}{$k} =~ s/(\S+\s\S+\s\S+)\s(.+)/$1\t5p\t$2/;
		print $matures{$pre{$k}{"5p"}}{$k}."\t".$matures_arf{$pre{$k}{"5p"}}."\n";
		$matures{$pre{$k}{"3p"}}{$k} =~ s/(\S+\s\S+\s\S+)\s(.+)/$1\t3p\t$2/;
		print $matures{$pre{$k}{"3p"}}{$k}."\t".$matures_arf{$pre{$k}{"3p"}}."\n";
		push(@nb5and3,$k);
	}elsif($pre{$k}{'-5p'}){
# 		if($debug){print "-5p \t";}
		$matures{$pre{$k}{"5p"}}{$k} =~ s/(\S+\s\S+\s\S+)\s(.+)/$1\t5p\t$2/;
		print $matures{$pre{$k}{"5p"}}{$k}."\t".$matures_arf{$pre{$k}{"5p"}}."\n";
		# test if we fund a 3p putatif
		if($pre_autre{$k}{'-3p'}){
# 			if($debug){print "-5p put3p\t";}
			$matures{$pre_autre{$k}{'3p'}}{$k} =~ s/(\S+\s\S+\s\S+)\s(.+)/$1\t3p\t$2/;
			print $matures{$pre_autre{$k}{'3p'}}{$k}."\t".$matures_arf{$pre_autre{$k}{'3p'}}."\n";
			push(@nb5andNew3,$k);
		}else{
			push(@nb5alone,$k);
		}
	}elsif($pre{$k}{'-3p'}){
# 		if($debug){print "-3p \t";}
		$matures{$pre{$k}{"3p"}}{$k} =~ s/(\S+\s\S+\s\S+)\s(.+)/$1\t3p\t$2/;
		print $matures{$pre{$k}{"3p"}}{$k}."\t".$matures_arf{$pre{$k}{"3p"}}."\n";
		# test if we fund a 5p putatif
		if($pre_autre{$k}{'-5p'}){
# 			if($debug){print "-3p put5p\t";}
			$matures{$pre_autre{$k}{'5p'}}{$k} =~ s/(\S+\s\S+\s\S+)\s(.+)/$1\t5p\t$2/;
			print $matures{$pre_autre{$k}{'5p'}}{$k}."\t".$matures_arf{$pre_autre{$k}{'5p'}}."\n";
			push(@nb3andNew5,$k);
		}else{
			push(@nb3alone,$k);
		}
	# cas ou le miR principal est un autre miR
	}elsif($pre_autre{$k}{'-5p'}){
		$matures{$pre_autre{$k}{'5p'}}{$k} =~ s/(\S+\s\S+\s\S+)\s(.+)/$1\t5p\t$2/;
		print $matures{$pre_autre{$k}{'5p'}}{$k}."\t".$matures_arf{$pre_autre{$k}{'5p'}}."\n";
		print STDERR "! ".$k." a pour seul mature detecté le miR ".$matures{$pre_autre{$k}{'5p'}}{$k}."\n";
		push(@nb5alone,$k);
	}elsif($pre_autre{$k}{'-3p'}){
		$matures{$pre_autre{$k}{'3p'}}{$k} =~ s/(\S+\s\S+\s\S+)\s(.+)/$1\t3p\t$2/;
		print $matures{$pre_autre{$k}{'3p'}}{$k}."\t".$matures_arf{$pre_autre{$k}{'3p'}}."\n";
		print STDERR "! ".$k." a pour seul mature detecté le miR ".$matures{$pre_autre{$k}{'3p'}}{$k}."\n";
		push(@nb3alone,$k);
	# cas particulier des pre_miRNA putatifs	
	}elsif($pre_put{$k}{'-5p'} && $pre_put{$k}{'-3p'}){
# 		if($debug){print "-5p -3p\t";}
		$matures{$pre_put{$k}{"5p"}}{$k} =~ s/(\S+\s\S+\s\S+)\s(.+)/$1\t5p\t$2/;
		print $matures{$pre_put{$k}{"5p"}}{$k}."\t".$matures_arf{$pre_put{$k}{"5p"}}."\n";
		my $mat5p = parse_mature_id($pre_put{$k}{"5p"});
# 		if($debug){print "-5p -3p\t";}
		$matures{$pre_put{$k}{"3p"}}{$k} =~ s/(\S+\s\S+\s\S+)\s(.+)/$1\t3p\t$2/;
		print $matures{$pre_put{$k}{"3p"}}{$k}."\t".$matures_arf{$pre_put{$k}{"3p"}}."\n";
		my $mat3p = parse_mature_id($pre_put{$k}{"3p"});
		if($$mat5p{is_putatif} && $$mat3p{is_putatif}){
			push(@nb5Putand3Put,$k);
		}elsif(!$$mat5p{is_putatif} && $$mat3p{is_putatif}){
			push(@nb5Knand3Put,$k);
		}elsif($$mat5p{is_putatif} && !$$mat3p{is_putatif}){
			push(@nb5Putand3Kn,$k);
		}else{
			push(@nb5Knand3Kn,$k);
		}
	}elsif($pre_put{$k}{'-5p'}){
# 		if($debug){print "-5p \t";}
		$matures{$pre_put{$k}{"5p"}}{$k} =~ s/(\S+\s\S+\s\S+)\s(.+)/$1\t5p\t$2/;
		print $matures{$pre_put{$k}{"5p"}}{$k}."\t".$matures_arf{$pre_put{$k}{"5p"}}."\n";
		my $mat5p = parse_mature_id($pre_put{$k}{"5p"});
		# test if we fund a 3p putatif
		if($pre_autre{$k}{'-3p'}){
# 			if($debug){print "-5p put3p\t";}
			die "error : on ne devrait pas etre la...";
			$matures{$pre_autre{$k}{'3p'}}{$k} =~ s/(\S+\s\S+\s\S+)\s(.+)/$1\t3p\t$2/;
			print $matures{$pre_autre{$k}{'3p'}}{$k}."\t".$matures_arf{$pre_autre{$k}{'3p'}}."\n";
		}else{
			if($$mat5p{is_putatif}){
				push(@nb5alonePut,$k);
			}else{
				push(@nb5aloneKn,$k);
			}
		}
	}elsif($pre_put{$k}{'-3p'}){
# 		if($debug){print "-3p \t";}
		$matures{$pre_put{$k}{"3p"}}{$k} =~ s/(\S+\s\S+\s\S+)\s(.+)/$1\t3p\t$2/;
		print $matures{$pre_put{$k}{"3p"}}{$k}."\t".$matures_arf{$pre_put{$k}{"3p"}}."\n";
		my $mat3p = parse_mature_id($pre_put{$k}{"3p"});
		# test if we fund a 5p putatif
		if($pre_autre{$k}{'-5p'}){
# 			if($debug){print "-3p put5p\t";}
			die "error : on ne devrait pas etre la...";
			$matures{$pre_autre{$k}{'5p'}}{$k} =~ s/(\S+\s\S+\s\S+)\s(.+)/$1\t5p\t$2/;
			print $matures{$pre_autre{$k}{'5p'}}{$k}."\t".$matures_arf{$pre_autre{$k}{'5p'}}."\n";
		}else{
			if($$mat3p{is_putatif}){
				push(@nb3alonePut,$k);
			}else{
				push(@nb3aloneKn,$k);
			}
		}
	}else{
		warn "! ERROR mir: $k n'a pas été classé en 5p ou 3p putatif\n";
		exit 0;
	}
}


 print STDERR "######################## General statistics precursors ############\n\n";
 print STDERR "# Total number of presursors in file: ".scalar(keys(%pre))."\n\n";
 print STDERR "######################## Know precursors ############\n\n";
 print STDERR "# Total number of Know presursors : ".(scalar(@nb5and3)+scalar(@nb5alone)+scalar(@nb3alone)+scalar(@nb5andNew3)+scalar(@nb3andNew5))."\n";
 print STDERR "# nb pre with know 5p and 3p mature detected : ".scalar(@nb5and3)."\n";
 print STDERR "# nb pre with only know 5p mature detected : ".scalar(@nb5alone)."\n";
 print STDERR "# nb pre with only know 3p mature detected : ".scalar(@nb3alone)."\n";
 print STDERR "# nb pre with know 5p mature detected and annoted 3p detected (by homologie with mature from other species) : ".scalar(@nb5andNew3)."\n";
 print STDERR "# nb pre with know 3p mature detected and annoted 5p detected (by homologie with mature from other species) : ".scalar(@nb3andNew5)."\n\n";
 print STDERR "######################## putatifs precursors ############\n\n";
 print STDERR "# Total number of putatifs presursors : ".scalar(keys(%pre_put))."\n";
 print STDERR "# nb putative pre with 5p and 3p mature detected : ".(scalar(@nb5Putand3Put)+scalar(@nb5Knand3Put)+scalar(@nb5Knand3Kn)+scalar(@nb5Putand3Kn))."\n";
 print STDERR "# ---- nb putative pre with annoted 5p and 3p mature detected : ".scalar(@nb5Knand3Kn)."\n";
 print STDERR "# ---- nb putative pre with annoted 5p and new putatif 3p mature detected : ".scalar(@nb5Knand3Put)."\n";
 print STDERR "# ---- nb putative pre with new putatif 5p and annoted 3p mature detected : ".scalar(@nb5Putand3Kn)."\n";
 print STDERR "# ---- nb putative pre with new putatif 5p and 3p mature detected : ".scalar(@nb5Putand3Put)."\n\n";
 print STDERR "# nb putative pre with only 5p mature detected : ".(scalar(@nb5alonePut)+scalar(@nb5aloneKn))."\n";
 print STDERR "# ---- nb putative pre with only annoted 5p mature detected : ".scalar(@nb5aloneKn)."\n";
 print STDERR "# ---- nb putative pre with only new putatif 5p mature detected : ".scalar(@nb5alonePut)."\n\n";
 print STDERR "# nb putative pre with only 3p mature detected : ".(scalar(@nb3alonePut)+scalar(@nb3aloneKn))."\n";
 print STDERR "# ---- nb putative pre with only annoted 3p mature detected : ".scalar(@nb3aloneKn)."\n";
 print STDERR "# ---- nb putative pre with only new putatif 3p mature detected : ".scalar(@nb3alonePut)."\n\n";
 
sub compare_matures {
	my $prec = shift;
	my $cur_mat = shift;
	my $cur_ct = shift;
	my $cur_pre = shift;
	my $put_pos = shift;
	
	my $cur_mature = parse_mature_id($cur_mat);
	my $cur_precursor = parse_precursor_id($cur_pre);
	
	my $assign_current;
	
# 	if($debug){print "test for assignation mature \"$cur_mat\" to : precursor =  $cur_pre\t position: $put_pos\t precursor name : ".$$cur_precursor{pre_name}."\n ";}
	
	# if there is no previous for this precursor
	if( !$$prec{$cur_pre}{$put_pos}){
		$assign_current++;
	}else{
		my $previous_mature = parse_mature_id($$prec{$cur_pre}{$put_pos});
		
#	if($debug){print "     previous mature: ".$$prec{$cur_pre}{$put_pos}."\t previous mature name : ".$$previous_mature{name}."\t previous mature spec : ".$$previous_mature{spec}."\n";}
#	if($debug){print "     CURRENT mature: ".$cur_mat."\t current mature name : ".$$cur_mature{name}."\t curent mature spec : ".$$cur_mature{spec}."\n";}
		
		if($$prec{$cur_pre}{"-".$put_pos} < $cur_ct ){
			$assign_current++;
		# if mature previouly associated got the same name and same species as the current precusrseur, and is not a putatif miRNA, he is the best
		}elsif(lc($$previous_mature{name}) eq lc($$cur_precursor{pre_name}) && lc($$previous_mature{spec}) eq lc($$cur_precursor{spec}) && !$$previous_mature{is_putatif}){
			return;
		# else if mature associated got the same count as the current mature
		}elsif($$prec{$cur_pre}{"-".$put_pos} == $cur_ct){
			# then we have to check if the current is better than the previous in terme of annotation
			# if the previous is a putatif and not the current
			if($$previous_mature{is_putatif} && !$$cur_mature{is_putatif}){
				$assign_current++;
			# if the previous is not a putatif and the current is putatif
			}elsif(!$$previous_mature{is_putatif} && $$cur_mature{is_putatif}){
				return;
			# if the current got the same name as the current precursor
			}elsif(lc($$cur_mature{name}) eq lc($$cur_precursor{pre_name})){
				# if the current mature got the same species as the current precursor
				if(lc($$cur_mature{spec}) eq lc($$cur_precursor{spec})){
					$assign_current++;
				# if the previous mature got the same name as the current precursor
				}elsif(lc($$previous_mature{name}) eq lc($$cur_precursor{pre_name})){
					# equality
					# if the current mature got the putative position and the previous don't have
					if($$cur_mature{pos} && !$$previous_mature{pos}){
						$assign_current++;
					}
				}
			# if the current got the same species as the current precursor
			}elsif(lc($$cur_mature{spec}) eq lc($$cur_precursor{spec})){
				# if the previous mature don't have the same name as the current precursor
				if(lc($$previous_mature{name}) ne lc($$cur_precursor{pre_name})){
					# if the previous mature don't have the same species
					if(lc($$previous_mature{spec}) ne lc($$cur_precursor{spec})){
						$assign_current++;
					# if have the same species but not a putative position and the current got the putative position,
					}elsif(!$$previous_mature{pos} && $$cur_mature{pos}){
						$assign_current++;
					}
				}
			# if the current don't got the species, don't got the name, but got a putative position
			}elsif($$cur_mature{pos}){
				# if the previous don(t have the name, the species and position
				if((lc($$previous_mature{name}) ne lc($$cur_precursor{pre_name}) && (lc($$previous_mature{spec}) ne lc($$cur_precursor{spec})) && (!$$previous_mature{pos}))){
					$assign_current++;
				}
			}
		}	
	} 
	if($assign_current){
		$$prec{$cur_pre}{"-".$put_pos} = $cur_ct;
		$$prec{$cur_pre}{"-".$put_pos."_N"} = $$cur_precursor{pre_name};
		$$prec{$cur_pre}{$put_pos} = $cur_mat;
	}
# 	if($debug){print " assignation result : $assign_current\n"};
 }
 
 sub parse_mature_id {
	my $id = shift;
	my $mir;
	
# 	if($debug){print "parse_mature_id $id\n"};
	
	if($id =~ /^$mature_shape$/){
		$$mir{mir_id} = $1.$2.$4.$5;
		$$mir{long_mature_id} =  $1.$2.$4.$5.$6;
		$$mir{pos}=$7;
		$$mir{spec}=$1;
		$$mir{name}= $2.$5.$6;
		if($4 ne ""){
			$$mir{is_putatif}=1;
		}
# 		if($debug){print "debug 1:$1 2:$2 3:$3 4:$4 5:$5 6:$6 7:$7 \n"};
	}else{
		print STDERR "! ".$id." n'a pas une forme de mature reconnue -> skip line $_ \n";
	}
	return $mir;
 }
 
 sub parse_precursor_id {
	my $id = shift;
	my $precursor;
	
# 	if($debug){print "parse_precursor_id $id\n"};
	
	# read the pre id 
	if($id =~ /^$pre_shape$/){
		$$precursor{pre_prefix} = $1.$2.$4;
		$$precursor{long_pre_prefix}= $1.$2.$4.$5;
		$$precursor{pre_name} = $2.$4.$5;
		$$precursor{spec}=$1;
# 		if($debug){print "id: ".$id." pre_prefix: ".$$precursor{pre_prefix}." long_pre_prefix: ".$$precursor{long_pre_prefix}." pre_name: ".$$precursor{pre_name}." spec: ".$$precursor{spec}."\n";}
	}else{
		print STDERR "! ".$id." n'a pas une forme de pre reconnue -> skip line $_ \n";
	}
	return $precursor;
 }
 
=pod

=head1 NAME

parse_miRDeep2_output.pl

=head1 SYNOPSIS

parse_miRDeep2_output.pl --mature_arf <.arf file> --expression_file <.csv file> --structure_file  <.mrd file> 

=head1 DESCRIPTION
	
	parse_miRDeep2_output.pl assigns mature miRNAs to a set of precursors, and report the quantification of the best two mature (3p & 5p predicted from their position on the precursor) observed for each precursor.
	
	This script reads the output files provided by the quantifier.pl module from miRdeep2 and assigns the matures to the precursors by using the following order of priority:
	
		- Mature known in the species studied (generaly all matures from miRBase known for the species are used)
		
		- Mature known in another species (all mature from miRBase, or only those corresponding to a subset of closely related species are used). In case where several mature are detected, mature with the highest count is chosen.
		
		- Mature unknown (generaly matures predicted by miRDeep2.pl module are used)
	
	# attempted know mature id should have following shape : (\w{3})(-[^-]+-\d+)([a-z]{0,2})([.-]\d{1,2})?(-\d{1}p)? (ex : mmu-mir-181a-1)
	# attempted know precursor id should have following shape : (\w{3})(-[^-]+-\d+)([a-z]{0,2})(-\d{1,2})? (ex : mmu-miR-181a-1-3p)
	# attempted putatif mature id should have following shape : (ex : mmu-26_25392-1-5p )
	# attempted putatif precursor id should have following shape : (\w{3})(-[^_]+_\d+)(-\d{1,2}) (ex : mmu-26_25392-1 )

Options:

	--mature_arf	: path to the file mature_XXX_mapped.arf (provided by the miRDeep2 quantifier.pl module)

	--expression_file	: path to the file miRNAs_expressed_all_samples_XXX.csv (provided by the miRDeep2 quantifier.pl module)

	--structure_file	: path to the miRBase.mrd file (provided by the miRDeep2 quantifier.pl module, can be found in the folder expression_analyses_XXX)
           
=head1 AUTHORS

Sylvain Marthey <sylvain.marthey@jouy.inra.fr>

=head1 VERSION

1.4

=head1 DATE

2017

=head1 KEYWORDS

miRNA, miRDeep2, annotation, quantification

=head1 EXAMPLE

parse_miRDeep2_output --mature_arf mature_mapped.arf --expression_file miRNAs_expressed_all_samples_1372870072.csv --structure_file  miRBase.mrd

=cut