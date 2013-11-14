package ExobrainPipeline::Plugin::FitBit;
use Moose;
with 'ExobrainPipeline::Role::Plugin';

use 5.010;

use WebService::FitBit;
use DateTime;

use namespace::autoclean;

has step_goal => ( is => 'ro', isa => 'Int',  default  => 10000 );
has tdp_id    => ( is => 'ro', isa => 'Int',  required => 1 );
has today     => ( is => 'ro', isa => 'Bool', default  => 0 );
has time_zone => ( is => 'ro', isa => 'Str',  required => 0 );

has _api => (
    is      => 'ro',
    isa     => 'WebService::FitBit',
    lazy    => 1,
    default => sub { return WebService::FitBit->new() } );

sub execute {
    my ( $self, $data ) = @_;

    my @dt_tz_args = $self->time_zone ? ( time_zone => $self->time_zone ) : ();
    my $yesterday = DateTime->today(@dt_tz_args)->subtract( days => 1 )->date;
    my $steps = $self->_api->steps_taken( $self->today ? () : $yesterday );

    if ( $steps >= $self->step_goal ) {
        my $message = "You met your step goal with $steps steps\n";
        push @$data,
            {
            tdp    => { id => $self->tdp_id, note => "$steps steps" },
            agenda => {
                text => $message,
                html => "<h1>FitBit</h1>\n<p>$message</p>"
            },
            };

    }
    else {
        my $deficit = $self->step_goal - $steps;
        my $message
            = "You were $deficit under your step goal with $steps steps.\n";
        push @$data, {
            agenda => {
                text => $message,
                html => "<h1>FitBit</h1>\n<p>$message</p>"
                }

        };
    }

    return $data;
}

1;

__END__
Sample conf:

[FitBit]
step_goal = 7500
tdp_id    = 12345
time_zone = America/New_York
