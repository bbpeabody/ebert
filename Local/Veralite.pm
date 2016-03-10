#!/usr/bin/perl

package Local::Veralite;

sub switch 
{
    # when $on == 1, turn the switch on, else turn it off
    my ($deviceNum, $on) = @_;
    return 'data_request?id=action&output_format=xml&DeviceNum=' 
        . $deviceNum 
        . '&serviceId=urn:upnp-org:serviceId:SwitchPower1&action=SetTarget&newTargetValue='
        . $on;
}

sub dim 
{
    my ($deviceNum, $brightnessPercentage) = @_;
    return 'data_request?id=action&output_format=json&DeviceNum='
        . $deviceNum
        . '&serviceId=urn:upnp-org:serviceId:Dimming1&action=SetLoadLevelTarget&newLoadlevelTarget='
        . $brightnessPercentage;
}

my %codes = (

BONUS_ROOM_LIGHT_OFF    => switch   ( 3,  0),
BONUS_ROOM_LIGHT_ON     => dim      ( 3,100),
BONUS_ROOM_LIGHT_DIM_20 => dim      ( 3, 20),
BONUS_ROOM_LIGHT_DIM_40 => dim      ( 3, 40),
BONUS_ROOM_LIGHT_DIM_60 => dim      ( 3, 60),
BONUS_ROOM_LIGHT_DIM_80 => dim      ( 3, 80),
MOVIES_SIGN_OFF         => switch   ( 5,  0),
MOVIES_SIGN_ON          => dim      ( 5,100),
MOVIES_SIGN_DIM_20      => dim      ( 5, 20),
MOVIES_SIGN_DIM_40      => dim      ( 5, 40),
MOVIES_SIGN_DIM_60      => dim      ( 5, 60),
MOVIES_SIGN_DIM_80      => dim      ( 5, 80),
BONUS_ROOM_FAN_OFF      => switch   ( 4,  0),
BONUS_ROOM_FAN_ON       => switch   ( 4,  1)

);

sub codes
{
    return \%codes;
}

return 1;

