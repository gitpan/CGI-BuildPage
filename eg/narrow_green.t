#!/usr/bin/perl

use strict;
use Data::Dumper;

use CGI::BuildPage;

my $q = new CGI::BuildPage({});

$q->no_header();

$q->layout('narrow', 'green');

	$q->title("Title of the document");

$q->add_left('Our Web site');

	$q->add("Welcome to out green web site of our Green company");

	$q->add('<BR>New line');

$q->hr;

	$q->add('New line');

$q->print_out();

__END__

