#!/usr/bin/perl

use strict;
use Data::Dumper;

use CGI::BuildPage;

my $q = new CGI::BuildPage({});

$q->no_header();

$q->layout('wide', 'blue');

	$q->title("Title of the document");

$q->add_left('Our Web site');

	$q->add("Welcome to our blue web site of our Blue company");

	$q->add('<BR>New line');
	$q->startform;
	$q->textfield('name');
	$q->submit('Sumbit it');
	$q->endform;

$q->hr;

	$q->add('New line');

$q->print_out();

