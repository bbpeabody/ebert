#!/usr/bin/perl
use Local::Gateway;

# Define a perl OO class
package Local::Device;
sub new
{
	my $class = shift;
	my $self = {
		_log		=> shift,
		_name		=> shift,
		_gateway	=> shift,
		_deviceId   => shift,
		_codes	    => shift
	};
	bless $self, $class;
	return $self;
}

sub getName
{
	my $self = shift;
	return $self->{_name};
}

sub setName
{
	my ($self, $name) = @_;
	$self->{_name} = $name if defined($name);
	return $self->{_name};
}

sub getGateway
{
	my $self = shift;
	return $self->{_gateway};
}

sub setGateway
{
	my ($self, $gateway) = @_;
	$self->{_gateway} = $gateway if defined($gateway);
	return $self->{_gateway};
}

sub getDeviceId
{
	my $self = shift;
	return $self->{_deviceId};
}

sub setDeviceId
{
	my ($self, $deviceId) = @_;
	$self->{_deviceId} = $deviceId if defined($deviceId);
	return $self->{_deviceId};
}

sub getCodes
{
	my $self = shift;
	return $self->{_codes};
}

sub setCodes
{
	my ($self, $codes) = @_;
	$self->{_codes} = $codes if defined($codes);
	return $self->{_codes};
}

sub sendCommand
{
	my ($self, $command) = @_;
	if (! defined $command)
	{
		$self->{_log}->error("The command is not defined for " . $self->getName()); 
		return 1;
	}
	if (! exists $self->{_codes}->{$command} || 
        ! defined $self->{_codes}->{$command}   )
	{
		$self->{_log}->error("The command '$command' does not exist for " . $self->getName()); 
		return 1;
	}
	my $commandSequence = $self->{_codes}->{$command};
	$self->{_log}->info($self->getName() . " sending command '$command' ");
	return $self->{_gateway}->sendCommand($self->{_deviceId}, $commandSequence);	
}

return 1;

