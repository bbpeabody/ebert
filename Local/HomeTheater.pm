#!/usr/bin/perl

# Define a perl OO class
package Local::HomeTheater;

use Data::Dumper;
use Local::Gateway;
use Local::Device;
use Local::SonyReceiver;
use Local::BenQProjector;
use Local::Roku;
use Local::Veralite;
use Local::Log;

sub new
{
	my $class = shift;
	my $log = shift;
	my $gateway     = new Local::Gateway($log, "Global Cache GC-100", "192.168.123.40", "4998", "gc-100");
	my $receiver    = new Local::Device($log, "Sony STR-DN1040", $gateway, "5:3", Local::SonyReceiver::codes);
	my $projector   = new Local::Device($log, "BenQ Projector", $gateway, "4:2", Local::BenQProjector::codes);
	my $gateway     = new Local::Gateway($log, "Roku POST", "192.168.123.41", "8060", "post");
	my $roku        = new Local::Device($log, "Roku", $gateway, "", Local::Roku::codes);
	my $gateway     = new Local::Gateway($log, "Veralite GET", "192.168.123.45", "3480", "get");
	my $veralite    = new Local::Device($log, "Veralite", $gateway, "", Local::Veralite::codes);
	my $self = {
		_log		=> $log,
		_name		=> shift,
		_receiver   => $receiver,
		_projector  => $projector, 
		_roku       => $roku,
        _veralite   => $veralite 
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

sub on
{
	my $self = shift;
	if ($self->{_receiver}->sendCommand('POWER_ON') ||
		$self->{_projector}->sendCommand('POWER_ON')  ) 
	{
		return ("Failed to turn on " . $self->getName(), 0);
	} 
	else 
	{
		return ("Turning on the " . $self->getName(), 0);
	} 
}

sub off
{
	my $self = shift;
	my $fail = 0;
	$fail |= $self->{_receiver}->sendCommand('POWER_OFF');
 	$fail |= $self->{_projector}->sendCommand('POWER_OFF');
	sleep(1);
 	$fail |= $self->{_projector}->sendCommand('POWER_OFF');
  	if ($fail) 
	{
		return ("Failed to turn off " . $self->getName(), 0);
	} 
	else 
	{
		return ("Turning off the " . $self->getName(), 0);
	} 
}

sub lightsOff
{
    my $self = shift;
    #my $suppressMessage = shift;
    my $fail = 0;
    $fail |= $self->{_veralite}->sendCommand('BONUS_ROOM_LIGHT_OFF');
    $fail |= $self->{_veralite}->sendCommand('MOVIES_SIGN_OFF');
  	return $fail unless wantarray;
  	if ($fail) 
	{
		return ("Failed to turn off the lights in the " . $self->getName(), 0);
	} 
	else 
	{
		return ("Turning off the lights in the " . $self->getName(), 0);
	} 
}

sub lightsDim
{
    my $self = shift;
    #$my $suppressMessage = shift;
    my $fail = 0;
    $fail |= $self->{_veralite}->sendCommand('BONUS_ROOM_LIGHT_OFF');
    $fail |= $self->{_veralite}->sendCommand('MOVIES_SIGN_DIM_40');
  	return $fail unless wantarray;
  	if ($fail) 
	{
		return ("Failed to dim the lights in the " . $self->getName(), 0);
	} 
	else 
	{
		return ("Dimming the lights in the " . $self->getName(), 0);
	} 
}

sub lightsOn
{
    my $self = shift;
    #my $suppressMessage = shift;
    my $fail = 0;
    $fail |= $self->{_veralite}->sendCommand('BONUS_ROOM_LIGHT_ON');
    $fail |= $self->{_veralite}->sendCommand('MOVIES_SIGN_DIM_60');
  	return $fail unless wantarray;
    if ($fail) 
	{
		return ("Failed to turn on the lights in the " . $self->getName(), 0);
	} 
	else 
	{
		return ("Turning on the lights in the " . $self->getName(), 0);
	} 
}

sub fanOff
{
    my $self = shift;
    my $fail = 0;
    $fail |= $self->{_veralite}->sendCommand('BONUS_ROOM_FAN_OFF');
  	if ($fail) 
	{
		return ("Failed to turn off the fans in the " . $self->getName(), 0);
	} 
	else 
	{
		return ("Turning off the fans in the " . $self->getName(), 0);
	} 
}

sub fanOn
{
    my $self = shift;
    my $fail = 0;
    $fail |= $self->{_veralite}->sendCommand('BONUS_ROOM_FAN_ON');
  	if ($fail) 
	{
		return ("Failed to turn on the fans in the " . $self->getName(), 0);
	} 
	else 
	{
		return ("Turning on the fans in the " . $self->getName(), 0);
	} 
}

sub rokuInput
{
    my $self = shift;
	return $self->{_receiver}->sendCommand('INPUT_VIDEO_1');
}

sub volumeUp
{
	my $self = shift;
	my $amount = shift || 5;
	my $fail = 0;
	foreach (0..$amount)
	{
		$fail |= $self->{_receiver}->sendCommand('VOLUME_UP');
	}

	if ($fail)
	{
		return ("Failed to increase the volume in the " . $self->getName(), 0);
	} 
	else 
	{
		return ("Increasing the volume in the " . $self->getName(), 0);
	} 
}

sub volumeDown
{
	my $self = shift;
	my $amount = shift || 5;
	my $fail = 0;
	foreach (0..$amount) 
	{
		$fail |= $self->{_receiver}->sendCommand('VOLUME_DOWN');
	}
	if ($fail)
	{
		return ("Failed to decrease the volume in the " . $self->getName(), 0);
	} 
	else 
	{
		return ("Decreasing the volume in the " . $self->getName(), 0);
	} 
}

sub muteToggle
{
	my $self = shift;
	if ($self->{_receiver}->sendCommand('MUTE_TOGGLE'))
	{
		return ("Failed to toggle mute on in the " . $self->getName(), 0);
	} 
	else 
	{
		return ("Toggling mute in the " . $self->getName(), 0);
	} 
}

sub search
{
	my $self = shift;
	my $text = shift;
	$text =~ s/^.*(search|find)//;
	$text =~ s/^.*(searching|finding)//;
	$text =~ s/^\s+//;
	$text =~ s/\s+$//;
	$text =~ s/^(for|on)\b\s*//;
	$text =~ s/^\s*\b(a|an|the|of)\b\s*/ /;	 
	my $fail = 0;
	$fail |= $self->rokuInput;
	$fail |= $self->{_roku}->sendCommand('HOME');
    sleep(3);
	$fail |= $self->{_roku}->sendCommand('HOME');
	$fail |= $self->{_roku}->sendCommand('DOWN');
	$fail |= $self->{_roku}->sendCommand('DOWN');
	$fail |= $self->{_roku}->sendCommand('DOWN');
	$fail |= $self->{_roku}->sendCommand('DOWN');
	$fail |= $self->{_roku}->sendCommand('DOWN');
	$fail |= $self->{_roku}->sendCommand('SELECT');
	my @chars = split(//,$text);
	foreach my $char (@chars)
	{
		if (ord($char) == 32)
		{
			$char = "SPACE";
		}
		$fail |= $self->{_roku}->sendCommand("CHAR_$char");
	}
    sleep(2);
	$fail |= $self->{_roku}->sendCommand('RIGHT');
	$fail |= $self->{_roku}->sendCommand('RIGHT');
	$fail |= $self->{_roku}->sendCommand('RIGHT');
	$fail |= $self->{_roku}->sendCommand('RIGHT');
	$fail |= $self->{_roku}->sendCommand('RIGHT');
	$fail |= $self->{_roku}->sendCommand('RIGHT');
	if ($fail)
	{
		return ("Search failed in the " . $self->getName(), 0);
	} 
	else 
	{
		return ("Searching for $text on all Roku Channels in the " . $self->getName() . " . Navigate?", "navigate");
	} 
}

sub watch
{
	my ($self, $command) = @_;
	my $fail = 0;
	my $rokuWatchHash = Local::Roku::watchList();
	my $rokuChannels = join("|", keys(%$rokuWatchHash));
    if ($command =~ /($rokuChannels)/) {
		$rokuChannel = $1;
		$rokuCommand = $rokuWatchHash->{$rokuChannel};
		$fail |= $self->rokuInput;
		$fail |= $self->{_roku}->sendCommand($rokuCommand);
	} 
    else
	{
		$fail = 1;
	}
    if (! $fail) 
    {
        $fail |= $self->lightsOff;
    }	
	if ($fail)
	{
		return ("Failed to switch " . $self->getName() . " to $rokuChannel.", 0);
	} 
	else 
	{
		return ("Let's watch $rokuChannel in the " . $self->getName(), 0);
	} 
}

sub pauseRoku
{
	my $self = shift;
	my $fail = 0;
	$fail |= $self->{_roku}->sendCommand('PLAY');
    if (! $fail) 
    {
        $fail |= $self->lightsDim;
    }	
	if ($fail)
	{
		return ("Failed to pause Roku in the " . $self->getName(), 0);
	} 
	else 
	{
		return ("Pausing the Roku in the " . $self->getName(), 0);
	} 
}

sub playRoku
{
	my $self = shift;
	my $fail = 0;
	$fail |= $self->{_roku}->sendCommand('PLAY');
    if (! $fail) 
    {
        $fail |= $self->lightsOff;
    }	
	if ($fail)
	{
		return ("Failed to play Roku in the " . $self->getName(), 0);
	} 
	else 
	{
		return ("Pressing play on the Roku in the " . $self->getName(), 0);
	} 
}

sub keyboard
{
    my $self = shift;
    my $cmd = shift;
    $cmd =~ s/\s+//g;
    $cmd =~ s/(letter|letters|keyboard|numbers|typing|type)//g;
    my $fail = 0;
	my @chars = split(//,$cmd);
	foreach my $char (@chars)
	{
		if (ord($char) == 32)
		{
			$char = "SPACE";
		}
		$fail |= $self->{_roku}->sendCommand("CHAR_$char");
	}
    return ("Typing?", $fail ? 0 : "letter");
}

sub navigate
{
    my $self = shift;
    my $cmd = shift;
    $cmd =~ s/\s+//g;
    $cmd =~ s/navigate//g;
    my $fail = 0;
    if ($cmd =~ m/^up(.*)/)
    {
	    $fail |= $self->{_roku}->sendCommand('UP');
        if ($1)
        {
            my ($rm, $rf) = $self->navigate($1);
            $fail |= $rf;   
        }
    }
    elsif ($cmd =~ m/^down(.*)/)
    {
	    $fail |= $self->{_roku}->sendCommand('DOWN');
        if ($1)
        {
            my ($rm, $rf) = $self->navigate($1);
            $fail |= $rf;   
        }
    }
    elsif ($cmd =~ m/^left(.*)/)
    {
	    $fail |= $self->{_roku}->sendCommand('LEFT');
        if ($1)
        {
            my ($rm, $rf) = $self->navigate($1);
            $fail |= $rf;   
        }
    }
    elsif ($cmd =~ /^(right|write)(.*)/)
    {
	    $fail |= $self->{_roku}->sendCommand('RIGHT');
        if ($2)
        {
            my ($rm, $rf) = $self->navigate($2);
            $fail |= $rf;   
        }
    }
    elsif ($cmd =~ /^(fastforward|forward)(.*)/)
    {
	    $fail |= $self->{_roku}->sendCommand('FWD');
        if ($2)
        {
            my ($rm, $rf) = $self->navigate($2);
            $fail |= $rf;   
        }
    }
    elsif ($cmd =~ /^(rewind|reverse)(.*)/)
    {
	    $fail |= $self->{_roku}->sendCommand('REV');
        if ($2)
        {
            my ($rm, $rf) = $self->navigate($2);
            $fail |= $rf;   
        }
    }
    elsif ($cmd =~ /^(play)(.*)/)
    {
	    $fail |= $self->{_roku}->sendCommand('PLAY');
        if ($2)
        {
            my ($rm, $rf) = $self->navigate($2);
            $fail |= $rf;   
        }
    }
    elsif ($cmd =~ /^(back)(.*)/)
    {
	    $fail |= $self->{_roku}->sendCommand('BACK');
        if ($2)
        {
            my ($rm, $rf) = $self->navigate($2);
            $fail |= $rf;   
        }
    }
    elsif ($cmd =~ /^(home)(.*)/)
    {
	    $fail |= $self->{_roku}->sendCommand('HOME');
        if ($2)
        {
            my ($rm, $rf) = $self->navigate($2);
            $fail |= $rf;   
        }
    }
    elsif ($cmd =~ /^(ok|okay|select|enter)(.*)/)
    {
	    $fail |= $self->{_roku}->sendCommand('SELECT');
        if ($2)
        {
            my ($rm, $rf) = $self->navigate($2);
            $fail |= $rf;   
        }
    }
    elsif ($cmd =~ m/(done|quit|cancel|end|stop|return)/)
    {
        return ("Finished navigating", 0);
    }
    return ("Navigate?", $fail ? 0 : "navigate");
}

return 1;
