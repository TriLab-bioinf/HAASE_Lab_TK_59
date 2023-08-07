#!/usr/bin/perl
use strict;

my $usage = "$0 -a <reference annotation bed> -b <bed 2>\n\n";
my %arg = @ARGV;

die $usage unless $arg{-a} && $arg{-b};

# Load a file
my %a;
open (BED1, "<$arg{-a}") || "ERROR I cannot open $arg{-a}: $!\n\n";
while(<BED1>){
    chomp;
    my ($chr, $e5, $e3, $cov, $strand, $exon_num, $gene_id, $tr_id, $igv) = split /\t/;
    my $gt = "$gene_id:$tr_id";
    ($e5, $e3) = ($e3, $e5) if $strand eq '-';
    my $ch_e5 = "$chr:$e5"; 

     # using array to store many isoforms within the same array element called with the chr ID and end5 ID
    push @{$a{$ch_e5}}, {
        'chr' => $chr,
        'e5' => $e5,
        'e3' => $e3,
        'cov' => $cov,
        'strand' => $strand,
        'exon_num' => $exon_num,
        'gene_id' => $gene_id,
        'tr_id' => $tr_id,
        'gt' => $gt,
        'igv' => $igv

    };
}
close BED1;

# Load b file
my %b;
open (BED2, "<$arg{-b}") || "ERROR I cannot open $arg{-b}: $!\n\n";
while(<BED2>){
    chomp;
    my ($chr, $e5, $e3, $cov, $strand, $exon_num, $gene_id, $tr_id, $igv) = split /\t/;
    my $gt = "$gene_id:$tr_id";
    ($e5, $e3) = ($e3, $e5) if $strand eq '-';
    my $ch_e5 = "$chr:$e5"; 

    # Store 3pExon if the 5'end matches a reference 3pExon
    if ($a{$ch_e5}){
        $b{$igv} = {
            'chr' => $chr,
            'e5' => $e5,
            'e3' => $e3,
            'cov' => $cov,
            'strand' => $strand,
            'exon_num' => $exon_num,
            'gene_id' => $gene_id,
            'tr_id' => $tr_id,
            'gt' => $gt
        };

        
        # $ifm = reference isoform
        foreach my $ifm ( @{$a{$ch_e5}} ){
            my $diff;
            if ($strand eq "+"){ 
                $diff = $ifm->{e3} - $e3;    
            } else {
                $diff = $e3 - $ifm->{e3};
            }
            print "$ifm->{chr}\t$ifm->{e5}\t$ifm->{e3}\t$ifm->{strand}\t$ifm->{gene_id}\t$ifm->{tr_id}\t$e5\t$e3\t$gene_id\t$tr_id\t$ifm->{igv}\t$diff\n";
        }
    }
}
close BED2;

