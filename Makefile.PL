
use ExtUtils::MakeMaker;
WriteMakefile(
	NAME		=> 'CGI::BuildPage',
	VERSION_FROM	=> 'CGI/BuildPage.pm',
	dist		=> { COMPRESS => 'gzip -9f', SUFFIX => 'gz',
		POSTOP => 'mv $(DISTNAME)-$(VERSION).tar.gz ../' },
	);

