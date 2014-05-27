% CorrelatePDsByCounts
filelist= Chewie_LFP1filenames_MasterConservative;
if 1
    if strcmpi(filelist{1}(1:4),'Mini')
        
        if exist('bestf_bychan','var') == 0
            bestf_bychan = sortrows([bestf_Mini' bestc_Mini'],2);
            bestc_bychan = bestf_bychan(:,2);
            bestf_bychan(:,2) = [];
        end
        
        DecoderStartDate = '08-24-2011';
        
    elseif strcmpi(filelist{1}(1:4),'Chew')
        
        if exist('bestf_bychan','var') == 0
            bestf_bychan = sortrows([bestf_Chewie' bestc_Chewie'],2);
            bestc_bychan = bestf_bychan(:,2);
            bestf_bychan(:,2) = [];
        end
        
        DecoderStartDate = '09-01-2011';
    end
    
    for i=1:length(filelist)
        
        fnam = [filelist{i,1}]
        
        try
            load([fnam(1:end-4),'_pdsallchanspos_bs-1wsz150mnpow_AllFreq_LFPcounts'],...
                'LFPcounts')
        catch
            continue
        end
        
        for j = 1:size(LFPcounts,1)
            for k = 1:size(LFPcounts,2)
                
                All_Non_LMP_counts(:,j,k,i) = cellfun(@mean,LFPcounts{j,k});
                
                %        All_LMP_counts(:,j,i) = All_LMP_counts(:,j,i)./max(All_LMP_counts(:,j,i));
            end
        end
        
    end; clear i j fnam bestf_Chewie bestc_Chewie bestf_Mini bestc_Mini LMPcounts...
        LFPcounts
end
    
for g = 1:length(bestc_bychan)
    
    if bestf_bychan(g) == 1
        
        OnlineFeats(:,g,:) = All_LMP_counts(:,bestc_bychan(g),:);
        
    elseif bestf_bychan(g) == 2 
        continue
    else
        
        OnlineFeats(:,g,:) = squeeze(All_Non_LMP_counts(:,bestc_bychan(g),bestf_bychan(g)-1,:));
    end
end; clear g 


%%

% All_LMP_counts_Vector = reshape(All_LMP_counts,size(LMPcounts{1},2)*size(LMPcounts,2),size(filelist,1));
All_Freq_counts_Vector = reshape(OnlineFeats,size(OnlineFeats,1)*size(OnlineFeats,2),size(filelist,1));

[DayAvgDataX,~,DayNames] = DayAverage(All_Freq_counts_Vector, All_Freq_counts_Vector, Chewie_LFP1filenames_MasterConservative(:,1), Chewie_LFP1filenames_MasterConservative(:,2));

    [rOnline.map,rOnline.map_mean, rOnline.rho, rOnline.pval, rOnline.f, rOnline.x] = ...
        CorrCoeffMap(DayAvgDataX,1,DayNames(:,2))

