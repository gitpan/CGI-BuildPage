
=head1 NAME

CGI::BuildPage - object to hold and build page

=cut

#####################################################################
#####################################################################

package CGI::BuildPage;

use strict;
use vars qw( @ISA $VERSION %ICONS %OPTS @CHECK_PARAMS
					$WWWSERVER_PREFIX $PICS_PATH );
use CGI;

@ISA = qw( CGI );
$VERSION = '0.95';

%ICONS = (
	kolecko => [ 'kolecko.gif', 'kolecko', 'http://www.kolecko.com/' ],
	ctverecek => [ 'ctverecek.gif', 'ctverecek', 'http://www.ctverecek.com/' ],
	trojuhelnik => [ 'trojuhelnik.gif', 'trojuhelnik', 'http://www.trojuhelnik.com/' ],
	green_kolecko => [ 'green_kolecko.gif', 'green_kolecko', 'http://www.kolecko.com/' ],
	green_ctverecek => [ 'green_ctverecek.gif', 'green_ctverecek', 'http://www.ctverecek.com/' ],
	green_trojuhelnik => [ 'green_trojuhelnik.gif', 'green_trojuhelnik', 'http://www.trojuhelnik.com/' ],
	);
%OPTS = (
	## whole body of the page
	WHOLE_BODY => {
		default => sub { my $self = shift;
			$self->get_option('ADD_ICONS_TO_BODY');
			$self->get_option('ADD_SIGN_TO_BODY');
			$self->flush;

			( $self->get_option('START_BODY'),
			$self->get_option('TITLE'),
			$self->{'.content'},
			$self->get_option('END_BODY'), );
			},
		},	
	## start and the end
	START_BODY => {
		blue => {
			wide => "<TABLE NOBORDER><TR><TD WIDTH=140></TD><TD></TD></TR>\n",
			narrow => '<TABLE NOBORDER><TR><TD WIDTH=10></TD><TD>',
			},
		green => {
			wide => "<TABLE NOBORDER><TR><TD WIDTH=170></TD><TD></TD></TR>\n",
			narrow => '<TABLE NOBORDER><TR><TD WIDTH=10></TD><TD>',
			},
		},			
	END_BODY => {
		blue => {
			wide => "</TABLE>\n",
			narrow => '</TD></TR></TABLE>',
			},
		green => {
			wide => "</TABLE>\n",
			narrow => '</TD></TR></TABLE>',
			},
		},	
	## title
	TITLE => {
		default => {
			wide => sub { my $self = shift;
				( '<TR><TD>', $self->get_option('LOGO'),
				'</TD><TD><H1>', $self->{'.title'},
				"</H1></TD></TR>\n" ); },
			narrow => sub { my $self = shift;
				( '<TABLE><TR><TD>', $self->get_option('LOGO'),
				'</TD><TD><H1>', $self->{'.title'},
				"</H1></TD></TR></TABLE>\n" ); },
			default => sub { '<H1>', shift->{'.title'}, "</H1>\n" },
			},
		},
	## background image
	BACKGROUND => {
		blue => {
			wide => 'blue-back.gif',
			narrow => 'blue-narrow-back.gif',
			},
		green => {
			wide => 'green-back.gif',
			narrow => 'green-narrow-back.gif',
			},
		},
	
	## background color	
	BGCOLOR => {
		default => { white => 'white', },
		},
	TOPPIC => {
		blue => {
			wide => 'fi-logo.gif',
			narrow => 'fi-logo.gif',
			white => 'fi-logo.gif',
			},
		green => {
			wide => 'petrov.gif',
			narrow => 'petrov.gif',
			white => 'petrov.gif',
			},
		},

	## <HR>
	HRULE => {
		blue => {
			wide => [ 'blue-hr.gif', '- - - - - - -' ],
			narrow => [ 'blue-hr.gif', '- - - - - - -' ],
			},
		green => {
			wide => [ 'green-hr.gif', '- - - - - - -' ],
			narrow => [ 'green-hr.gif', '- - - - - - -' ],
			},
		default => "<HR>\n",
		},
	
	## company logo	
	LOGO => {
		blue => [ 'blue-small-logo.gif', 'Blue Co. Logo',
						'http://www.blue.com/' ],
		green => [ 'green-small-logo.gif', 'Blue Co. Logo',
						'http://www.green.com/' ],
		},
	
	## definition of the signature
	SIGN_VALUE => {
		blue => 'webmaster@blue.com',
		green => 'webmaster@green.com',
		},
	## actually printing the signature
	ADD_SIGN_TO_BODY => {
		default => sub { my $self = shift;
			$self->hr;

			my $sign = $self->{'.sign'};
			if (not defined $sign) { $sign = $self->get_option('SIGN_VALUE'); }
			$self->add($sign);
			'';
			},
		},

	DEFAULT_ICONS => {
		fi => [ 'brno', 'mu', 'fi', 'admin', 'charset', ],
		green => [],
		default => [],
		},
	
	ADD_ICONS_TO_BODY => {
		blue => sub { my $self = shift;
			$self->hr(); $self->add( map { get_opt_arr_ref($_) } @ICONS{qw( kolecko ctverecek trojuhelnik ) });
			$self->add($self->{'.icons'}) if defined $self->{'.icons'};
			''; },
		green => sub { my $self = shift;
			$self->hr(); $self->add( map { get_opt_arr_ref($_) } @ICONS{qw( green_trojuhelnik green_kolecko green_ctverecek ) });
			$self->add($self->{'.icons'}) if defined $self->{'.icons'};
			''; },
		},

	## Start and the end of the left column	
	LEFT_COL_START => {
		default => { 'wide' => '<FONT COLOR=#ffffff SIZE=5><B>' },
		green => { 'wide' => '<FONT SIZE=4><B>' },
		},
	LEFT_COL_END => {
		default => { 'wide' => '</B></FONT>' },
		},
	);


@CHECK_PARAMS = qw( kod semestr semester );
$PICS_PATH = '../pics';

# #############################################
# Create the new object -- similar to new CGI()
sub new
	{
	my $class = shift;
	my $do_log = 1;
	if (defined $_[0] and $_[0] =~ /^-?no_?log$/i)
		{ shift; $do_log = 0; }
	
	my $self = $class->SUPER::new(@_);	# Create the object
	
	$self->log_in() if $do_log;		# Log the start of the script
	$self->check_input_params();		# Check params for bad chars

	$self->layout( 'plain', '' );		# Empty layout
	$self->header( '-type' => 'text/html' );	# Default header
	$self->no_cache();			# No cache by default
	
	$self->{'.content'} = '';		# Clear content of the page
	$self->{'.html_header'} = {};		# Clear HTML headers
	$self;
	}

# ###
# Specify the layout (visual things) of the page
sub layout
	{
	my $self = shift;
	my ($layout, $institution) = @_;	# Store the values
	$self->{'.layout'} = $layout if defined $layout;
	$self->{'.institution'} = $institution if defined $institution;
	if ($layout eq 'wide')
		{ $self->{'.left'} = ''; $self->{'.right'} = ''; }
	}

# ############
# HTTP headers

# ###
# Specify a new HTTP header
sub header { my $self = shift; $self->{'.header'} = { @_ }; }
# ###
# Add/delete a line to the header
sub add_header
	{
	my $self = shift;
	$self->{'.header'} = { %{$self->{'.header'}}, @_ };
	}
sub del_header	{ delete shift->{'.header'}{ shift @_ }; }

# ###
# Set the expire date
sub expires
	{
	my ($self, $date) = @_;
	$self->add_header('-Expires' => CGI::expires($date));
	}

# ###
# Switch on/off printing the HTTP header
sub no_header	{ shift->{'.noheader'} = 1; }
sub allow_header { delete shift->{'.noheader'}; }

# ###
# Enable or diable the No-cache pragma
sub no_cache	{ shift->add_header('-Pragma' => 'No-cache'); }
sub allow_cache	{ shift->del_header('-Pragma'); }


# ##################################
# Editing (adding) stuff to the page

# ###
# The title of the answer
sub title	{ my $self = shift; $self->{'.title'} = shift; }

# ###
# Add material to the page
sub add
	{
	my $self = shift;
	my $append = "\n";
	if (defined $_[0] and $_[0] =~ /^no_?lf$/i) { $append = ''; shift; }
	( exists $self->{'.right'} ? $self->{'.right'} : $self->{'.content'} )
		.= join '', @_, $append;
	return;
	}
# ###
# Add to the left column
sub add_left
	{
	my $self = shift;
	my $append = "\n";
	if (defined $_[0] and $_[0] =~ /^no_?lf$/i) { $append = ''; shift; }
	if (defined $_[0] and $_[0] =~ /^vcenter$/i)
			{ $self->{'.leftvcenter'} = 1; shift; }

	my $data = join '', @_, $append;
	
	if (exists $self->{'.left'})
		{ $self->{'.left'} .= $data; }
	else
		{
		$data = '<H2>' . $data . "</H2>\n" unless $data =~ /<H.>/;
		$self->add('no_lf', $data);
		}
	return;
	}
# ###
# Add to the whole width, even in the two column format
sub add_both
	{
	my $self = shift;
	$self->flush();
	my $append = "\n";
	if (defined $_[0] and $_[0] =~ /^no_?lf$/i) { $append = ''; shift; }
	
	my $data = join '', @_, $append;
	
	if (defined $self->{'.left'} )
		{ $self->{'.content'} .= '<TR><TD COLSPAN=2>'. $data. "</TD></TR>\n"; }
	else
		{ $self->{'.content'} .= $data; }
	return;
	}
	
# ###
# Flush the columns
sub flush
	{
	my $self = shift;
	if (exists $self->{'.left'} and ($self->{'.left'} ne ''
		or $self->{'.right'} ne ''))
		{
		$self->{'.content'} .= qq!<TR><TD@{[ ( exists $self->{'.leftvcenter'} ? '' : ' VALIGN=top' ) ]}>@{[ $self->get_option('LEFT_COL_START') ]}$self->{'.left'}@{[ $self->get_option('LEFT_COL_END') ]}</TD><TD>$self->{'.right'}</TD></TR>!;
		$self->{'.left'} = '';
		$self->{'.right'} = '';
		delete $self->{'.leftvcenter'};
		}
	else
		{ $self->{'.content'} .= "<BR>\n" unless $self->{'.content'} =~ /<BR>\n$/; }
	1;
	}

# ###
# Horizontal rule
sub hr
	{
	my $self = shift;
	$self->flush();
	$self->add_both( "\n", $self->get_option("HRULE"));
	}

# ###
# These functions are redefined from CGI package -- they do not return
# their output but rather add it into the response.

use vars qw( $AUTOLOAD @FUNCTIONS @DOT_FUN );

@FUNCTIONS = qw( self_url textfield radio_group
	isindex textarea password_field popup_menu scrolling_list
	checkbox_group checkbox submit reset defaults hidden
	image_button button startform endform );

sub AUTOLOAD
	{
	my $self = shift;
	my $function = $AUTOLOAD;
	$function =~ s/^.*:://;
	my $super = 'CGI::' . $function;
	if (grep { $_ eq $function } @FUNCTIONS)
		{
		eval qq! sub $AUTOLOAD { my \$self = shift; \$self->add($super(\$self, \@_)); } !;
		return $self->$AUTOLOAD(@_);
		}
	elsif (grep { $_ eq $function } @DOT_FUN)
		{
		return $self->{'.' . $function};
		}
	else
		{
		eval qq! sub $AUTOLOAD { return ($super(\@_)); } !;
		return $self->$AUTOLOAD(@_);
		}
	}

# ###
# Check the string for possible crack attempts
sub check_valid_string
	{
	my $string = shift; $string = shift if ref $string;
	$string =~ /^[-a-zA-Z0-9_.]*$/
	}
# ###
# Check the parameters passed to the string -- either the default list
# or those specified
sub check_input_params
	{
	my $self = shift;
	my @list = @CHECK_PARAMS;
	if (@_) { @list = @_ };

	my @bad = ();
	my $key;

	for $key (@list)
		{
		my $value;
		for $value ($self->param($key))
			{
			push @bad, $key
				unless $self->check_valid_string($value);
			}
		}
	if (@bad)
		{
		$self->log_error('!');
		$self->REPORT(-text => [ 'Unallowed character in ',
			( scalar(@bad) > 1 ? 'parameter' : 'parameters'),
			" @bad -- possible attack on system\n",
			( map { join '', $_, ' => ', join(',', $self->param($_)), "\n" } @bad ),
			(defined $self->remote_user() ? "Remote user: @{[$self->remote_user()]}\n" : '')
			] );
		}
	}

# ###
# A method that returns value that matches the given layout best
sub get_option
	{
	my ($self, $var) = @_;
	my ($inst, $layout) = @{$self}{ qw( .institution .layout ) };

	return unless exists $OPTS{$var};

	if (not exists $OPTS{$var}{$inst})
		{
		if (exists $OPTS{$var}{'default'})
			{ $inst = 'default'; }
		else { return; }
		}
	
	my $ret;
	if (ref $OPTS{$var}{$inst} ne 'HASH')
		{ $ret = $OPTS{$var}{$inst}; }
	elsif (exists $OPTS{$var}{$inst}{$layout})
		{ $ret = $OPTS{$var}{$inst}{$layout}; }
	elsif (exists $OPTS{$var}{$inst}{'default'})
		{ $layout = 'default'; $ret = $OPTS{$var}{$inst}{$layout}; }
	elsif (exists $OPTS{$var}{'default'})
		{
		if (ref $OPTS{$var}{'default'} eq 'HASH')
			{
			if (exists $OPTS{$var}{'default'}{$layout})
				{ $ret = $OPTS{$var}{'default'}{$layout}; }
			elsif (exists $OPTS{$var}{'default'}{'default'})
				{ $ret = $OPTS{$var}{'default'}{'default'}; }
			else	{ return ''; }
			}
		else
			{ $ret = $OPTS{$var}{'default'}; }
		}
	else	{ return ''; }

	if (ref $ret eq 'ARRAY')
		{ $ret = get_opt_arr_ref($ret); }
	elsif (ref $ret eq 'CODE')
		{ return $self->$ret(); }
	$ret;
	}

# ###
# Convert array ref to image
sub get_opt_arr_ref
	{
	my $value = shift;
	my ($pic, $alt, $ref, @rest) = @$value;
	if ($pic !~ m!^/! and $pic =~ /\.(gif|jpg|jpeg|png)$/)
		{
		my $ret = qq!<IMG SRC="$PICS_PATH/$pic" BORDER=0@{[
		( defined $alt ? qq{ ALT="$alt"} : '' ) ]}>!;
		$ret .= join ' ', @rest if @rest;
		if (defined $ref)
			{ $ret = qq!<A HREF="$ref">$ret</A>!; }
		return $ret;
		}
	else
		{ return join ' ', @$value; }
	}

# ###
# User defined icons
sub add_icon
	{
	my $self = shift;
	my $value;
	if (ref $_[0] eq 'ARRAY')
		{ $value = get_opt_arr_ref($_[0]); }
	else
		{ $value = get_opt_arr_ref(\@_); }
	$self->{'.icons'} = '' unless defined $self->{'.icons'};
	$self->{'.icons'} .= $value;
	1;
	}

# ###
# Define the signature
sub sign
	{
	my ($self, $sign, $ref) = @_;
	if (not defined $sign)
		{ $sign = $self->get_option('SIGN_VALUE'); }
	elsif (defined $ref)
		{ $sign = qq!<I><A HREF="mailto:$ref">$sign</A></I>!; }
	$self->{'.sign'} = $sign;
	}

# ###
# Test the length of the https key
sub https_keysize
	{
	my $self = shift;
	my $length = 0;
	if (defined $ENV{'HTTPS'} and $ENV{'HTTPS'} eq 'on')
		{ $length = 40; }
	if (defined $ENV{'HTTPS_SECRETKEYSIZE'}) 
		{ $length = $ENV{'HTTPS_SECRETKEYSIZE'}; }
	$length;
	}

# ###
# Actually print the HTTP header. Never used directly
sub print_header
	{
	my $self = shift;
	print $self->SUPER::header( %{$self->{'.header'}} );
	}

# ###
# Print out the whole body
sub print_out
	{
	my $self = shift;
	return if defined $self->{'.alreadyprinted'};
					# prevent print in DESTROY

	$self->print_header() unless defined $self->{'.noheader'};
					# print header

	if (@_)	{ print @_; return; }	# if the content was specified in 
					# this call, print it and abort

	$self->flush();			# reasonable to flush columns

	my $title = ($self->{'.title'} or '');
	$title =~ s/<(BR|P)>/ /gi;
	### $title =~ s!</?.*?>!!gs;
	my %html_headers = ( '-title' => $title, %{$self->{'.html_header'}} );

	my $bg = $self->get_option('BGCOLOR');
	$html_headers{'-bgcolor'} = $bg if $bg ne '';
	$bg = $self->get_option('BACKGROUND');
	$html_headers{'-background'} = "$PICS_PATH/$bg" if $bg ne '';

	### $starthtml =~ s/<!DOCTYPE.*?\n//; ### some people do not like this

	print $self->start_html(%html_headers), "\n";

	print $self->get_option('WHOLE_BODY');

	print $self->end_html(), "\n";
	}



#
# log the request
#
sub get_params_for_log
	{
	my $self = shift;
	my $params = '';
	my $key;
	for $key ($self->param)
		{
		$params .= join ' ', map { qq($key="$_") } 
				map { my $e = $_; $e =~ s/\n/<NL>/g; $e; }
						$self->param($key);
		$params .= ' ';
		}
	$params;
	}
sub log_in
	{
	my $self = shift;
	CGI::BuildPage::Log::do_log($self->remote_user(), $self->remote_host(),
		'*', $self->script_name(), $self->get_params_for_log());
	}
sub log_error
	{
	my $self = shift;
	my $error = shift;
	$error = '!' unless defined $error;
	my $text = shift;
	$text = $self->get_params_for_log() unless defined $text;
	CGI::BuildPage::Log::do_log($self->remote_user(), $self->remote_host(),
		$error, $self->script_name(), $text);
	}


sub bad_parameter
        {
        my $self = shift;
        $self->{'.content'} = '';
        $self->{'.left'} = $self->{'.right'} = '';
        $self->title("Bad invocation");
        $self->add("The script was called with wrong parameters.");
        $self->print_out();
        exit();
        }

sub REPORT
        {
        my $self;
        $self = shift if ref $_[0];

        my ($text, $email, $subject, $urgent) = ('', 'root',
                'CGI::BP: Serious error', 0);

        if (defined $_[0] and $_[0] =~ /^-?(text|content)$/i)
                {
                my %options = @_;
                my $key;
                for $key (keys %options)
                        {
                        my $value = $options{$key};
                        delete $options{$key};
                        $key =~ s/[-_]//g;
                        $key = lc $key;
                        $options{$key} = $value;
                        }
                $text = $options{'text'} if defined $options{'text'};
                $email = $options{'email'} if defined $options{'email'};
                $subject = $options{'subject'} if defined $options{'subject'};
                $urgent = $options{'urgent'} if defined $options{'urgent'};
                }
        elsif (defined $_[0])
                {
                $text = shift;
                if (defined $_[0])
                        {
                        $subject = shift;
                        if (defined $_[0])
                                { $email = shift; }
                        }
                }

        if (ref $text)
                { $text = join '', @$text; }

        my $urgenttext = '';
        $urgenttext = "Priority: urgent\n" unless ($urgent eq '0' or $urgent eq '');
        open MAIL, qq!| /usr/lib/sendmail -t !;
        print MAIL "To: $email\nSubject: $subject\n$urgenttext\n";

        print MAIL $text, "\n---\n";
        my $key;
        for $key (sort keys %ENV)
                { print MAIL "$key = $ENV{$key}\n"; }
        close MAIL;

        if (defined $self and $self->can('bad_parameter'))
                { $self->bad_parameter(); }
        }

1;


package CGI::BuildPage::Log;
use POSIX;

my $LOGDIR = "/export/journal";
my $LOGFILE = "$LOGDIR/log";

sub log_date
	{ POSIX::strftime("%Y-%m-%d.%H-%M-%S", localtime); }
sub do_log
	{
	my $text = '';
	$text = join ':', log_date(), map { defined $_ ? $_ : '' } @_ if @_;
	$text .= "\n" unless $text =~ /\n$/;
	open LOG, ">> $LOGFILE" or return; ### die "Error appending $LOGFILE: $!";
	flock LOG, 2;
	seek LOG, 0, 2;
	print LOG $text;
	close LOG;
	}
1;

__END__

=head1 SYNOPSIS

	use CGI::BuildPage;
	my $q = new CGI::BuildPage();

and then it's similar to B<CGI.pm>, but use B<add> instead of B<print>s.

=head1 MOTIVATION

During the development of the Administrative server of our faculty we
found out that certain parts of our scripts are typed again and again.
This included such things like background color or image settings,
links that should go with icons and logos, creating two column pages,
etc. So even if we were using CGI.pm to parse the parameters and
create the HTML answer, there still was a big deal of duplicate
"static" code in our scripts.

That's why we designed a interface that is in part presented here as
the B<CGI::BuildPage> module. It inherits from B<CGI>, so it has the
same capabilities and methods, with one main exception: the methods
like I<startform> or I<textfield> do not return the HTML code
produced but store it inside of the object. That's why the module can
also add certain visual elements to the proper places of pages, like
logos and signatures, and can produce two column output using tables.

One of the requirement we had on the module was a support of
different styles for different parts of our organization. The visual
part of the HTML document is to great extend described using a set
of rules in the module and you can make the script produce different
page by only a change of parameters to the method I<layout>. You can
even have one script, linked from more directories, that checks the
path_info() and prints answers with different layouts.

Another features include the possibility to check parameters for
"strange" characters, logging of the script execution including the
parameters, modification of the HTTP headers at any time during the
script processing.

The module allows the authors of the scripts (and we have more than
250 on our Web site) to concentrate on the real goals of the script,
like getting the parameters, checking them, fetching data from files
or database and building the parts of the output page as you go or
changing the expire date or cache pragma depending on the results.

The module uses tables to create the layout. Even if new techniques
are emerging, we need a tool giving results that will be understood by
even old browsers. HTML seems to be the language of choice for now and
at least a year to come.

=head1 DESCRIPTION

The list of methods available in B<CGI::BuildPage> follows. Note that
only the changes from the CGI's behavior or new methods are listed
here.

=head2 Basic methods and building HTML

=over 4

=item new

Creates the basic object, calls I<CGI::new>. If the first parameter is
the word 'C<no_log>', doesn't log the script execution. This can be used
for unimportant script where the logging in Apache's access_log is
enough, or for scripts that take passwords as their parameters. We can
alter or remove the password parameter and then log explicitely using
I<log_in>:

	my $query = new CGI::FI('no_log');
	my $passwd = $query->param('password');
	$query->param('passwd', crypt (...salt etc...));
	### or directly $query->delete('passwd');
	$query->log_in();

=item layout

Specify the layout and institution, for which we produce the page.
This method should be called before we start to add things into the
page. The distribution module supports layout values B<plain>,
B<white>, B<narrow> and B<wide>, institution values B<blue> and
B<green>.

=item add

Adds the parameter to the content of the page. It doesn't print it
out, stores it into the object instead. Example:

	$query->add('<H2>Enter your code</H2>');

If the layout is two column, adds to the right (main) column.

=item add_left, add_both

Adds to the left column or to both (using C<COLSPAN>). If the layout
doesn't imply two columns, adds to the main, possibly doing some more
formatting.

=back

All these three I<add>ing methods append the newline character to the
parameter by default. This can be switched off by specifying word
'C<no_lf>' as the first parameter. Left column is typeset top-justified,
it can be centered using 'C<vcenter>' as another optional word at the
start of parameter list.

=over 4

=item flush

Flushes the columns, the global line in the two column layout. You can
thus mix I<add> and I<add_left> and they will be appended to the their
columns independently.

=item print_out

Actually print the content of the HTML answer to the output. You can
give parameters to this method, then this data will be printed instead
of the accumulated content. This can be handy for dynamic gifs,
generated using B<GD>, for example.

=back

The HTML producing methods of B<CGI> are changed so that they store
their result into the content in the object, using I<add>. One
exception is the method I<hr>, which depends on the layout of the
page and may return a picture, and also stores using I<add_both>.

=over 4

=item sign

Specifies the signature of the page, instead of the default one. The
second parameter will be used in the mailto HREF.

=item add_icon

Adds user defined icons to the line of default icons. The parameters
are: picture file, alternate text and the HREF.

=back

=head2 Other parameter methods

=over 4

=item no_cache, allow_cache

Specifies whether to send the No-cache HTTP header, default yes.

=item no_header, allow_header

Switches off and on sending the HTTP headers. This can be used for
caching the output of the CGI into html file. Default is allow.

=item expires

Sets the expire date, the format is the same as in B<CGI>.

=item https_keysize

Returns the length of the keys in HTTPS protocol, 0 for plain HTTP.

=item check_input_params

Checks if the parameters contain "unsecure" characters, meaning
possible hacker attack. The names of the parameters are the arguments.
If a problem is found, logs error and send an email to the root.

=back

=head2 Errors, logging

To log in explicitely, use method I<log_in>. To log error, use
I<log_error>, optionally giving it one character symbol of the error.

The method I<bad_parameter> can be used to abort the script execution.

Method I<REPORT> is used to email the message to the root (note that
similar functionality is provided by the module B<Tie::STDERR>, so this
could also be done via C<use Tie::STDERR> and C<print STDERR>).

=head1 VERSION

0.95

=head1 SEE ALSO

perl(1), CGI(3).

=head1 AUTHOR

(c) 1998 Jan Pazdziora, adelton@fi.muni.cz,
http://www.fi.muni.cz/~adelton/ at Faculty of Informatics, Masaryk
University in Brno, Czech Republic

