#!/usr/bin/env perl

use v5.34.0;
use strict; use warnings;
use open qw( :std :encoding(UTF-8) );
use FindBin qw( $RealBin ); use lib $RealBin;
use atranslate;

my $file = shift or die "Usage: $0 <text_filename>";

my $chat     = atranslate->new;
my $response = $chat->translate_file($file);

say($response);
