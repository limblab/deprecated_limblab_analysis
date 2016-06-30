%% Input
% Filelist
% featindBEST_  - Feature Index (if LFPs)
% shuntedCh 

% CorrelatePDsByCounts
filelist= Chewie_LFP1_tsNum;
datenames = Chewie_LFP1_tsNum;
Controltype = 'LFP1';
Signaltype = 'LFP1';
% LFP1, LFP2, AllLFP or Spike

startind = 1;
% Chewie LFP1 = 117 ([117:267 288:end] - Cut out May files because of loose
% connector
% Mini LFP1 = 52

PDByBand = 0; % Plot PD SI by band
MDByBand = 0; % Plot MD SI by band
NeuronSubset = 0 % Look at SI by neuron subsets (need to load R2 performances)
% Number of times to select a random subset of LFP features to test for
% stability.
numSim = 50;

MissingFilesList = filelist(startind:end,:);
MissingFilesListInd = [];

if strcmpi(filelist{1}(1:4),'Mini') 
    if strcmpi(Controltype,'lfp1')
        [datelist, DateNames] = CalcDecoderAge(datenames, '08-24-2011');
        DecoderStartDate = '08-24-2011'; 
    elseif strcmpi(Controltype,'lfp2')
        [datelist, DateNames] = CalcDecoderAge(datenames, '04-13-2012');
        DecoderStartDate = '04-13-2012'; 
    elseif strcmpi(Controltype,'spike')
        [datelist, DateNames] = CalcDecoderAge(datenames, '08-24-2011');
        DecoderStartDate = '08-24-2011'; 
    end
    
    shuntedCh = Mini_shuntedCh;
    if strcmpi(Controltype,'lfp1') || strcmpi(Signaltype,'lfp1') || ...
            strcmpi(Controltype,'lfp2') || strcmpi(Signaltype,'lfp2') || ...
            strcmpi(Signaltype,'AllLFP')
        if exist('bestf_Mini','var') == 0 && ( strcmpi(Controltype,'lfp1') || strcmpi(Signaltype,'lfp1') )
            [bestc_Mini bestf_Mini] = CalcCh_Feat_fromFeatInd(LFP1_featindBEST_Mini);
            featindBEST = LFP1_featindBEST_Mini;
        elseif exist('bestf_Mini','var') == 0 && ( strcmpi(Controltype,'lfp2') || strcmpi(Signaltype,'lfp2') )
            [bestc_Mini bestf_Mini] = CalcCh_Feat_fromFeatInd(LFP2_featIndBEST_Mini);
            featindBEST = LFP2_featIndBEST_Mini;
        elseif exist('bestf_Mini','var') == 0 && ( strcmpi(Controltype,'AllLFP') || strcmpi(Signaltype,'AllLFP') )
            bestc_Mini = reshape(repmat(1:96,6,1) ,1,576);
            bestf_Mini = reshape(repmat(1:6,1,96) ,1,576);
            featindBEST = 1:576;
        end
        bestf_bychan = sortrows([bestf_Mini' bestc_Mini'],2);
        bestc_bychan = bestf_bychan(:,2);
        bestf_bychan(:,2) = [];
    end
      
elseif strcmpi(filelist{1}(1:4),'Chew')
    if strcmpi(Controltype,'lfp1')
        [datelist, DateNames] = CalcDecoderAge(datenames, '09-01-2011');
        DecoderStartDate = '09-01-2011'; 
    elseif strcmpi(Controltype,'lfp2')
        [datelist, DateNames] = CalcDecoderAge(datenames, '04-13-2012');
        DecoderStartDate = '04-13-2012'; 
    elseif strcmpi(Controltype,'spike')
        [datelist, DateNames] = CalcDecoderAge(datenames, '09-01-2011');
        DecoderStartDate = '09-01-2011';
    end
    
    shuntedCh = Chewie_shuntedCh;
    if strcmpi(Controltype,'lfp1') || strcmpi(Signaltype,'lfp1') || ...
            strcmpi(Controltype,'lfp2') || strcmpi(Signaltype,'lfp2') ...
            || strcmpi(Signaltype,'AllLFP')
        if exist('bestf_Chewie','var') == 0 && (strcmpi(Controltype,'lfp1') || strcmpi(Signaltype,'lfp1'))
            [bestc_Chewie bestf_Chewie] = CalcCh_Feat_fromFeatInd(LFP1_featindBEST_Chewie);
            featindBEST = LFP1_featindBEST_Chewie;
        elseif exist('bestf_Chewie','var') == 0 && (strcmpi(Controltype,'lfp2') || strcmpi(Signaltype,'lfp2'))
            [bestc_Chewie bestf_Chewie] = CalcCh_Feat_fromFeatInd(LFP2_featIndBEST_Chewie);
            featindBEST = LFP2_featIndBEST_Chewie;
        elseif exist('bestf_Chewie','var') == 0 && ( strcmpi(Controltype,'AllLFP') || strcmpi(Signaltype,'AllLFP') )
            bestc_Chewie = reshape(repmat(1:96,6,1) ,1,576);
            bestf_Chewie = reshape(repmat(1:6,1,96) ,1,576);
            featindBEST = 1:576;
        end
        bestf_bychan = sortrows([bestf_Chewie' bestc_Chewie'],2);
        bestc_bychan = bestf_bychan(:,2);
        bestf_bychan(:,2) = [];
    end
end
MissingFilesDateList = datelist;
%% Load PD output files 
for i=startind:length(filelist)

    fnam = [filelist{i,1}]

    try  
        if strcmpi(Signaltype,'spike')
            load([fnam(1:end-4),'spikePDs_allchans_bs-1cos'],...
            'spike_counts','spikePDs')
        elseif strcmpi(Controltype,'lfp1') && strcmpi(filelist{1}(1:4),'Chew') || strcmpi(Signaltype,'AllLFP') && strcmpi(filelist{1}(1:4),'Chew')
            try
                load([fnam(1:end-4),'_pdsallchanspos_bs-1wsz150mnpowlogLMP_and_AllFreqcos.mat'],...
                    'LFPcounts','LMPcounts','LFPfilesLMP_PDs','LFPfilesPDs')
                load([fnam(1:end-4),'_pdsallchanspos_bs-1wsz150mnpow_AllFreq_LFPcounts.mat'],...
                        'LFPcounts','LFP_counts','LMPcounts','LFPfilesLMP_PDs','LFPfiles_PDs')  
                %              '_pdsallchanspos_bs-1wsz100mnpowlogAllFreqcos.mat'],... % Chewie's Non-LMP PD file extension
                %              _pdsallchanspos_bs-1wsz150mnpowlogLMP_and_AllFreqcos'],...
                
                try
                    load([fnam(1:end-4),'_pdsallchanspos_bs-1wsz150mnpow_Delta_LFPcounts.mat'],...
                        'LFPcounts','LFP_counts')
                end
                if exist('LFPcounts','var')
                    AllFreqLFPcounts = LFPcounts;
                    clear LFPcounts
                elseif exist('LFP_counts','var')
                    AllFreqLFPcounts = LFP_counts;
                    clear LFP_counts
                end
                        
                if exist('LFPcounts','var')
                    DeltaCounts = LFPcounts;
                    if size(AllFreqLFPcounts,2) == 5
                        LFPcounts(:,[1 3:6]) = AllFreqLFPcounts;
                    else
                        LFPcounts(:,[1 3:6]) = AllFreqLFPcounts(:,[1 3:6]);
                    end
                    LFPcounts(:,2) = DeltaCounts;
                elseif exist('LFP_counts','var')
                    DeltaCounts = LFP_counts;
                    if size(AllFreqLFPcounts,2) == 5
                        LFPcounts(:,[1 3:6]) = AllFreqLFPcounts;
                    else
                        LFPcounts(:,[1 3:6]) = AllFreqLFPcounts(:,[1 3:6]);
                    end
                    LFPcounts(:,2) = DeltaCounts;
                    clear LFP_counts
                end
            catch 
                try
                    
                    load([fnam(1:end-4),'_pdsallchanspos_bs-1wsz150mnpow_AllFreq_LFPcounts.mat'],...
                        'LFPcounts','LFP_counts','LMPcounts','LFPfilesLMP_PDs','LFPfiles_PDs')
                    try
                        load([fnam(1:end-4),'_pdsallchanspos_bs-1wsz150mnpowlogLMP_and_AllFreqcos.mat'],...
                    'LFPcounts','LMPcounts','LFPfilesLMP_PDs','LFPfilesPDs')
                    end
                    
                    if exist('LFPcounts','var')
                        AllFreqLFPcounts = LFPcounts;
                        clear LFPcounts
                    elseif exist('LFP_counts','var')
                        AllFreqLFPcounts = LFP_counts;
                        clear LFP_counts
                    end
                        
                    load([fnam(1:end-4),'_pdsallchanspos_bs-1wsz150mnpow_Delta_LFPcounts.mat'],...
                        'LFPcounts','LFP_counts')
                
                    if exist('LFPcounts','var')
                        DeltaCounts = LFPcounts;
                        if size(AllFreqLFPcounts,2) == 5
                            LFPcounts(:,[1 3:6]) = AllFreqLFPcounts;
                        else
                            LFPcounts(:,[1 3:6]) = AllFreqLFPcounts(:,[1 3:6]);
                        end
                        LFPcounts(:,2) = DeltaCounts;
                    elseif exist('LFP_counts','var')
                        DeltaCounts = LFP_counts;
                        if size(AllFreqLFPcounts,2) == 5
                            LFPcounts(:,[1 3:6]) = AllFreqLFPcounts;
                        else
                            LFPcounts(:,[1 3:6]) = AllFreqLFPcounts(:,[1 3:6]);
                        end
                        LFPcounts(:,2) = DeltaCounts;
                        clear LFP_counts
                    end
                catch  
                    try
                        load([fnam(1:end-4),'_pdsallchanspos_bs-1wsz150mnpow_AllFreq_LFPcounts'],...
                            'LFPcounts','LFP_counts','LMPcounts')
                        if exist('LFPcounts','var')
                            AllFreqLFPcounts = LFPcounts;
                            clear LFPcounts
                        elseif exist('LFP_counts','var')
                            AllFreqLFPcounts = LFP_counts;
                            clear LFP_counts
                        end
                        load([fnam(1:end-4),'_pdsallchanspos_bs-1wsz150mnpow_Delta_LFPcounts.mat'],...
                            'LFPcounts','LFP_counts')
                
                        if exist('LFPcounts','var')
                            DeltaCounts = LFPcounts;
                            if size(AllFreqLFPcounts,2) == 5
                                LFPcounts(:,[1 3:6]) = AllFreqLFPcounts;
                            else
                                LFPcounts(:,[1 3:6]) = AllFreqLFPcounts(:,[1 3:6]);
                            end
                            LFPcounts(:,2) = DeltaCounts;
                        elseif exist('LFP_counts','var')
                            DeltaCounts = LFP_counts;
                            if size(AllFreqLFPcounts,2) == 5
                                LFPcounts(:,[1 3:6]) = AllFreqLFPcounts;
                            else
                                LFPcounts(:,[1 3:6]) = AllFreqLFPcounts(:,[1 3:6]);
                            end
                            LFPcounts(:,2) = DeltaCounts;
                            clear LFP_counts
                        end
%                     catch
%                         MissingFiles{i} = fnam;
%                         MissingFilesListInd = [MissingFilesListInd i];
%                         continue
                    end
                end
            end
        else
            load([fnam(1:end-4),'_pdsallchanspos_bs-1wsz150mnpow_AllFreq_LFPcounts'],...
                'LFPcounts','LFP_counts','LMPcounts')
            
            if exist('LFPcounts','var')
                AllFreqLFPcounts = LFPcounts;
                clear LFPcounts
            elseif exist('LFP_counts','var')
                AllFreqLFPcounts = LFP_counts;
                clear LFP_counts
            end
            if strcmpi(filelist{1}(1:4),'Mini')
                try
                    load([fnam(1:end-4),'_pdsallchanspos_bs-1wsz150mnpow_Delta_LFPcounts.mat'],...
                        'LFPcounts','LFP_counts')
                end
                if exist('LFPcounts','var')
                    DeltaCounts = LFPcounts;
                    if size(AllFreqLFPcounts,2) == 5
                        LFPcounts(:,[1 3:6]) = AllFreqLFPcounts;
                    else 
                        LFPcounts(:,[1 3:6]) = AllFreqLFPcounts(:,[1 3:6]);
                    end
                    LFPcounts(:,2) = DeltaCounts;
                elseif exist('LFP_counts','var')
                    DeltaCounts = LFP_counts;
                    if size(AllFreqLFPcounts,2) == 5
                        LFPcounts(:,[1 3:6]) = AllFreqLFPcounts;
                    else 
                        LFPcounts(:,[1 3:6]) = AllFreqLFPcounts(:,[1 3:6]);
                    end
                    LFPcounts(:,2) = DeltaCounts;
                    clear LFP_counts
                end
                
            end
        end

%     catch exception
%         MissingFiles{i} = fnam
%         MissingFilesListInd = [MissingFilesListInd i];
%         
%         continue
    end
    if exist('LMPcounts','var') == 0 || exist('LFPcounts','var') == 0
        continue
    end
    if exist('LFPfilesPDs','var') & ~exist('LMPcounts','var')
        for j = 1:size(LFPfilesPDs{1,1},2)
            for k = 1:size(LFPfilesPDs{1,1}{1,1},1)
                
                All_Non_LMP_CI_Range(LFPfilesPDs{1,1}{1,j}(k,5),j,i) = (LFPfilesPDs{1,1}{1,j}(k,3) - LFPfilesPDs{1,1}{1,j}(k,1))*180/pi;
                
            end
        end
    end
    
    if exist('LFPfilesPDs','var') & exist('LMPcounts','var')
            for k = 1:size(LFPfilesPDs{1,1},1)
                
%                 All_LMP_CI_Range(LFPfilesPDs{1,1}(k,5),j,i) = (LFPfilesPDs{1,1}(k,3) - LFPfilesPDs{1,1}(k,1))*180/pi;
                
            end
    end
    
    if exist('LFP_counts','var')            
            LFPcounts = LFP_counts;
            clear LFP_counts;
    end
    
    if exist('LFPcounts','var')   
        
        for j = 1:size(LFPcounts,1)
            for k = 1:size(LFPcounts,2)   
                
                All_Non_LMP_counts(:,j,k,i) = cellfun(@nanmean,LFPcounts{j,k});                
                All_Non_LMP_MDs(j,i,k) = range(All_Non_LMP_counts(:,j,k,i));
                
            end
        end
    end
    
    if exist('LMPcounts','var')  
        for k = 1:size(LMPcounts,2)
            
            All_LMP_counts(:,k,i) = cellfun(@mean,LMPcounts{1,k});
%             All_LMP__CI_Range(LFPfilesLMP_PDs{1,1}(k,1),i) = (LFPfilesLMP_PDs{1,1}(k,3) - LFPfilesLMP_PDs{1,1}(k,1))*180/pi;
            All_LMP_MDs(k,i) = range(All_LMP_counts(:,k,i));
            
        end
    end
    
    if exist('spike_counts','var')
       for k = 1:size(spike_counts,2)

           All_Spike_counts(:,spikePDs{1,1}(k,1),i) = cellfun(@mean,spike_counts{1,k});
           All_Spike_CI_Range(spikePDs{1,1}(k,1),i) = (spikePDs{1,1}(k,5) - spikePDs{1,1}(k,3))*180/pi;
           All_Spike_MDs(spikePDs{1,1}(k,1),i) = range(All_Spike_counts(:,spikePDs{1,1}(k,1),i));
           
           All_Spike_Var(:,spikePDs{1,1}(k,1),i) = cellfun(@std,spike_counts{1,k}).^2;
           All_Spike_Mean(:,spikePDs{1,1}(k,1),i) = cellfun(@mean,spike_counts{1,k});
       end
    end 

end; clear i j fnam bestf_Chewie bestc_Chewie bestf_Mini bestc_Mini LMPcounts...
    LFPcounts spike_counts
% Take out all files that are not in the file list.
if exist('All_LMP_counts','var') & isempty(MissingFilesListInd) == 0
    All_Non_LMP_counts(:,:,:,MissingFilesListInd) = [];
    All_Non_LMP_MDs(:,MissingFilesListInd,:) = [];
    All_LMP_counts(:,:,MissingFilesListInd) = [];
    All_LMP_MDs(:,MissingFilesListInd) = [];
elseif exist('All_Spike_counts','var') & isempty(MissingFilesListInd) == 0
    All_Spike_counts(:,:,MissingFilesListInd) = [];
    All_Spike_CI_Range(:,MissingFilesListInd) = [];
    All_Spike_MDs(:,MissingFilesListInd) = [];
    
    All_Spike_Var(:,:,MissingFilesListInd) = [];
    All_Spike_Mean(:,:,MissingFilesListInd) = [];
end


MissingFilesList(MissingFilesListInd,:) = [];
MissingFilesDateList(MissingFilesListInd,:) = [];
%% Take out shunts and average counts
if exist('All_LMP_counts','var')
%     AllChtoRemov = unique([badChannels; shuntedCh]);
%     Bia = ismember(bestc_bychan, AllChtoRemov);
%     bestc_NoShunt = bestc_bychan(~Bia);
%     bestf_NoShunt = bestf_bychan(~Bia);
    Lia = ismember(bestc_bychan,shuntedCh);
    bestc_NoShunt = bestc_bychan(~Lia);
    bestf_NoShunt = bestf_bychan(~Lia);
    bestc_byFeat = sortrows([bestc_NoShunt bestf_NoShunt],2);
    bestf_byFeat = bestc_byFeat(:,2);
    bestc_byFeat(:,2) = [];
    h = 1;
    l =1;
    mu = 1;
    g1 = 1;
    g2 = 1;
    g3 = 1; 
    del = 1;
    if strcmpi(Signaltype,'AllLFP') || strcmpi(Signaltype,'LFP1') 
%         for g = 1:length(bestc_NoShunt)
%             if bestf_NoShunt(g) == 1
%                 LMPFeats(:,h,:) = All_LMP_counts(:,bestc_NoShunt(g),:);
%                 LMPFeatsMDs(h,:) = All_LMP_MDs(bestc_NoShunt(g),:);
%                 h=h+1;
%             elseif bestf_NoShunt(g) == 2
%                 DeltaFeats(:,del,:) = squeeze(All_Non_LMP_counts(:,bestc_NoShunt(g),bestf_NoShunt(g),:));
%                 DeltaFeatsMDs(del,:) = All_Non_LMP_MDs(bestc_NoShunt(g),:,bestf_NoShunt(g));
%                 del = del+1;
%          
%             elseif bestf_NoShunt(g) == 3
%                 MuFeats(:,mu,:) = squeeze(All_Non_LMP_counts(:,bestc_NoShunt(g),bestf_NoShunt(g),:));
%                 MuFeatsMDs(mu,:) = All_Non_LMP_MDs(bestc_NoShunt(g),:,bestf_NoShunt(g));
%                 mu = mu+1;
%             elseif bestf_NoShunt(g) == 4
%                 Gam1Feats(:,g1,:) = squeeze(All_Non_LMP_counts(:,bestc_NoShunt(g),bestf_NoShunt(g),:));
%                 Gam1FeatsMDs(g1,:) = All_Non_LMP_MDs(bestc_NoShunt(g),:,bestf_NoShunt(g));
%                 g1 = g1+1;
%             elseif bestf_NoShunt(g) == 5
%                 Gam2Feats(:,g2,:) = squeeze(All_Non_LMP_counts(:,bestc_NoShunt(g),bestf_NoShunt(g),:));
%                 Gam2FeatsMDs(g2,:) = All_Non_LMP_MDs(bestc_NoShunt(g),:,bestf_NoShunt(g));
%                 g2 = g2+1;
%             elseif bestf_NoShunt(g) == 6
%                 Gam3Feats(:,g3,:) = squeeze(All_Non_LMP_counts(:,bestc_NoShunt(g),bestf_NoShunt(g),:));
%                 Gam3FeatsMDs(g3,:) = All_Non_LMP_MDs(bestc_NoShunt(g),:,bestf_NoShunt(g));
%                 g3 = g3+1;
%             end
%         end; clear g* h mu del
        
        for g = 1:length(bestc_NoShunt)
            if bestf_NoShunt(g) == 1
                OnlineFeats(:,l,:) = All_LMP_counts(:,bestc_NoShunt(g),:);
%                 OnlineFeats_CI_Range(:,l,:) = All_LMP_CI_Range(:,bestc_NoShunt(g),:);
                OnlineFeatsMDs(l,:) = squeeze(All_LMP_MDs(bestc_NoShunt(g),:));
                l=l+1;
            else
                OnlineFeats(:,l,:) = squeeze(All_Non_LMP_counts(:,bestc_NoShunt(g),bestf_NoShunt(g),:));
%                 OnlineFeats_CI_Range(:,l,:) = squeeze(All_Non_LMP_CI_Range(:,bestc_NoShunt(g),bestf_NoShunt(g)-1,:));
                OnlineFeatsMDs(l,:) = All_Non_LMP_MDs(bestc_NoShunt(g),:,bestf_NoShunt(g));

                l = l+1;
            end
        end; clear g h l
        l =1;
        for g = 1:length(bestc_byFeat)
            if bestf_byFeat(g) == 1
                OnlineFeats_byFeat(:,l,:) = All_LMP_counts(:,bestc_byFeat(g),:);
%                 OnlineFeats_byFeat_CI_Range(:,l,:) = All_LMP_CI_Range(:,bestc_byFeat(g),:);
                OnlineFeats_byFeatMDs(l,:) = squeeze(All_LMP_MDs(bestc_byFeat(g),:));
                bestc_Final(l) = bestc_byFeat(g);
                bestf_Final(l) = bestf_byFeat(g);
                l=l+1;
            else
                OnlineFeats_byFeat(:,l,:) = squeeze(All_Non_LMP_counts(:,bestc_byFeat(g),bestf_byFeat(g),:));
%                 OnlineFeats_byFeat_CI_Range(:,l,:) = squeeze(All_Non_LMP_CI_Range(:,bestc_byFeat(g),bestf_byFeat(g)-1,:));
                OnlineFeats_byFeatMDs(l,:) = All_Non_LMP_MDs(bestc_byFeat(g),:,bestf_byFeat(g));
                bestc_Final(l) = bestc_byFeat(g);
                bestf_Final(l) = bestf_byFeat(g);
                l = l+1;
            end
        end
    else
        for g = 1:length(bestc_NoShunt)
            if bestf_NoShunt(g) == 1
                OnlineFeats(:,h,:) = All_LMP_counts(:,bestc_NoShunt(g),:);
                OnlineFeatsMDs(h,:) = squeeze(All_LMP_MDs(bestc_NoShunt(g),:));
                h=h+1;
            else
                OnlineFeats(:,h,:) = squeeze(All_Non_LMP_counts(:,bestc_NoShunt(g),bestf_NoShunt(g),:));
                OnlineFeatsMDs(h,:) = All_Non_LMP_MDs(bestc_NoShunt(g),:,bestf_NoShunt(g));
                h = h+1;
            end
        end; clear g h l
    
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
                OfflineFeatsMDs(h,:) = squeeze(All_LMP_MDs(bestc_Indirect(g),:));
                h=h+1;
                
            elseif bestf_Indirect(g) == 2
                
                continue
            else
                
                OfflineFeats(:,h,:) = squeeze(All_Non_LMP_counts(:,bestc_Indirect(g),bestf_Indirect(g)-1,:));
                OfflineFeatsMDs(h,:) = All_Non_LMP_MDs(bestc_Indirect(g),:,bestf_Indirect(g)-1);
                h = h+1;
            end
        end; clear g h
    end
else
    chans = spikePDs{1,1}(:,1);
    Lia = ismember(chans,shuntedCh);
    chans_NoShunt = chans(~Lia)
    for g = 1:length(chans_NoShunt)
            OnlineFeats(:,g,:) = All_Spike_counts(:,chans_NoShunt(g),:);
            
            OnlineFeatsMDs(g,:) = All_Spike_MDs(chans_NoShunt(g),:);
            
            OnlineFeats_Var(:,g,:) = All_Spike_Var(:,chans_NoShunt(g),:);
            OnlineFeats_Mean(:,g,:) = All_Spike_Mean(:,chans_NoShunt(g),:);
            
            OnlineFeats_CI_Range(g,:) = All_Spike_CI_Range(chans_NoShunt(g),:);
    end; clear g
end

if exist('r2','var')
    for i = [6]
        
        [bestcSpike] = LFPtoSpikeChTransform(chans_LFPindexing);
        
        OnlineFeats_Top = All_Spike_counts(:,bestcSpike(1:i),:);
        OnlineFeats_TopMD(i,:) = All_Spike_MDs(bestcSpike(i),:);
        
        All_Freq_counts_Vector = reshape(OnlineFeats_Top,size(OnlineFeats_Top,1)*size(OnlineFeats_Top,2),size(OnlineFeats_Top,3));
        
        if nnz(All_Freq_counts_Vector(((i-1)*12)+1:(i*12),:)) < ((size(All_Freq_counts_Vector(((i-1)*12)+1:(i*12),:),1)*size(All_Freq_counts_Vector(((i-1)*12)+1:(i*12),:),2))/2)
            NeuronNoPD(i) = i;
            continue
        end
        
        [DayAvgDataX,~,DayNames] = DayAverage(All_Freq_counts_Vector(:,startind:end), All_Freq_counts_Vector(:,startind:end), MissingFilesList(startind:end,1), MissingFilesDateList(startind:end,2));
        
        [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
            CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))
        SI_mean(i) = mean(rOnline.map_mean);
        title(['Top ',mat2str(i),' Features SI'])
%         close all
    end
    figure
    plot(SI_mean)
end
%% Plot mean vs var and calculate Fano Factors
% All_Var_Vector = reshape(OnlineFeats_Var,size(OnlineFeats_Var,1)*size(OnlineFeats_Var,2),size(OnlineFeats_Var,3));
% All_Mean_Vector = reshape(OnlineFeats_Mean,size(OnlineFeats_Mean,1)*size(OnlineFeats_Mean,2),size(OnlineFeats_Mean,3));
% 
% for fi = 1 :size(All_Mean_Vector,2)
% 
%     p = polyfit(All_Mean_Vector(:,fi),All_Var_Vector(:,fi),1);
%     FanoF(fi) = p(1);
%     
% end

%% Now put counts into a vector, day average, and make correlation map

if strcmpi(Signaltype,'AllLFP')
    
    All_Freq_counts_Vector = reshape(OnlineFeats,size(OnlineFeats,1)*size(OnlineFeats,2),size(OnlineFeats,3));

    [DayAvgDataX,~,DayNames] = DayAverage(All_Freq_counts_Vector(:,startind:end), All_Freq_counts_Vector(:,startind:end), MissingFilesList(startind:end,1), MissingFilesDateList(startind:end,2));

    [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
        CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))
    title('All Features SI')
end

if PDByBand == 1
    LMP_counts_Vector = reshape(LMPFeats,size(LMPFeats,1)*size(LMPFeats,2),size(LMPFeats,3));
    [DayAvgDataX,~,DayNames] = DayAverage(LMP_counts_Vector(:,startind:end), LMP_counts_Vector(:,startind:end), MissingFilesList(startind:end,1), MissingFilesDateList(startind:end,2));
    [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
        CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))
    title('LMP Feature SI')
    
    if exist('MuFeats','var')
        Mucounts_Vector = reshape(MuFeats,size(MuFeats,1)*size(MuFeats,2),size(MuFeats,3));
        [DayAvgDataX,~,DayNames] = DayAverage(Mucounts_Vector(:,startind:end), Mucounts_Vector(:,startind:end), MissingFilesList(startind:end,1), MissingFilesDateList(startind:end,2));
        [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
            CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))
        title('Mu Feature SI')
    end
    
    if exist('Gam1Feats','var')
        Gam1counts_Vector = reshape(Gam1Feats,size(Gam1Feats,1)*size(Gam1Feats,2),size(Gam1Feats,3));
        [DayAvgDataX,~,DayNames] = DayAverage(Gam1counts_Vector(:,startind:end), Gam1counts_Vector(:,startind:end), MissingFilesList(startind:end,1), MissingFilesDateList(startind:end,2));
        [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
            CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))
        title('Gam1 Feature SI')
    end
    
    Gam2counts_Vector = reshape(Gam2Feats,size(Gam2Feats,1)*size(Gam2Feats,2),size(Gam2Feats,3));
    [DayAvgDataX,~,DayNames] = DayAverage(Gam2counts_Vector(:,startind:end), Gam2counts_Vector(:,startind:end), MissingFilesList(startind:end,1), MissingFilesDateList(startind:end,2));
    [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
        CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))
    title('Gam2 Feature SI')
    
    Gam3counts_Vector = reshape(Gam3Feats,size(Gam3Feats,1)*size(Gam3Feats,2),size(Gam3Feats,3));
    [DayAvgDataX,~,DayNames] = DayAverage(Gam3counts_Vector(:,startind:end), Gam3counts_Vector(:,startind:end), MissingFilesList(startind:end,1), MissingFilesDateList(startind:end,2));
    [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
        CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))
    title('Gam3 Feature SI')
    
elseif MDByBand == 1
    
        LMP_counts_Vector = LMPFeatsMDs;
    [DayAvgDataX,~,DayNames] = DayAverage(LMP_counts_Vector(:,startind:end), LMP_counts_Vector(:,startind:end), MissingFilesList(startind:end,1), MissingFilesDateList(startind:end,2));
    [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
        CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))
    title('LMP MD Feature SI')
    
    if exist('MuFeats','var')
        Mucounts_Vector = MuFeatsMDs;
        [DayAvgDataX,~,DayNames] = DayAverage(Mucounts_Vector(:,startind:end), Mucounts_Vector(:,startind:end), MissingFilesList(startind:end,1), MissingFilesDateList(startind:end,2));
        [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
            CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))
        title('Mu MD Feature SI')
    end
    
    if exist('Gam1Feats','var')
        Gam1counts_Vector = Gam1FeatsMDs;
        [DayAvgDataX,~,DayNames] = DayAverage(Gam1counts_Vector(:,startind:end), Gam1counts_Vector(:,startind:end), MissingFilesList(startind:end,1), MissingFilesDateList(startind:end,2));
        [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
            CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))
        title('Gam1 MD Feature SI')
    end
    
    Gam2counts_Vector = Gam2FeatsMDs;
    [DayAvgDataX,~,DayNames] = DayAverage(Gam2counts_Vector(:,startind:end), Gam2counts_Vector(:,startind:end), MissingFilesList(startind:end,1), MissingFilesDateList(startind:end,2));
    [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
        CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))
    title('Gam2 MD Feature SI')
    
    Gam3counts_Vector = Gam3FeatsMDs;
    [DayAvgDataX,~,DayNames] = DayAverage(Gam3counts_Vector(:,startind:end), Gam3counts_Vector(:,startind:end), MissingFilesList(startind:end,1), MissingFilesDateList(startind:end,2));
    [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
        CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))
    title('Gam3 MD Feature SI')

elseif NeuronSubset == 1 
    OnlineFeats_CI_Avg = mean(OnlineFeats_CI_Range,2);
    Online_feats_8bin = reshape(mean(reshape(OnlineFeats,2,9,58,63),1),9,58,63)
    threshold = 30:10:90
    for ti = 1:length(threshold)
        OnlineFeats_WellMod = OnlineFeats(:,OnlineFeats_CI_Avg <= threshold(ti),:)
    
        All_Freq_counts_Vector = reshape(OnlineFeats_WellMod,size(OnlineFeats_WellMod,1)*size(OnlineFeats_WellMod,2),size(OnlineFeats_WellMod,3));

        [DayAvgDataX,~,DayNames] = DayAverage(All_Freq_counts_Vector(:,startind:end), All_Freq_counts_Vector(:,startind:end), MissingFilesList(startind:end,1), MissingFilesDateList(startind:end,2));

        [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
            CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))
        
        title(['Mean Corr Coeff of PD Map (n =',num2str(size(OnlineFeats_WellMod,2)),')'])
    end
    
     for i = 1:numSim
         randvect = randi(size(OnlineFeats,2),51,1);
         All_Freq_counts_Vector = reshape(OnlineFeats(:,randvect,:),size(OnlineFeats(:,randvect,:),1)*size(OnlineFeats(:,randvect,:),2),size(OnlineFeats(:,randvect,:),3));
         
         [DayAvgDataX,~,DayNames] = DayAverage(All_Freq_counts_Vector(:,startind:end), All_Freq_counts_Vector(:,startind:end), MissingFilesList(startind:end,1), MissingFilesDateList(startind:end,2));
         
         [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
             CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))
         
         r_mean_rand(i,:) = nanmean(rOnline.map);
         % Now looks at stability of modulation depths
         All_Freq_MDs_Vector = OnlineFeatsMDs;
         
         [DayAvgDataX,~,DayNames] = DayAverage(All_Freq_MDs_Vector(:,startind:end), All_Freq_MDs_Vector(:,startind:end), MissingFilesList(startind:end,1), MissingFilesDateList(startind:end,2));
         
         [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
             CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))
         close all
     end
     
elseif PDByBand == 0
    if strcmpi(Controltype,'Spike')
         All_Freq_counts_Vector = reshape(OnlineFeats,size(OnlineFeats,1)*size(OnlineFeats,2),size(OnlineFeats,3));
         [DayAvgDataX,~,DayNames] = DayAverage(All_Freq_counts_Vector(:,startind:end), All_Freq_counts_Vector(:,startind:end), MissingFilesList(startind:end,1), MissingFilesDateList(startind:end,2));
 
         figure
         imagesc(DayAvgDataX)
         ylabel('Unit')
         xlabel('Day')
         caxis([0 20])
    else
        All_Freq_counts_Vector = reshape(OnlineFeats_byFeat(:,:,[117:267 288:end]),size(OnlineFeats_byFeat,1)*size(OnlineFeats_byFeat,2),size(OnlineFeats_byFeat(:,:,[117:267 288:end]),3));
         [DayAvgDataX,~,DayNames] = DayAverage(All_Freq_counts_Vector(:,startind:end), All_Freq_counts_Vector(:,startind:end), MissingFilesList([117:267 288:end],1), MissingFilesDateList([117:267 288:end],2));
    
         figure
         imagesc(DayAvgDataX)
         ah = findobj(gca,'TickDirMode','auto')
         set(ah,'Box','off')
         set(ah,'TickLength',[0,0])
         ylabel('Feature')
         xlabel('Day')
         caxis([-100 100])
         [uBands,uBandYticks,~]=unique(bestf_Final);
         uBandYticks(1:end)= uBandYticks(1:end)*12 - 12 +1;
         allBands={'LMP','0-4','7-20','70-110','130-200','200-300'};         
         set(gca,'YTick',uBandYticks,'YTickLabel',allBands(uBands))
    end
   
    
    [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
        CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))
    ah = findobj(gca,'TickDirMode','auto')
    set(ah,'Box','off')
    set(ah,'TickLength',[0,0])
    return
end

plot(mean(r_mean_rand))

if strcmpi(Controltype,'lfp1') || strcmpi(Controltype,'lfp2')  
%     All_Offline_Freq_counts_Vector = reshape(OfflineFeats,size(OfflineFeats,1)*size(OfflineFeats,2),size(filelist,1));
%     [DayAvgDataOfflineX,~,DayNames] = DayAverage(All_Offline_Freq_counts_Vector, All_Offline_Freq_counts_Vector, filelist(:,1), MissingFilesDateList(:,2));
%     
%     [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
%         CorrCoeffMap(DayAvgDataOfflineX,1,DayNames(:,2))
    
    % Now look at stability of modulation depths on indirect channels
    All_Freq_MDs_Vector = OnlineFeatsMDs;
%     All_Freq_MDs_Vector = All_Spike_MDs;
    
    [DayAvgDataX,~,DayNames] = DayAverage(All_Freq_MDs_Vector(:,startind:end), All_Freq_MDs_Vector(:,startind:end), MissingFilesList(startind:end,1), MissingFilesDateList(startind:end,2));
    
    [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
        CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))
    title('All Feat MD SI')
end