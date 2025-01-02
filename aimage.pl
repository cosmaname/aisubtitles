#!/usr/bin/env perl

use v5.34.0;

use FindBin qw( $RealBin );
use lib $RealBin;

use strict;
use warnings;
use aimage;

my $file = shift or die "Usage: $0 <image_filename>";

my $chat     = aimage->new;
my $response = $chat->describe_image($file);
say($response);
