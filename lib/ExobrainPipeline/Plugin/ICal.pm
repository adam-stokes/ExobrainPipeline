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
has time_zone   => ( is => 'ro', isa => 'Str', required => 0 );

sub execute {
    my ( $self, $data ) = @_;

    # TODO Errors, yo
    my $ics = HTTP::Tiny->new->get( $self->url )->{content};

    my $span = DateTime::Span->from_datetime_and_duration(
        start => DateTime->now,
        days  => $self->days
    );

    my $output = $self->title . "\n" . '=' x length( $self->title ) . "\n";
    my $raw_data = [];

    my @events = sort {
        $a->{properties}{dtstart}[0]{value}
            cmp $b->{properties}{dtstart}[0]{value}
        } grep { $_->property('summary')->[0]->value }
        Data::ICal->new( data => $ics )->events($span);

    for my $event (@events) {
        $event->start->set_time_zone( $self->time_zone ) if $self->time_zone;

        $raw_data->push(
            {   start => $event->start,
                name  => $event->property('summary')->[0]->value
            } );

        $output .= join( ' - ',
            $event->start->strftime( $self->time_format ),
            $event->property('summary')->[0]->value )
            . "\n";
    }

    $data->push( { agenda => $output, ical => $raw_data } );

    return $data;
}

1;

__END__

[ICal]
title = Upcomming Hollidays
url   = http://www.calendarlabs.com/templates/ical/US-Holidays.ics
days  = 28

[ICal / ICal2 ]
title = World Take Over Schedule
url   = http://127.0.0.37/data/ics/world.ics
