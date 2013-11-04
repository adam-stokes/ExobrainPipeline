package ExobrainPipeline::Plugin::TheDailyPractice;
use Moose;
with 'ExobrainPipeline::Role::Plugin';

use 5.010;

use Net::TDP;
use DateTime;
use Moose::Autobox;

use namespace::autoclean;

has api_key   => ( is => 'ro', isa => 'Str', required => 1 );
has time_zone => ( is => 'ro', isa => 'Str', required => 0 );
has today => ( is => 'ro', isa => 'Bool', default => 0 ); # yesterday is default
has _api => (
    is      => 'ro',
    isa     => 'Net::TDP',
    lazy    => 1,
    default => sub { return Net::TDP->new( api_key => $_[0]->api_key ) } );

sub execute {
    my ( $self, $data ) = @_;

    my @dt_tz_args = $self->time_zone ? ( time_zone => $self->time_zone ) : ();
    my $date
        = $self->today
        ? DateTime->today(@dt_tz_args)->date
        : DateTime->today(@dt_tz_args)->subtract( days => 1 )->date;

    for my $plugin ( $data->flatten ) {
        next unless $plugin->exists('tdp');

        # make them all the same
        $plugin->{tdp} = [ $plugin->{tdp} ] if ref $plugin->{tdp} eq 'HASH';

        for my $goal ( $plugin->{tdp}->flatten ) {
            my $return
                = $self->_api->completed( $goal->flatten, date => $date );
        }
    }

    return $data;
}

1;

__END__
Sample conf:

[TheDailyPractice]
api_key = 416544165445ab6546ef54546465846854
time_zone = America/New_York
