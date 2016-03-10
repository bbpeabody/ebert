#!/usr/bin/perl

use Net::Telnet;
# Define a perl OO class
package Local::Gateway;

use Local::Log;
use constant MAX_ID =>  65535;
use LWP::UserAgent;

sub new
{
	my $class = shift;
	my $self = {
		_log        => shift,
		_name		=> shift,
		_ipAddr		=> shift,
		_port		=> shift,
		_type		=> shift,
		_id             => 1
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

sub getIpAddr
{
	my $self = shift;
	return $self->{_ipAddr};
}

sub setIpAddr
{
	my ($self, $ipAddr) = @_;
	$self->{_ipAddr} = $ipAddr if defined($ipAddr);
	return $self->{_ipAddr};
}

sub getPort
{
	my $self = shift;
	return $self->{_port};
}

sub setPort
{
	my ($self, $port) = @_;
	$self->{_port} = $port if defined($port);
	return $self->{_port};
}

sub getType
{
	my $self = shift;
	return $self->{_type};
}

sub setType
{
	my ($self, $type) = @_;
	$self->{_type} = $type if defined($type);
	return $self->{_type};
}

sub sendCommand
{
	my ($self, $deviceId, $command) = @_;
	if ($self->{_type} eq "gc-100") 
	{
		$self->{_log}->info($self->getName() . " sending command '$command' to device '$deviceId' at address '" . $self->{_ipAddr} . "' port '" . $self->{_port} . "'");
		my $t = new Net::Telnet (Timeout => 10, Prompt => '/.*/', Port => $self->{_port});
		$t->open($self->{_ipAddr});
		$t->cmd("sendir,$deviceId,$self->{_id},$command");
		my $line = $t->get();
		$self->{_log}->info($self->getName() . " received " . $line);
		$t->close();
		if ($self->{_id} == MAX_ID)
		{
			$self->{_id} = 1;
		}
		else
		{
			$self->{_id} += 1;
		}
		if ($line =~ /completeir/) 
		{
			return 0;	# Success
		}
		else
		{
			return 1;	# Failure
		} 
	}
	elsif ($self->{_type} eq "post")
	{
		my $ua = LWP::UserAgent->new;
		my $server_endpoint = "http://" . $self->{_ipAddr} . ":" . $self->{_port} . "/" . $command;
		$self->{_log}->info($self->getName() . " HTTP POST '$server_endpoint'");
 
		# set custom HTTP request header fields
		my $req = HTTP::Request->new(POST => $server_endpoint);
		#$req->header('content-type' => 'application/json');
		#$req->header('x-auth-token' => 'kfksj48sdfj4jd9d');
 
		# add POST data to HTTP request body
		#my $post_data = '{ "name": "Dan", "address": "NY" }';
		#$req->content($post_data);
 
		my $resp = $ua->request($req);
		if ($resp->is_success) {
    		my $message = $resp->decoded_content;
    		$self->{_log}->info($self->getName() . ": Received reply: $message\n");
			return 0;
		}
		else
		{
    		$self->{_log}->error($self->getName() . ": HTTP POST error code: ", $resp->code);
    		$self->{_log}->error($self->getName() . ": HTTP POST error message: ", $resp->message);
			return 1;
		}
	}
    elsif ($self->{_type} eq "get")
    {
		my $ua = LWP::UserAgent->new;
		my $server_endpoint = "http://" . $self->{_ipAddr} . ":" . $self->{_port} . "/" . $command;
		$self->{_log}->info($self->getName() . " HTTP GET '$server_endpoint'");
 
		# set custom HTTP request header fields
		my $req = HTTP::Request->new(GET => $server_endpoint);
		#$req->header('content-type' => 'application/json');
		#$req->header('x-auth-token' => 'kfksj48sdfj4jd9d');
 
		# add POST data to HTTP request body
		#my $post_data = '{ "name": "Dan", "address": "NY" }';
		#$req->content($post_data);
 
		my $resp = $ua->request($req);
		if ($resp->is_success) {
    		my $message = $resp->decoded_content;
    		$self->{_log}->info($self->getName() . ": Received reply: $message\n");
			return 0;
		}
		else
		{
    		$self->{_log}->error($self->getName() . ": HTTP GET error code: ", $resp->code);
    		$self->{_log}->error($self->getName() . ": HTTP GET error message: ", $resp->message);
			return 1;
		}
    }
}
return 1;

