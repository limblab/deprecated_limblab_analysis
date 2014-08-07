% CorrelatePDsByCounts
filelist= Mini_MSP_DaysNames;
datenames = Mini_MSP_datenames;
type = 'Spike';

if strcmpi(filelist{1}(1:4),'Mini')        
    [datelist, DateNames] = CalcDecoderAge(datenames, '08-24-2011')
    shuntedCh = Mini_shuntedCh;    
    if strcmpi(type,'lfp')
        bestf_bychan = sortrows([bestf_Mini' bestc_Mini'],2);
        bestc_bychan = bestf_bychan(:,2);
        bestf_bychan(:,2) = [];
        featindBEST = featindBEST_Mini;
    end
    DecoderStartDate = '08-24-2011';   
elseif strcmpi(filelist{1}(1:4),'Chew')
    [datelist, DateNames] = CalcDecoderAge(filelist, '09-01-2011')
    shuntedCh = Chewie_shuntedCh;
    if strcmpi(type,'lfp')
        bestf_bychan = sortrows([bestf_Chewie' bestc_Chewie'],2);
        bestc_bychan = bestf_bychan(:,2);
        bestf_bychan(:,2) = [];
        featindBEST = featindBEST_Chewie;
    end
    DecoderStartDate = '09-01-2011';
end
%% Load PD output files 
for i=1:length(filelist)

    fnam = [filelist{i,1}]

    try
        if strcmpi(type,'spike')
            load([fnam(1:end-4),'spikePDs_allchans_bs-1cos'],...
            'spike_counts','SpikePDs')
        else 
        load([fnam(1:end-4),'_pdsallchanspos_bs-1wsz150mnpow_AllFreq_LFPcounts'],...
            'LFPcounts','LMPcounts')
        end
    catch
        continue
    end
    
    if exist('LFPcounts','var')
        
        for j = 1:size(LFPcounts,1)
            for k = 1:size(LFPcounts,2)
                
                All_Non_LMP_counts(:,j,k,i) = cellfun(@mean,LFPcounts{j,k});
                
            end
        end
        
        for k = 1:size(LMPcounts,2)
            
            All_LMP_counts(:,k,i) = cellfun(@mean,LMPcounts{1,k});
            
        end
    
    elseif exist('spike_counts','var')
       for k = 1:size(spike_counts,2)

           All_Spike_counts(:,spikePDs{1,1}(k,1),i) = cellfun(@mean,spike_counts{1,k});
       end
    end 

end; clear i j fnam bestf_Chewie bestc_Chewie bestf_Mini bestc_Mini LMPcounts...
    LFPcounts
%% Take out shunts and average counts
if exist('All_LMP_counts','var')
    Lia = ismember(bestc_bychan,shuntedCh);
    bestc_NoShunt = bestc_bychan(~Lia)
    bestf_NoShunt = bestf_bychan(~Lia);
    h = 1;    
    for g = 1:length(bestc_NoShunt)        
        if bestf_NoShunt(g) == 1
            OnlineFeats(:,h,:) = All_LMP_counts(:,bestc_NoShunt(g),:);
            h=h+1;
        elseif bestf_NoShunt(g) == 2
            continue
        else
            OnlineFeats(:,h,:) = squeeze(All_Non_LMP_counts(:,bestc_NoShunt(g),bestf_NoShunt(g)-1,:));
            h = h+1;
        end        
    end; clear g h
    
    AllfeatInds = 1:576;
    OfflineFeatInds = setdiff(AllfeatInds,featindBEST);
    [Offlinebestc Offlinebestf] = CalcCh_Feat_fromFeatInd(OfflineFeatInds);
    
    Lia = ismember(Offlinebestc, bestc_bychan);
    bestc_Indirect = Offlinebestc(~Lia)
    bestf_Indirect = Offlinebestf(~Lia);
    
    h = 1;
    for g = 1:length(bestc_Indirect)
        
        if bestf_Indirect(g) == 1
            
            OfflineFeats(:,h,:) = All_LMP_counts(:,bestc_Indirect(g),:);
            h=h+1;
            
        elseif bestf_Indirect(g) == 2
            
            continue
        else
            
            OfflineFeats(:,h,:) = squeeze(All_Non_LMP_counts(:,bestc_Indirect(g),bestf_Indirect(g)-1,:));
            h = h+1;
        end
    end; clear g h
else
    chans = spikePDs{1,1}(:,1);
    Lia = ismember(chans,shuntedCh);
    chans_NoShunt = chans(~Lia)
    for g = 1:length(chans_NoShunt)
            OnlineFeats(:,g,:) = All_Spike_counts(:,chans_NoShunt(g),:);
    end; clear g
end

%% Now put counts into a vector, day average, and make correlation map
All_Freq_counts_Vector = reshape(OnlineFeats,size(OnlineFeats,1)*size(OnlineFeats,2),size(filelist,1));

[DayAvgDataX,~,DayNames] = DayAverage(All_Freq_counts_Vector, All_Freq_counts_Vector, filelist(:,1), datelist(:,2));

[rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
        CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))

if strcmpi(type,'lfp')
All_Offline_Freq_counts_Vector = reshape(OfflineFeats,size(OfflineFeats,1)*size(OfflineFeats,2),size(filelist,1));
[DayAvgDataOfflineX,~,DayNames] = DayAverage(All_Offline_Freq_counts_Vector, All_Offline_Freq_counts_Vector, filelist(:,1), datelist(:,2));

[rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
        CorrCoeffMap(DayAvgDataOfflineX,1,DayNames(:,2))
end