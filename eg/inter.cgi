#!/usr/bin/perl

use strict;

BEGIN { unshift @INC, ( -d 'eg' ? '.' : '..'); }

use CGI::BuildPage;

my $q = new CGI::BuildPage();

my ($layout, $inst) = ($q->param('layout'), $q->param('inst'));

if (not grep { $layout eq $_ } qw( plain white wide narrow ))
	{ $layout = 'white'; }

if (not grep { $inst eq $_ } qw( green blue ))
	{ $inst = ''; }
	
$q->layout($layout, $inst);

	$q->title('Interactive CGI::BuildPage demo');

	$q->add("Welcome to the interactive CGI::BuildPage module
	demo. In the following form, select the visual aspects of the
	page.");
	
	$q->flush;

$q->add_left('Select layout');

	$q->startform(-method => 'GET');
	$q->textfield('layout', 'wide');
	$q->add("<P>\n");

	$q->flush;

$q->add_left('Select inst');
	$q->textfield('inst', 'green');


	$q->add("<BR>\n");
	$q->submit('Submit');
	$q->endform;

$q->hr;

	$q->add('Possible values for layout are: wide, narrow, white,
	plain. For institution, currently use green or blue.');

$q->print_out();

__END__

