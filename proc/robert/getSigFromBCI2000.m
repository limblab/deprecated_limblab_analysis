function sig=getSigFromBCI2000(signal,parameters,SIGNALTOUSE)

switch SIGNALTOUSE
    case 'force'
        sig=signal(:,strcmpi(parameters.ChannelNames.Value,SIGNALTOUSE));
end
