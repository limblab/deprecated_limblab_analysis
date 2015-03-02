function status = processSpikesForSorting(file_path,file_prefix)
% processSpikesForSorting combines spike data from .nev files in file_path that match
%   file_prefix string.  Saves spike data to new file named '(file_prefix)-spikes.nev'.
%   After running, sort spikes in Plexon OfflineSorter and save as '(file_prefix)-spikes-s.nev'.
%   Run this script again after spike sorting to separate into independent 
%   .mat files.

    if ~exist([file_path file_prefix '-spikes-metatags.mat'],'file')
        % Merge spike data
        NEVlist = dir([file_path file_prefix '*.nev']);
        NEVlist = NEVlist(cellfun('isempty',(regexp({NEVlist(:).name},'-s'))));
        disp(['Merging ' num2str(length(NEVlist)) ' files.'])
        NEVNSx_all = cerebus2NEVNSx(file_path,file_prefix);
        NEVNSx_all.NEV = artifact_removal(NEVNSx_all.NEV,10,0.0005,1);
        saveNEVSpikesLimblab(NEVNSx_all.NEV, file_path, [file_prefix '-spikes.nev'])
        MetaTags = NEVNSx_all.MetaTags;
        save([file_path file_prefix '-spikes-metatags'],'MetaTags')
        status = 'merged spikes';
    else
        % Un-merge
        load([file_path file_prefix '-spikes-metatags'],'MetaTags')
        if exist([file_path file_prefix '-spikes-s.nev'],'file')        
            NEV_sorted = openNEVLimblab('read',[file_path file_prefix '-spikes-s.nev']);
            disp(['Separating ' num2str(length(MetaTags.NEVlist) ) ' files.'])
            for iFile = 1:length(MetaTags.NEVlist) 
                t_offset = (MetaTags.FileStartSec(iFile))*30000;
                NEV_spikes_struct = NEV_sorted.Data.Spikes;
                first_idx = find(NEV_sorted.Data.Spikes.TimeStamp >= MetaTags.FileStartSec(iFile)*30000,1,'first');
                if iFile < length(MetaTags.NEVlist)
                    last_idx = find(NEV_sorted.Data.Spikes.TimeStamp < MetaTags.FileStartSec(iFile+1)*30000,1,'last');
                else
                    last_idx = length(NEV_sorted.Data.Spikes.TimeStamp);
                end
                NEV_spikes_struct.TimeStamp =  NEV_spikes_struct.TimeStamp(first_idx:last_idx) - t_offset;
                NEV_spikes_struct.Electrode =  NEV_spikes_struct.Electrode(first_idx:last_idx);
                NEV_spikes_struct.Unit =  NEV_spikes_struct.Unit(first_idx:last_idx);
                NEV_spikes_struct.Waveform =  NEV_spikes_struct.Waveform(:,first_idx:last_idx);
                NEV = openNEVLimblab('read', [file_path MetaTags.NEVlist{iFile}],'nosave');
                NEV.Data.Spikes = NEV_spikes_struct;
                save([file_path MetaTags.NEVlist{iFile}(1:end-4) '-s'],'NEV')
            end
            delete([file_path file_prefix '-spikes-metatags.mat'])
            status = 'processed';
        else
            status = 'merged spikes';
        end
    end