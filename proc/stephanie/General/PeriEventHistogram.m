% Peri-event histogram
% Plots rasters with respect to the 'go' word

% The 'go' word is 49
go_ind = find(out_struct.words(:,2)==49);

%PreWord time
preWord = 0.5;
%PostWord time
postWord = 0.5;


Tstart = go_ind+preWord;
Tend = go_ind-postWord;


 for i=1%:96
     subplot(4,24,i)
     spikes = out_struct.units(1,i).ts;
     trialSpikes = find(spikes
 end
 
 
 
 
 
 
%Word_start
start = find(out_struct.words(:,2)==23);
%Word_end
end = find(out_struct.words(:,2)==32);
