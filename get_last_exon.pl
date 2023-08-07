#!/usr/bin/perl
use strict;

my (%transcript, %exon, %coverage);

while(<>){
    chomp;
    
    # fetch exon info per line
    my @x = split /\t/;

    next unless $x[2] eq 'exon';
    
    my ($chr, $exon_e5, $exon_e3, $strand, $info) = ($x[0], $x[3], $x[4], $x[6], $x[8]);
    my $gene_id = $1 if $info =~ m/gene_id\s"(\S+)"/;
    my $transcript_id = $1 if $info =~ m/transcript_id\s"(\S+)"/;
    my $exon_num = $1 if $info =~ m/exon_number\s"(\d+)"/;
    my $exon_cov = $1 if $info =~ m/cov\s"(\S+)"/ || -1;
    
    # Check if it's the 3' exon
    if ($transcript{$transcript_id}{num} < $exon_num){
        # Update exon coords
        $exon_e5 = $exon_e5-1; # to make it bed compliance
        $transcript{$transcript_id} = {'num' => $exon_num,
                                       'gid' => $gene_id,
                                       'e5' => $exon_e5,
                                       'e3' => $exon_e3,
                                       'cov' => $exon_cov,
                                       'chr' => $chr,
                                       'strand' => $strand,
                                       'igv' => "$chr:$exon_e5-$exon_e3",
                                       };
    }
}

# Print out 3' exons and remove redundant 3' exons that have exactly the same coords (to eliminate isoforms that are just different on other exons)
my %nr;
foreach my $tr_id (keys %transcript){
    my $tr = $transcript{$tr_id};
    $nr{$tr->{igv}}++;
    print "$tr->{chr}\t$tr->{e5}\t$tr->{e3}\t$tr->{cov}\t$tr->{strand}\t$tr->{num}\t$tr->{gid}\t$tr_id\t$tr->{igv}\n" unless $nr{$tr->{igv}} > 1;
}