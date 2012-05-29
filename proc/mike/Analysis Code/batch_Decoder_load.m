direct = 'C:\Documents and Settings\Administrator\Desktop\Mike_Data\Spike LFP Decoding\Chewie';
%Set directory to desired directory

cd(direct);

Days=dir(direct);
%Days(1:2)=[];
%DaysNames={Days.name}; <- Use if folder structure has files separated by
%day
FileNames = {Days.name};
nlags =20;
nfolds = 5;
nfbands = 6;
nchan = 96;
nfeats = 150;

for i = 1:length(FileNames)-2
    %DayName = [direct,'\',DaysNames{i},'\'];
    %cd(DayName);
    
    %Get mat file names and create decoder
    %Files=dir(DayName);
    %FileNames={Files.name};
    MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,'_Spike_LFP.*(?<=poly).*\.mat'))==0); % (?<=decoder) <-Use if loading online decoders
    
    if isempty(MATfiles)
        fprintf(1,'no MAT files found.  Make sure this day has an LFP decoder\n.')
        continue
    end
    
    
    fnam = MATfiles{i}
    fname=[direct,'\',fnam]; %<-- DaysNames{i},'\',fnam];  Use if folder structure separates files by day
    load(fnam);
    
    Features(i,:) = featind(:,1:150);
    
    H_avg = mean(reshape(cat(1,H{:}),nlags*nfeats,nfolds,2),2);
    clear H
    H{1} = reshape(H_avg,nlags*nfeats,2);
    DecoderAge
    
    if size(bestc,2) > size(bestc,1)
        bestc = bestc';
        bestf = bestf';
    end
    
    [Wf{i},Wft{i},Wc{i},Wt{i}]= MRScalcwtsum(H,nlags,nfbands,nchan,bestf,bestc);
    
    featuresIndex = (bestc-1)*6+bestf;
    for k = 1:length(featuresIndex)
        Temp_index = (featuresIndex(k)-1)*nlags+1;
        for j = 1:nlags
            DecoderFeatureIndex((k-1)*nlags+j) = Temp_index;
            Temp_index = Temp_index + 1;
        end
    end
    H = [H DecoderFeatureIndex'];
    if iscell(H)
        H = cat(2,H{:});
    end
    %% Average across time lags
    H1r=reshape(H,nlags,[],3);
    H_avg_TimeLag = [reshape(mean(H1r(1:end,:,1:2)),size(H1r,2),2) featuresIndex];
    H_max_TimeLag = [reshape(max(H1r(:,:,1:2),[],1),size(H1r,2),2) featuresIndex];
    H_max_TimeLag = sortrows(H_max_TimeLag,3);
    
    for q = 1:10
        H_TimeLag = [reshape(H1r(q,:,1:2),size(H1r,2),2) featuresIndex];
        H_TimeLag = sortrows(H_TimeLag,3);
        Decoders{i,1,q+4} = H_TimeLag(:,1);
        Decoders{i,2,q+4} = H_TimeLag(:,2);
        
    end
    
    %% Index decoder by feature 
    H_IndexedByFeature = zeros(nchan*nfbands*nlags,3);
    H_IndexedByFeature(DecoderFeatureIndex',:) = H;
    
    %% Sort decoder by feature
    H_SortedByFeature = sortrows(H,3);
    H_avg_SortedByFeature = sortrows(H_avg_TimeLag,3);
    features{i} = featuresIndex;
    
    %% Output
    Decoders{i,1,1} = H_IndexedByFeature(:,1);
    Decoders{i,2,1} = H_IndexedByFeature(:,2);
    Decoders{i,1,2} = H_SortedByFeature(:,1);
    Decoders{i,2,2} = H_SortedByFeature(:,2);
    Decoders{i,3,2} = H_SortedByFeature(:,3);
    Decoders{i,1,3} = H_avg_SortedByFeature(:,1);
    Decoders{i,2,3} = H_avg_SortedByFeature(:,2);
    Decoders{i,1,4} = H_max_TimeLag(:,1);
    Decoders{i,2,4} = H_max_TimeLag(:,2);
    Decoders{i,3,4} = DecoderAge;    
    
    if i >= 2 
        if Decoders{i,3,4} == Decoders{i-1,3,4}
            tmpIndex = tmpIndex+1;
            Decoders{i,4,4} = tmpIndex;
            H_sum = reshape(sum(abs(H1r(1:end,:,1:2))),size(H1r,2),2);
            Hmean(:,1) = H_sum(:,1)/sum(H_sum(:,1),1);
            Hmean(:,2) = H_sum(:,2)/sum(H_sum(:,2),1);
            Htemp = reshape(Decoders{DayIndex,1,15},nfeats,1,2)+ reshape(Hmean,nfeats,1,2);
            Decoders{DayIndex,1,15} = reshape(Htemp,nfeats,2);
        else
            Decoders{DayIndex,1,15} = Decoders{DayIndex,1,15}/tmpIndex;
            tmpIndex = 1;
            DayIndex = DayIndex + 1;
            H_sum = reshape(sum(abs(H1r(1:end,:,1:2))),size(H1r,2),2);
            Hmean(:,1) = H_sum(:,1)/sum(H_sum(:,1),1);
            Hmean(:,2) = H_sum(:,2)/sum(H_sum(:,2),1);
            Decoders{DayIndex,1,15} = Hmean;
            Decoders{DayIndex,2,15} = DecoderAge;
            Decoders{DayIndex,3,15} = H(:,3);
            Decoders{i,4,4} = tmpIndex;
        end
    else
        DayIndex = 1;
        H_sum = reshape(sum(abs(H1r(1:end,:,1:2))),size(H1r,2),2);
        Hmean(:,1) = H_sum(:,1)/sum(H_sum(:,1),1);
        Hmean(:,2) = H_sum(:,2)/sum(H_sum(:,2),1);
        Decoders{DayIndex,1,15} = Hmean;
        Decoders{DayIndex,2,15} = DecoderAge;
        Decoders{DayIndex,3,15} = H(:,3);
        Decoders{i,4,4} = 1;
        tmpIndex = 1;
    end
    
end

% Wt_norm = [reshape(cat(1,Decoders{:,1,15}),nfeats,[],2); repmat(cat(2,Decoders{:,2,15}),[1 1 2])];
% imagesc(Wt_norm(1:99,:,1));figure(gcf);
% W_timeLag_byFreq_avg = reshape(mean(reshape(cat(1,Wft{:}),6,length(Wft),40),2),6,20,2);


for r = [4 14 ]
    DecWts_X(:,:,r) = [cat(2,Decoders{:,1,r}); cat(1,Decoders{:,3,4})'; (cat(1,Decoders{:,3,4})+cat(1,Decoders{:,4,4}))']';
    DecWts_Y(:,:,r) = [cat(2,Decoders{:,2,r}); cat(1,Decoders{:,3,4})'; (cat(1,Decoders{:,3,4})+cat(1,Decoders{:,4,4}))']';

    DecWts_X(:,:,r) = sortrows(DecWts_X(:,:,r),101);
    DecWts_Y(:,:,r) = sortrows(DecWts_Y(:,:,r),101);

%     DecWts_X(:,:,r) = DecWts_X(:,:,r)';
%     DecWts_Y(:,:,r) = DecWts_Y(:,:,r)';
    figure;
     DecWts_Plot = DecWts_X(:,:,r)';
%     DecWts_Plot(:,9) = [];
%     DecWts_Plot(:,17) = [];
%     DecWts_Plot(:,10) = [];
    imagesc(DecWts_Plot(1:99,:));figure(gcf);
end


% Wt_cat = reshape(cat(1,Wt{:}),20,[],2)
% Wt_cat_avg = mean(Wt_cat,2)

% for i = 1:size(DecWts_X,2)
% DayLabel{i} = int2str(DecWts_X(i,100,14));
% end
% set(gca,'XTick',[1:12],'XTickLabel',DayLabel)


