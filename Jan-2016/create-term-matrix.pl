#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(say);

use Encode qw(decode_utf8 encode_utf8);
use File::Slurper qw(read_lines);
use Search::Xapian;
use utf8::all;

my @stop_words = read_lines('stop-words');
my $stop = Search::Xapian::SimpleStopper->new(@stop_words);
my $stem = Search::Xapian::Stem->new('en');

my @lines = <>;
chomp @lines;

my %unique_lines;
my @term_to_lines;

my @index_to_term;
my %term_to_index;

open my $fh, '>', 'lines';
my $line_number = 1;
for my $line (@lines) {
    $line =~ s{\bhttp[s]?:\S+}{}g; # remove URLS
    my @terms = $line =~ /\p{Alnum}+/g;

    @terms = grep { !/\p{Cyrillic}/ } @terms;
    @terms = map { lc() } @terms;
    @terms = grep { !$stop->stop_word($_) } @terms;
    @terms = map { decode_utf8($stem->stem_word(encode_utf8($_))) } @terms;

    my $index_line = join(' ', @terms);
    if($unique_lines{$index_line}) {
        next;
    }
    say {$fh} $index_line;
    $unique_lines{$index_line} = 1;

    for my $term (@terms) {
        my $index = $term_to_index{$term};

        unless(defined $index) {
            push @index_to_term, $term;
            $term_to_index{$term} = $index = $#index_to_term;
        }

        my $lines = ($term_to_lines[$index] //= []);
        $lines->[$line_number]++;
    }
    $line_number++;
}
close $fh;

for my $index (0..$#term_to_lines) {
    my $term_no = $index + 1;

    my $lines = $term_to_lines[$index];

    for my $line_no (0..@$lines) {
        my $term_line_count = $lines->[$line_no];
        next unless $term_line_count;
        say "$term_no $line_no $term_line_count";
    }
}

open $fh, '>', 'terms';
say {$fh} $_ for @index_to_term;
close $fh;
