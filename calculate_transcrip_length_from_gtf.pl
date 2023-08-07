#!/Users/lorenziha/opt/anaconda3/bin/perl
use strict;

# Programs
my $bedtools = '/Users/lorenziha/opt/anaconda3/envs/tk_59/bin/bedtools';

my $usage = "$0 -g <annotation gtf file>\n\nExample:\n\n$0 -g Mus_musculus.GRCm38.102.gtf | tee gene_exonic_lenghts.ensembl.txt\n\nThis program will merge all exons from a single gene before estimating the total transcript length\n\nIt requires bedtools\n\n";
my %arg = @ARGV;
die $usage unless $arg{-g};

# Read GTF file and store gene coords in array with key=gene_id
my %gene_ids;
my %nr; # track redundant exons
open (GTF, "<$arg{-g}") || die "ERROR, I cannot open $arg{-g}: $!\n\n";
while(<GTF>){
    chomp;
    my @x = split /\t/;
    next unless $x[2] eq 'exon';

    my $nr_id = "$x[0].$x[3].$x[4]";
    $nr{$nr_id}++;

    next if $nr{$nr_id} > 1; # skip redundant exons

    # Get gene_id
    my $gene_id = $1 if $x[8] =~ m/gene_id\s"(\S+)"/;
    unless ($gene_id){
        warn "NO GENE_ID FOUND for exon feature:\n$_\n";
    }

    $x[3]-=1;

    push @{$gene_ids{$gene_id}}, "$x[0]\t$x[3]\t$x[4]\t.\t$x[6]";
}
close GTF;

# Process GTF data
foreach my $gene_id (keys %gene_ids){
    

    # Create tmp.bed file with exons from single gene
    my @gene = @{$gene_ids{$gene_id}};
    open (TMP, ">tmp.bed");
    foreach my $exon (@gene){
        print TMP "$exon\n";
    }
    close TMP;

    # Sort tmp.bed file by coord
    system("sort -k2n tmp.bed > tmp.sorted.bed");

    print "$gene_id\t";
    my $err = system($bedtools.' merge -i tmp.sorted.bed | perl -e \'while(<>){chomp; @x=split /\t/; $len += abs($x[2]-$x[1]);} print "$len\n"\'');
    if ($err){print "NA\n"}
}