#!/usr/bin/env perl

#===================================================
# Author: Chih-Hsuan Wei
# Software: SR4GN
#===================================================

#=====
#parameters
my $sentence_extraction = "sentence.xml";
my $table_extraction = "table.xml";
my $tax_extraction = "tax.xml";
my $gmention_extraction = "gmention.xml";
my $sa_extraction = "sa.xml";
my $BioC_extraction = "BioC.xml";

#=====
#Splitting articles to sentences.
sub Pre_processing
{
	my $output_route = @_[0];
	my $filename = @_[1];
	my $context = @_[2];
	my $Sentence_Insertion = @_[3];
	my $format = @_[4];
	if($Sentence_Insertion eq "True")
	{
		require 'Pre_Processing/insert_training_articles.pl';
		if($format eq "BioC")
		{
			PreProcessing::Sentence_Insertion_BioC($output_route,$context,$filename."_".$sentence_extraction,$filename."_".$table_extraction);
		}
		else
		{
			PreProcessing::Sentence_Insertion($output_route,$context,$filename."_".$sentence_extraction,$filename."_".$table_extraction);
		}
	}
}

#=====
#Gene Name Recognition.
#1.Extracting gene mentions by AIIA-GMT.
#2.Extracting possible gene identifiers. User may use all kinds of gene/protein identifiers(Such as swissprot id) to identify these mentions. 
sub GNR
{
	my $output_route = @_[0];
	my $filename = @_[1];
	my $Tagged_by_AIIA = @_[2];
	
	if($Tagged_by_AIIA eq "True")
	{	
		require 'GNR/tagged_by_aiia.pl';
		GNR::Tagged_by_AIIA($output_route,$filename."_".$sentence_extraction,$filename."_".$gmention_extraction);
	}
}

#=====
#Species Name Indentification.
#SR module focuses on species and cell names.  
sub SR
{
	my $output_route = @_[0];
	my $filename = @_[1];
	my $species_name_extraction = @_[2];
	my $cellline_extraction = @_[3];
	my $Disambiguation_by_Co_Occurrence = @_[4];
	my $Filtering = @_[5];

	if($species_name_extraction eq "True")
	{
		require 'SR/species_name_extraction.pl';
		SR::species_name_extraction($output_route,$filename."_".$sentence_extraction,$filename."_".$tax_extraction);
		require 'SR/cellline_extraction.pl';
		SR::cellline_extraction($output_route,$filename."_".$sentence_extraction,$filename."_".$tax_extraction);
		require 'SR/sub_type_matching.pl';
		SR::Disambiguation_by_Co_Occurrence($output_route,$filename."_".$sentence_extraction,$filename."_".$tax_extraction);
		require 'SR/filtering.pl';
		SR::Filtering($output_route,$filename."_".$sentence_extraction,$filename."_".$tax_extraction);
	}
}

#=====
#Species Assignment.
#SA module assignes species identifier(Taxonomy ID) to each gene mentions.(excluding Candidate_ID) 
sub SA
{
	my $output_route = @_[0];
	my $filename = @_[1];
	my $Species_Assignment = @_[2];

	if($Species_Assignment eq "True")
	{
		if(-e $output_route."/".$filename."_gmention.xml")
		{
			require 'SA/species_assignment.pl';
			SA::Species_Assignment($output_route,$filename."_".$sentence_extraction,$filename."_".$gmention_extraction,$filename."_".$tax_extraction,$filename."_".$sa_extraction);
		}
		else
		{
			die "\nSpecies assignment cannot be execute if Gene name recogniton(GNR) result is not exist.\n";
		}
	}
}

#=====
#BioC format
sub BioC_format
{
	my $output_route = @_[0];
	my $filename = @_[1];
	my $context = @_[2];
	
	my %Tax_annotation_hash=();
	open tax,"<".$output_route."/".$filename."_".$tax_extraction;
	while(<tax>)
	{
		my $tmp=$_;
		$tmp=~s/[\n\r]//g;
		if($tmp=~/<Tax sid='([0-9]+)\_([0-9]+)' start='([0-9]+)' end='([0-9]+)' tax_id='([0-9]+)'>(.+)<\/Tax>/)
		{
			my $paragraph=$1;
			my $sid=$2;
			my $start=$3;
			my $last=$4;
			my $tax_id=$5;
			my $tax_mention=$6;
			$Tax_annotation_hash{$paragraph."\t".$sid."\t".$start."\t".$tax_id."\t".$tax_mention}=1;			
		}
	}
	close tax;
	
	my %SA_annotation_hash=();
	open sa,"<".$output_route."/".$filename."_".$sa_extraction;
	while(<sa>)
	{
		my $tmp=$_;
		$tmp=~s/[\n\r]//g;
		if($tmp=~/<mention sid='([0-9]+)\_([0-9]+)' start='([0-9]+)' end='([0-9]+)' tax_id='([0-9]+)'>(.+)<\/mention>/)
		{
			my $paragraph=$1;
			my $sid=$2;
			my $start=$3;
			my $last=$4;
			my $tax_id=$5;
			my $gene_mention=$6;
			$SA_annotation_hash{$paragraph."\t".$sid."\t".$start."\t".$tax_id."\t".$gene_mention}=1;			
		}
	}
	close sa;
	
	my $STR_output="";
	my $para_count=1;
	my $annotation_id=0;
	while($context=~/^(.*?<offset>([0-9]+?)<\/offset>.*?)<text>(.+?)<\/text>(.*)$/)
	{
		my $pre=$1;
		my $offset=$2;
		my $text=$3;
		my $org_text=$3;
		my $post=$4;
		$text =~ s/\. ([A-Z\<\(])/\.\@\@\@\@$1/g;
		@split_text=split("@@@@",$text);
		my %offset_text_hash=();
		$offset_text_hash{1}=$offset;
		my $sid=2;
		foreach my $textt (@split_text)
		{
			$textt=~s/\&[\#A-Za-z0-9]+\;/\./g;
			$offset_text_hash{$sid}=$offset_text_hash{$sid-1}+length($textt)+1;
			$sid++;
		}
		$STR_output=$STR_output.$pre."";
		$STR_output=$STR_output."<text>$org_text</text>";
		
		#Annotation:
		foreach my $TAX (keys %Tax_annotation_hash)
		{
			if($TAX=~/^$para_count	([0-9]+)	([0-9]+)	([0-9]+)	(.+)$/)
			{
				my $sid = $1;
				my $start = $2;
				my $tax_id = $3;
				my $tax_mention = $4;
				$STR_output=$STR_output."<annotation id='".($annotation_id++)."'>\n<infon key=\"type\">Species</infon><location offset='".($offset_text_hash{$sid}+$start)."' length='".length($tax_mention)."' />\n<infon type='NCBI Taxonomy'>Tax:$tax_id</infon><text>$tax_mention</text></annotation>";
			}
		}
		foreach my $SA (keys %SA_annotation_hash)
		{
			if($SA=~/^$para_count	([0-9]+)	([0-9]+)	([0-9]+)	(.+)$/)
			{
				my $sid = $1;
				my $start = $2;
				my $tax_id = $3;
				my $tax_mention = $4;
				$STR_output=$STR_output."<annotation id='".($annotation_id++)."'>\n<infon key=\"type\">Gene</infon><location offset='".($offset_text_hash{$sid}+$start)."' length='".length($tax_mention)."' />\n<infon type='NCBI Taxonomy'>Tax:$tax_id</infon><text>$tax_mention</text></annotation>";
			}
		}
		$context=$post;
		$para_count++;
	}
	$STR_output=$STR_output.$context;
	open output,">".$output_route."/".$filename."_".$BioC_extraction;
	$STR_output=~s/(<(collection|document|passage|annotation)>)/$1\n/g;
	$STR_output=~s/(<\/([A-Za-z0-9\_]+)>)/$1\n/g;
	print output $STR_output."\n";
	close output;
}

sub main
{
	my $setup;
	my $folder_route;
	my $output_route;
	for(my $i=0;$i<@ARGV;$i++)
	{
		if($ARGV[$i] eq "-s")
		{
			$i++;
			$setup=$ARGV[$i];
		}
		elsif($ARGV[$i] eq "-i")
		{
			$i++;
			$folder_route=$ARGV[$i];
		}
		elsif($ARGV[$i] eq "-o")
		{
			$i++;
			$output_route=$ARGV[$i];
		}
		elsif($ARGV[$i]=~/^-s(.+)$/)
		{
			$setup=$1;
		}
		elsif($ARGV[$i]=~/^-i(.+)$/)
		{
			$folder_route=$1;
		}
		elsif($ARGV[$i]=~/^-o(.+)$/)
		{
			$output_route=$1;
		}
	}
	my %setup_hash=();
	
	if($folder_route eq "")
	{
		print "Instruction Format:\n\n\tperl SR4GN.pl -i [input dir] -o [output dir] -s [setup]\n";
		print "\te.g. perl SR4GN.pl -i input -o output -s setup_SR.txt\n";
	}
	elsif($output_route eq "")
	{
		print "Instruction Format:\n\n\tperl SR4GN.pl -i [input dir] -o [output dir] -s [setup]\n";
		print "\te.g. perl SR4GN.pl -i input -o output -s setup_SR.txt\n";
	}
	else
	{
		if($setup eq "")
		{
			$setup_hash{"Sentence_Insertion"} = "True";
			$setup_hash{"species_name_extraction"} = "True";
			print "Running speices recognition (SR) module...\n";
		}
		else
		{
			#=====
			#Read the setup-file 
			open setup,"<$setup";
			while(<setup>)
			{
				my $setup=$_;
				if ($setup=~/(\w+) = (\w+)/)
				{
					
					$setup_hash{$1}=$2;
					
				}
			}
			close setup;
			if ($setup_hash{"species_name_extraction"} eq "True") {print "Running species recognition (SR) module...\n";}
			if($setup_hash{"Tagged_by_AIIA"} eq "True") {print "Running gene name recognition (GNR) module...\n";}
			if($setup_hash{"Species_Assignment"} eq "True") {print "Running species assignment (SA) module...\n";}
		}
		#=====
		#SR4GN processing 
		opendir(DIR, $folder_route);
		@class = grep(/[a-z0-9]/,readdir(DIR));
		closedir(DIR);
		foreach $filename(@class)
		{
			my ($sec1,$min1,$hour1,$day,$mon,$year)=localtime(time);
			open article,"<$folder_route\/$filename";
			my $context="";
			my $while_count=0;
			while(<article>)
			{
				my $tmp=$_;
				$tmp=~s/[\n\r]//g;
				if($tmp=~/^[A-Z\(]/ && $context ne ""){
					$context=$context." ".$tmp;	
				}
				else{
					$context=$context.$tmp;
				}
			}
			close article;
			
			my $format="SR4GN";
			if($context=~/<infon key=\"type\">(front|title)<\/infon>/){	$format="BioC"; }
			
			#=====
			#Splitting articles to sentences
			Pre_processing($output_route,$filename,$context,$setup_hash{"Sentence_Insertion"},$format);
			
			#=====
			#Species Name Indentification
			SR($output_route,$filename,$setup_hash{"species_name_extraction"});
			
			#=====
			#Gene Name Recognition
			GNR($output_route,$filename,$setup_hash{"Tagged_by_AIIA"});
						
			#=====
			#Species Assignment
			SA($output_route,$filename,$setup_hash{"Species_Assignment"});
			
			if ($format eq "BioC")
			{
				print "BioC_format...\n";
				BioC_format($output_route,$filename,$context);
			}
			
			my ($sec2,$min2,$hour2,$day,$mon,$year)=localtime(time);
			my $timecost=((($hour2-$hour1)*60)+($min2-$min1)*60)+($sec2-$sec1);
			print "$folder_route\/$filename Finished in $timecost sec.\n";
		}
	}
}

main();
