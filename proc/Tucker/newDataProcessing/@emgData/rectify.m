function rectify(emg)
    %this is a method function for the emgData class, and should be saved
    %in the @emgData folder
    %
    %emg.rectify()
    %rectifies all channels in emg.data. takes no inputs and returns
    %nothing
    tmp=emg.data;
    tmp{:,2:end}=abs(tmp{:,2:end});
    set(emg,'data',tmp)

    evntData=loggingListenerEventData('rectify',[]);
    notify(emg,'rectified',evntData)
end