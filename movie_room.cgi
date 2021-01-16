#!/usr/bin/perl
use strict;
use CGI;
use JSON;
use Data::Dumper;
use File::Basename qw(dirname basename);
use Regexp::Assemble;
use Cwd qw(abs_path);

# Use the script's directory as a perl library source.  This is necessary so perl 
# can find all of the .pm perl modules in subsequent 'use' statements
use lib dirname(abs_path($0));

# Define the base filename to be used for log files.  It will the script's directory
# plus /log/scriptname (minus the extension).
use constant LOG_FILE => dirname(abs_path($0)) . '/log/' . basename($0);
use constant APP_ID   => "amzn1.echo-sdk-ams.app.adf3ac0f-e6da-4fe7-ac2e-227ed3a3d845";
use constant USER_ID  => "amzn1.echo-sdk-account.AEAFGWVX25UFP2CQJJINXHLFNVEMUFXNOJIHFMW6DC6PQIPLPVML4";

# These are my perl packages written just for this script
use Local::Log;         # Log class definition
use Local::HomeTheater; # HomeTheater class definition
use Local::Roku;        # Roku package contains codes for controlling Roku devices

# Construct the log object.  Use this logging object to log any warnings/errors/info.  
# This object gets passed to all other objects, so everybody posts log messages to the 
# same file.
my $log = new Local::Log(LOG_FILE);

# Construct the home theater object
my $ht = new Local::HomeTheater($log, "Home Theater");

# Construct the CGI object.  The CGI object provides access to the CGI environment 
# setup by the web server.
my $cgi = CGI->new;                  

# Get the POST data from the webserver.
my $postData = $cgi->param("POSTDATA");  

# Check the request from Amazon and make sure it's what we expect
my ($requestType, $request, $command) = check_request($postData);

# Process the request
if ($requestType eq "IntentRequest")
{
    my ($response, $attribute) = process_command($command);
    send_response($response, $attribute, $request);
} 
elsif ($requestType eq "SessionEndedRequest")
{
    # Do nothing
}

# End of main script
exit;

sub process_command
{
    my $command = shift;
    my $functionTable = getFunctionTable();
    # Add the hash with regular expression to subroutine mapping
    my $ra = Regexp::Assemble->new( track => 1 )->add( keys %$functionTable );
    # See if what Alexa sent us matches any of our regular expressions
    if ($ra->match($command))
    {
        # We had a match, so get the exact regular expression that matched
        my $m = $ra->matched;
        $log->info("'$command' matched '$m'");
        # Call the sub that is the hash value to the regular expression key
        return &{$functionTable->{$m}}($command);
    }
    else
    {
        # We didn't match any of our regular expressions, so return a response stating 
        # that we didn't understand the command
        return ("The Home Theater did not understand $command", 0);
    }
}

sub send_response
{
    my $response = shift;
    my $attribute = shift;
    my $request = shift;
    $log->info("Response = " . $response);
    my $json_hash = {};
    my $response_hash = {};
    my $outputSpeech_hash = {};
    my $card_hash = {};
    my $reprompt_hash = {};
    my $sessionAttributes_hash = {
        previous_command => $attribute
    };
    $json_hash->{version} = $request->{version};
    #$json_hash->{sessionAttributes} = JSON::null;
    $json_hash->{sessionAttributes} = $attribute ? $sessionAttributes_hash : JSON::null; 
    $json_hash->{response} = $response_hash;

    $response_hash->{outputSpeech} = $outputSpeech_hash;
    $response_hash->{card} = $card_hash;
    $response_hash->{reprompt} = $reprompt_hash;
    $response_hash->{shouldEndSession} = $attribute ? JSON::false : JSON::true;
    
    $outputSpeech_hash->{type} = "PlainText";
    $outputSpeech_hash->{text} = $response;
    
    $card_hash->{type} = "Simple";
    $card_hash->{title} = $response;
    $card_hash->{content} = $response;
    
    $reprompt_hash->{outputSpeech} = $outputSpeech_hash;
    my $json = encode_json $json_hash;
    print "Content-Type: application/json;charset=UTF-8\nContent-Length: " . length($json) . "\n\n";
    print $json;
}

sub check_request
{
    my $jsonEncodedRequest = shift;
    # Convert the JSON encoded object into a perl hash.
    my $decodedRequest = decode_json $jsonEncodedRequest;
    $log->info(Dumper($decodedRequest));  
    my $checkIntentType = "IntentRequest";
    my $checkSessionEndedType = "SessionEndedRequest";
    my $checkCommandName = "command";
    my $appId = $decodedRequest->{session}->{application}->{applicationId};
    my $userId = $decodedRequest->{session}->{user}->{userId};
    my $type = $decodedRequest->{request}->{type};
    my $commandName = $decodedRequest->{request}->{intent}->{slots}->{command}->{name};
    my $previousCommand = $decodedRequest->{session}->{attributes}->{previous_command};
    if ($appId ne APP_ID)
    {
        $log->error("Request 'aplicationId' is invalid. Received: $appId Expected: " . APP_ID);
        die;
    }    
    if ($userId ne USER_ID)
    {
        $log->error("Request 'userId' is invalid. Received: $userId Expected: " . USER_ID);
        die;
    }    
    if ($type ne $checkIntentType && $type ne $checkSessionEndedType)
    {
        $log->error("Request 'type' is invalid. Received: $type Expected: $checkIntentType OR $checkSessionEndedType");
        die;
    }    
    if ($commandName ne $checkCommandName)
    {
        $log->error("Request 'command->name'is invalid. Received: $commandName Expected: $checkCommandName");
        die;
    }    
    my $cmd = $previousCommand . " " . $decodedRequest->{request}->{intent}->{slots}->{command}->{value};
    $log->info("Received valid request with command = '$cmd'");
    return ($type, $decodedRequest, $cmd);
}

sub getFunctionTable
{
    # Returns a hash reference.  The hash keys are regular expressions that are used to 
    # to match the spoken words received from the Alexa skill.  The hash values are
    # subroutines that are called when an Alexa command matches the regular expression.
    my $rokuWatchHash = Local::Roku::watchList();
    my $rokuChannels = join("|", keys(%$rokuWatchHash));
    my %h = (
        # Match examples 'turn the theater on', 'system on',  'turn on the cinema'
         '^(?=.*\b(theater|movie|cinema|tv|television|system)\b)(?=.*\bon\b).*$'            
            => sub  { return $ht->on; }

        # Match examples 'turn the theater off', 'system off',  'turn off the cinema'
        ,'^(?=.*\b(theater|movie|cinema|tv|television|system)\b)(?=.*\boff\b).*$'           
            => sub  { return $ht->off; }
    
        # Match examples 'turn it up', 'increase the volume', 'crank it up', 'louder' 
        ,'^(?=.*\b(turn|crank|volume)\b)(?=.*\b(up|high|increase|higher)\b).*$'         
            => sub  { return $ht->volumeUp; }
        ,'\bloud'                     
            => sub  { return $ht->volumeUp; }
        
        # Match examples 'turn it down', 'volume decrease', 'lower the volume'  
        ,'^(?=.*\b(turn|crank|volume)\b)(?=.*\b(down|low|decrease|lower)\b).*$'         
            => sub  { return $ht->volumeDown; }
        
        ,'\b(mute|quiet|unmute)\b'
            => sub  { return $ht->muteToggle; }
       
        # Calls the search sub and passes the Alexa command for further parsing so 
        # the search words can be extracted from the command 
        ,'\b(search|find)\b'
            => sub  { return $ht->search(shift); }
        
        # Match examples 'watch netflix', 'listen to pandora', 'switch to espn'
        ,'^(?=.*\b(watch|turn|switch|listen|open|launch)\b)(?=.*\b(' . $rokuChannels . ')\b).*$'            
            => sub  { return $ht->watch(shift); }
        
        # Match examples 'turn the lights off', 'lights off'
        ,'^(?=.*\b(light|lights|lite|lites)\b)(?=.*\boff\b).*$'            
            => sub  { return $ht->lightsOff; }
        
        # Match examples 'dim the lights', 'lights dim'
        ,'^(?=.*\b(light|lights|lite|lites)\b)(?=.*\bdim\b).*$'            
            => sub  { return $ht->lightsDim; }
        
        # Match examples 'turn the lights on', 'lights on'
        ,'^(?=.*\b(light|lights|lite|lites)\b)(?=.*\bon\b).*$'            
            => sub  { return $ht->lightsOn; }
        
        # Match examples 'turn the fan on', 'fans on', 'turn on the fan'
        ,'^(?=.*\b(fan|fans)\b)(?=.*\bon\b).*$'            
            => sub  { return $ht->fanOn; }
        
        # Match examples 'turn the fan off', 'fans off', 'turn off the fan'
        ,'^(?=.*\b(fan|fans)\b)(?=.*\boff\b).*$'            
            => sub  { return $ht->fanOff; }
        
        # Match examples 'play', 'resume', 'continue'
        ,'^(?=.*\b(play|resume|continue)\b).*$'            
            => sub  { return $ht->playRoku; }
        
        # Match examples 'pause', 'stop'
        ,'^(?=.*\b(pause|stop)\b).*$'            
            => sub  { return $ht->pauseRoku; }
        
        # Match examples 'navigate'
        ,'^(?=.*\b(navigate)\b).*$'            
            => sub  { return $ht->navigate(shift); }
        
        # Match examples 'keyboard'
        ,'^(?=.*\b(letters|alphabet|letter|keyboard|type|typing)\b).*$'            
            => sub  { return $ht->keyboard(shift); }
    );
    return \%h;
}



1;
