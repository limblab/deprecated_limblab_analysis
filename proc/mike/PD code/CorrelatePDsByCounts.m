%% Input
% Filelist
% featindBEST_  - Feature Index (if LFPs)
% shuntedCh 

% CorrelatePDsByCounts
filelist= Chewie_MSP_tsNum;
datenames = Chewie_MSP_tsNum;
Controltype = 'Spike';
Signaltype = 'AllLFP';
% LFP1, LFP2 or Spike
startind = 1;
MissingFilesList = filelist;
MissingFilesListInd = [];

if strcmpi(filelist{1}(1:4),'Mini') 
    if strcmpi(Controltype,'lfp1')
        [datelist, DateNames] = CalcDecoderAge(datenames, '08-24-2011');
        DecoderStartDate = '08-24-2011'; 
    elseif strcmpi(Controltype,'lfp2')
        [datelist, DateNames] = CalcDecoderAge(datenames, '04-13-2012');
        DecoderStartDate = '04-13-2012'; 
    elseif strcmpi(Controltype,'spike')
        [datelist, DateNames] = CalcDecoderAge(datenames, '01-25-2012');
        DecoderStartDate = '01-25-2012'; 
    end
    
    shuntedCh = Mini_shuntedCh;
    if strcmpi(Controltype,'lfp1') || strcmpi(Signaltype,'lfp1') || strcmpi(Controltype,'lfp2') || strcmpi(Signaltype,'lfp2')
        if exist('bestf_Mini','var') == 0 && ( strcmpi(Controltype,'lfp1') || strcmpi(Signaltype,'lfp1') )
            [bestc_Mini bestf_Mini] = CalcCh_Feat_fromFeatInd(LFP1_featindBEST_Mini);
            featindBEST = LFP1_featindBEST_Mini;
        elseif exist('bestf_Mini','var') == 0 && ( strcmpi(Controltype,'lfp2') || strcmpi(Signaltype,'lfp2') )
            [bestc_Mini bestf_Mini] = CalcCh_Feat_fromFeatInd(LFP2_featIndBEST_Mini);
            featindBEST = LFP2_featIndBEST_Mini;
        elseif exist('bestf_Mini','var') == 0 && ( strcmpi(Controltype,'AllLFP') || strcmpi(Signaltype,'AllLFP') )
            bestc_Mini = reshape(repmat(1:96,6,1) ,576,1);
            bestf_Mini = reshape(repmat(1:6,1,96) ,576,1);
            featindBEST = 1:576;
        end
        bestf_bychan = sortrows([bestf_Mini' bestc_Mini'],2);
        bestc_bychan = bestf_bychan(:,2);
        bestf_bychan(:,2) = [];
    end
      
elseif strcmpi(filelist{1}(1:4),'Chew')
    if strcmpi(Controltype,'lfp1')
        [datelist, DateNames] = CalcDecoderAge(filelist, '09-01-2011');
        DecoderStartDate = '09-01-2011'; 
    elseif strcmpi(Controltype,'lfp2')
        [datelist, DateNames] = CalcDecoderAge(filelist, '04-13-2011');
        DecoderStartDate = '04-13-2012'; 
    elseif strcmpi(Controltype,'spike')
        [datelist, DateNames] = CalcDecoderAge(datenames, '01-25-2012');
        DecoderStartDate = '01-25-2012';
    end
    
    shuntedCh = Chewie_shuntedCh;
    if strcmpi(Controltype,'lfp1') || strcmpi(Signaltype,'lfp1') || strcmpi(Controltype,'lfp2') || strcmpi(Signaltype,'lfp2') || strcmpi(Signaltype,'AllLFP')
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
        else 
        load([fnam(1:end-4),'_pdsallchanspos_bs-1wsz150mnpow_AllFreq_LFPcounts'],...
            'LFPcounts','LMPcounts')
        end
    catch
        MissingFiles{i} = fnam
        MissingFilesListInd = [MissingFilesListInd i];
        
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
    LFPcounts spike_counts

MissingFilesList(MissingFilesListInd,:) = [];
MissingFilesDateList(MissingFilesListInd,:) = [];
%% Take out shunts and average counts
if exist('All_LMP_counts','var')
    Lia = ismember(bestc_bychan,shuntedCh);
    bestc_NoShunt = bestc_bychan(~Lia)
    bestf_NoShunt = bestf_bychan(~Lia);
    h = 1;
    mu = 1;
    g1 = 1;
    g2 = 1;
    g3 = 1;    
    if strcmpi(Signaltype,'AllLFP') 
        for g = 1:length(bestc_NoShunt)
            if bestf_NoShunt(g) == 1
                LMPFeats(:,h,:) = All_LMP_counts(:,bestc_NoShunt(g),:);
                h=h+1;
            elseif bestf_NoShunt(g) == 2
                continue
            elseif bestf_NoShunt(g) == 3
                MuFeats(:,mu,:) = squeeze(All_Non_LMP_counts(:,bestc_NoShunt(g),bestf_NoShunt(g)-1,:));
                mu = mu+1;
            elseif bestf_NoShunt(g) == 4
                Gam1Feats(:,g1,:) = squeeze(All_Non_LMP_counts(:,bestc_NoShunt(g),bestf_NoShunt(g)-1,:));
                g1 = g1+1;
            elseif bestf_NoShunt(g) == 5
                Gam2Feats(:,g2,:) = squeeze(All_Non_LMP_counts(:,bestc_NoShunt(g),bestf_NoShunt(g)-1,:));
                g2 = g2+1;
            elseif bestf_NoShunt(g) == 6
                Gam3Feats(:,g3,:) = squeeze(All_Non_LMP_counts(:,bestc_NoShunt(g),bestf_NoShunt(g)-1,:));
                g3 = g3+1;
            end
        end; clear g h
    else
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
    end
else
    chans = spikePDs{1,1}(:,1);
    Lia = ismember(chans,shuntedCh);
    chans_NoShunt = chans(~Lia)
    for g = 1:length(chans_NoShunt)
            OnlineFeats(:,g,:) = All_Spike_counts(:,chans_NoShunt(g),:);
    end; clear g
end

%% Now put counts into a vector, day average, and make correlation map

if strcmpi(Signaltype,'AllLFP') 
    LMP_counts_Vector = reshape(LMPFeats,size(LMPFeats,1)*size(LMPFeats,2),size(LMPFeats,3));
    [DayAvgDataX,~,DayNames] = DayAverage(LMP_counts_Vector(:,startind:end), LMP_counts_Vector(:,startind:end), MissingFilesList(startind:end,1), MissingFilesDateList(startind:end,2));
    [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
        CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))
    title('LMP Feature SI')
    
    Mucounts_Vector = reshape(MuFeats,size(MuFeats,1)*size(MuFeats,2),size(MuFeats,3));
    [DayAvgDataX,~,DayNames] = DayAverage(Mucounts_Vector(:,startind:end), Mucounts_Vector(:,startind:end), MissingFilesList(startind:end,1), MissingFilesDateList(startind:end,2));
    [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
        CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))
    title('Mu Feature SI')
    
    Gam1counts_Vector = reshape(Gam1Feats,size(Gam1Feats,1)*size(Gam1Feats,2),size(Gam1Feats,3));
    [DayAvgDataX,~,DayNames] = DayAverage(Gam1counts_Vector(:,startind:end), Gam1counts_Vector(:,startind:end), MissingFilesList(startind:end,1), MissingFilesDateList(startind:end,2));
    [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
        CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))
    title('Gam1 Feature SI')
    
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
else
    All_Freq_counts_Vector = reshape(OnlineFeats,size(OnlineFeats,1)*size(OnlineFeats,2),size(OnlineFeats,3));

    [DayAvgDataX,~,DayNames] = DayAverage(All_Freq_counts_Vector(:,startind:end), All_Freq_counts_Vector(:,startind:end), MissingFilesList(startind:end,1), MissingFilesDateList(startind:end,2));

    [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
        CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))
end
    
if strcmpi(Controltype,'lfp1') || strcmpi(Controltype,'lfp2')  
All_Offline_Freq_counts_Vector = reshape(OfflineFeats,size(OfflineFeats,1)*size(OfflineFeats,2),size(filelist,1));
[DayAvgDataOfflineX,~,DayNames] = DayAverage(All_Offline_Freq_counts_Vector, All_Offline_Freq_counts_Vector, filelist(:,1), MissingFilesDateList(:,2));

[rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
        CorrCoeffMap(DayAvgDataOfflineX,1,DayNames(:,2))
end