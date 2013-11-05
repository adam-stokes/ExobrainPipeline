package ExobrainPipeline::Plugin::ICal::Combiner;
use Moose;
with 'ExobrainPipeline::Role::Plugin';

use 5.010;

use Template;
use Template::Constants qw( :debug );
use Moose::Autobox;

use namespace::autoclean;

has title       => ( is => 'ro', isa => 'Str', default => 'Upcomming Events' );
has time_format => ( is => 'ro', isa => 'Str', default => '%R' );
has date_format => ( is => 'ro', isa => 'Str', default => '%m-%d %a' );
has strip_midnight => ( is => 'ro', isa => 'Bool', default => 0 );

sub execute {
    my ( $self, $data ) = @_;

    my $events = [];
    for my $plugin ( $data->flatten ) {
        next unless $plugin->exists('ical');
        $events->push( $plugin->{ical}->flatten );
        delete $plugin->{agenda};
    }

    $events = $events->sort( sub { $_[0]->{start} <=> $_[1]->{start} } );
    $events->map(
        sub {
            $_->{date} = $_->{start}->strftime( $self->date_format );
            $_->{time} = $_->{start}->strftime( $self->time_format );
        } );

    
    $events->map( sub { $_->{time} = '' if $_->{time} eq '00:00' } )
        if $self->strip_midnight;

    my $txt = $self->title . "\n" . '=' x length( $self->title ) . "\n";
    $txt .= join( ' - ', $_->{date} . ' ' . $_->{time}, $_->{name} ) . "\n"
        for $events->flatten;


    # tried to do this in TT but it wouldn't cooperate
    {
        my $last = '';
        for my $event ( $events->flatten ) {
            $event->{date} = '' if $event->{date} eq $last;
            $last = $event->{date} unless $event->{date} eq '';
        }
    }

    my $html;
    my $html_template = join( '', <DATA> );
    Template->new->process( \$html_template,
        { title => $self->title, events => $events }, \$html );

    $data->push( { agenda => { text => $txt, html => $html } } );

    return $data;
}

1;

# [ICal::Combiner]
# title          = Agenda
# strip_midnight = 1

__DATA__
<h1> [% title %]</h1>
<table>
[% FOREACH event IN events -%]
<tr>
    <td width="100">[% event.date %]</td>
    <td width="50">[% event.time %]</td>
    <td>[% event.name %]</td>
</tr>
[% END -%]
</table>
