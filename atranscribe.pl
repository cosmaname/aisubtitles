#!/usr/bin/env perl

use v5.34.0;
use strict; use warnings;
use FindBin qw( $RealBin ); use lib $RealBin;
use atranscribe;

my $filename = shift or die "Usage: $0 <audio_filename> <offset>";
my $offset   = shift or die "Usage: $0 <audio_filename> <offset>";

my $chat     = atranscribe->new;
my $response = $chat->transcribe_file($filename, $offset);

say($response);
