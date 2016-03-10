#!/usr/bin/perl

# Define a perl OO class
package Local::Log;

sub new
{
	my $class = shift;
	my $self = {
		_name	     => shift,
        _numLogFiles => shift || 10,
        _maxLogSize  => shift || 1E6
	};
	bless $self, $class;
	return $self;
}

sub getFilename
{
	my $self = shift;
    my $logNum = shift || 0;
    if ($logNum)
    {
        return $self->{_name} . ".$logNum.log";
    }
    else
    {
        return $self->{_name} . ".log";
    }
}

sub error
{
    my ($self, $err) = @_;
    $self->writeFile("ERR  $err") if defined($err);
}

sub warn
{
    my ($self, $warn) = @_;
    $self->writeFile("WARN $warn") if defined($warn);
}

sub info
{
    my ($self, $info) = @_;
    $self->writeFile("INFO $info") if defined($info);
}

sub writeFile
{
    my ($self, $msg) = @_;
    return if (! defined ($msg) );
	chomp ($msg);
    $self->rotateLog;
    open FH, ">>" . $self->getFilename;
    print FH $self->getTime() . " $msg\n";
    close FH;
}

sub rotateLog
{
    my $self = shift;
    if (-e $self->getFilename)
    {
        my $filesize = -s $self->getFilename;
        if ($filesize > $self->{_maxLogSize})
        {
            my $maxFile = $self->{_numLogFiles} - 1;
            # Delete the oldest log file
            if (-e $self->getFilename($maxFile))
            {
                unlink($self->getFilename($maxFile));
            }
            # Shift all log files down.  Oldest log file will have highest number
            for( my $i = $maxFile-1; $i >= 0; $i--)
            {
                if (-e $self->getFilename($i))
                {
                    rename $self->getFilename($i), $self->getFilename($i+1);
                }
            }
        } 
    } 
    if (! -e $self->getFilename)
    {
        open FH, ">" . $self->getFilename or die;
        close FH;
        $self->info("LOG STARTED");
        return 0;
    }
}

sub getTime
{
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime();
    return sprintf("%02d/%02d/%04d %02d:%02d:%02d", $mon+1, $mday, $year + 1900, $hour, $min, $sec);
}

return 1;

