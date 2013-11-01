package ExobrainPipeline::Plugin::ICal;
use Moose;
with 'ExobrainPipeline::Role::Plugin';

use 5.010;

use DateTime;
use HTTP::Tiny;
use Moose::Autobox;
use DateTime::Span;
use Data::ICal::DateTime;
use DateTime::Format::ICal;

use namespace::autoclean;

has url         => ( is => 'ro', isa => 'Str', required => 1 );
has days        => ( is => 'ro', isa => 'Int', default  => 7 );
has title       => ( is => 'ro', isa => 'Str', default  => 'Upcomming Events' );
has time_format => ( is => 'ro', isa => 'Str', default  => '%m-%d %a %R' );

sub execute {
    my ( $self, $data ) = @_;

    # TODO Errors, yo
    my $ics = HTTP::Tiny->new->get( $self->url )->{content};

    my $span = DateTime::Span->from_datetime_and_duration(
        start => DateTime->now,
        days  => $self->days
    );

    my $output = $self->title . "\n" . '=' x length( $self->title ) . "\n";

    my @events = sort {
        $a->{properties}{dtstart}[0]{value}
            cmp $b->{properties}{dtstart}[0]{value}
        } grep { $_->property('summary')->[0]->value }
        Data::ICal->new( data => $ics )->events($span);

    for my $event (@events) {

        my $start = DateTime::Format::ICal->parse_datetime(
            $event->property('dtstart')->[0]->value );

        $output .= join( ' - ',
            $start->strftime( $self->time_format ),
            $event->property('summary')->[0]->value )
            . "\n";
    }

    $data->push( { agenda => $output } );

    return $data;
}

1;
