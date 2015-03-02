function saveNEVOnlyDigital(NEV,savename)

% saves only the non spikes information from an NEV object in a .mat file
% intended for use with saveNEVOnlySpikes to make offline sorter less
% painful
    NEV.Data.Spikes=[];
   
    save(savename,'NEV')
end