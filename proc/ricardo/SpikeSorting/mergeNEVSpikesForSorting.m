
file_prefix = 'Kevin_2013-06-12_';
filepath = 'D:\Data\Kevin_12A2\Data\';
NEVlist = dir([filepath file_prefix '*.nev']);

if cellfun('isempty',strfind({NEVlist.name},'-spikes-s'))
    NEVlist = NEVlist(cellfun('isempty',(regexp({NEVlist(:).name},'-s'))));
    NEVNSx_all = concatenate_NEVs(filepath,file_prefix);
    saveNEVOnlySpikes(NEVNSx_all.NEV, filepath, [file_prefix '-spikes.nev'])
else
    % Un-merge
    NEV_sorted = openNEV('read',[filepath file_prefix '-spikes-s.nev']);
    for iFile = 1:length(NEVNSx_all.MetaTags.NEVlist) 
        t_offset = (NEVNSx_all.MetaTags.FileStartSec(iFile))*30000;
        NEV_spikes_struct(iFile) = NEV_sorted.Data.Spikes;
        first_idx = find(NEV_sorted.Data.Spikes.TimeStamp >= NEVNSx_all.MetaTags.FileStartSec(iFile)*30000,1,'first');
        if iFile < length(NEVNSx_all.MetaTags.NEVlist)
            last_idx = find(NEV_sorted.Data.Spikes.TimeStamp < NEVNSx_all.MetaTags.FileStartSec(iFile+1)*30000,1,'last');
        else
            last_idx = length(NEV_sorted.Data.Spikes.TimeStamp);
        end
        NEV_spikes_struct(iFile).TimeStamp =  NEV_spikes_struct(iFile).TimeStamp(first_idx:last_idx) - t_offset;
        NEV_spikes_struct(iFile).Electrode =  NEV_spikes_struct(iFile).Electrode(first_idx:last_idx);
        NEV_spikes_struct(iFile).Unit =  NEV_spikes_struct(iFile).Unit(first_idx:last_idx);
        NEV_spikes_struct(iFile).Waveform =  NEV_spikes_struct(iFile).Waveform(:,first_idx:last_idx);
        NEV = openNEV('read', [filepath NEVNSx_all.MetaTags.NEVlist{iFile}],'nosave');
        NEV.Data.Spikes = NEV_spikes_struct(iFile);
        save([filepath NEVNSx_all.MetaTags.NEVlist{iFile}(1:end-4) '-s'],'NEV')
    end
end