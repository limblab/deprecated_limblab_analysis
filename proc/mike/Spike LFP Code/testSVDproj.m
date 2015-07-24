%[R2_para R2_perp] = testSVDproj(H,neuronIDs,shuntedch,r2,r2chan_index)
%Test n_parallel and n_perpendicular with Single Weiner Decoder

binsize  = .05;
numlags  = 10; % Number of lags used online
Offlinelags = 1; % Number of lags to use offline
numsides = 1;
lambda   = 1;
binsamprate = floor(1/binsize);
fInd = 1;
numfp = 96; 
folds = 10;
wsz = 256;

spikes = 0;
lfps =1;
TestfullH = 0;
TestRandH = 1;
LoadFeatMat = 0;

% FileList = Chewie_LFP1_tsNum;
% DateFormNames = Chewie_LFP1_tsNum;
% featind = LFP1_featindBEST_Chewie;
% shuntedCh = Chewie_shuntedCh;
% DecoderStartDate = '09-01-2011';

%% take out weights and channel indices for zeroed and shunted channels
% if lfps == 1 && length(H) == length(original_H)
%     
%     [bestc bestf] = CalcCh_Feat_fromFeatInd(featind);
%     [C,sortInd]=sortrows([bestc' bestf']);
%     bestc = C(:,1);
%     bestf = C(:,2);
%     if LoadFeatMat == 1
%         [featindSorted,sortInd]=sortrows(featind');
%     end
%     if exist('badChannels','var')
%         AllChtoRemov = unique([badChannels; shuntedCh]);
%     else
%         AllChtoRemov = shuntedCh;
%     end
%     Bia = ismember(bestc, AllChtoRemov);
%     bestc = bestc(~Bia);
%     bestf = bestf(~Bia);
%     BadCind = find(Bia == 1);
%     bi = length(BadCind);
%     for i = 1:length(BadCind)
%         H(((BadCind(bi)-1)*10)+1:BadCind(bi)*10,:) = [];
%         bi = bi -1;
%     end
%     
% end
% 
% Rand_I = randi([3 length(bestc)],120,2);
% Rand_I = unique(Rand_I,'rows','stable');
% Rand_I = Rand_I(Rand_I(:,1) ~= Rand_I(:,2),:);
% Rand_I = Rand_I(1:102,:);
% 
% DecoderSVD

for q = 1:length(FileList)
    %% Load file
    if LoadFeatMat == 0
        if exist('fnam','var') == 0
            fnam{q} =  findBDFonCitadel(FileList{q,1});
        elseif length(fnam) >= q
            if isempty(fnam{q}) == 1
                fnam{q} = findBDFonCitadel(FileList{q,1});
            end
        else
            fnam{q} =  findBDFonCitadel(FileList{q,1});
        end
    else
        if q < 10
            fnam{q} = ['file','0',num2str(q)]
        else
            fnam{q} = ['file',num2str(q)]
        end
    end
    
    try
        load(fnam{q})
    catch exception
        FilesNotRun{q,2} = exception;
        FilesNotRun{q,1} = fnam
        clear exception
        continue
    end
    
    %% Calculate power bands if using LFPs
    if lfps == 1
        if LoadFeatMat == 0
            [sig, samplerate, ~, ~,~,~,~,~,~, analog_time_base] = SetPredictionsInputVar(out_struct);
            fpAssignScript2
            bdf = out_struct;
            clear out_struct fpchans
            words = bdf.words;
            
            [PB, ~, ~, ~, y{q}, t] = MRScalcFeatMat(sig, 'vel', numfp, ...
                binsize, folds, numlags,numsides,samplerate, fp,fptimes, ...
                analog_time_base,fnam,256,[],[],[],[],words);
            
            for i=1:length(bestc)
                bestPB(i,:)=PB(bestf(i),bestc(i),:);
            end
            x=bestPB';
            clear bestPB sig analog_time_base
        else
            for i=1:length(bestc)
                if q < 10
                    x(:,i)=eval(['featMat','0',num2str(q),'(:,featindSorted(i,:))']);
                    y{q} = eval(['binnedSig','0',num2str(q)]);
                else
                    x(:,i)=eval(['featMat',num2str(q),'(:,featindSorted(i,:))']);
                    y{q} = eval(['binnedSig',num2str(q)]);                  
                end
            end
            clear featMat* binnedSig*
        end
    end
    %% Bin spikes if using spikes
    if spikes == 1
        bdf = out_struct;
        clear out_struct
        t = bdf.vel(1,1):binsize:bdf.vel(end,1);
        y{q} = bdf.vel(:,2:3);
        y{q} = [interp1(bdf.vel(:,1), y{q}(:,1), t); interp1(bdf.vel(:,1), y{q}(:,2), t)]';
        
        cells{q} = unit_list(bdf);
        x = zeros(length(y{q}), length(V{1}));
        for i = 1:length(cells)
            if cells(i,1) ~= 0
                for j = 1:length(neuronIDs)
                    if cells(i,1) == neuronIDs(j,1)
                        ts = get_unit(bdf, cells(i, 1), cells(i, 2));
                        b = train2bins(ts, t);
                        x(:,j) = b;
                        break
                    end
                end
            end
        end
    
    [rOnlinemap{q},~, ~, ~, ~, ~] = ...
        CorrCoeffMap(AllGam3,1,1:96)
    continue    
        clear b cells i ts t
    end
    
    %% Now build and test decoders
    if TestfullH == 0
        if TestRandH == 0
            try
                [y{q},x,ytnew] = predMIMO3(x,H,numsides,1,y{q});
                % Apply non-linearity
%                 for z=1:size(y{q},2)
%                     y{q}(:,z) = P(1,z)*y{q}(:,z).^3 + P(2,z)*y{q}(:,z).^2 +...
%                         P(3,z)*y{q}(:,z);
%                     y{q}(:,z) = y{q}(:,z) - mean(y{q}(:,z));
%                     %                 ytnew{q}(:,z) = ytnew{q}(:,z)- mean(ytnew{q}(:,z));
%                 end
                [n_para{q}, n_perp{q}, H_para_AllLag{q}, H_perp_AllLag{q},...
                    H_para_Allalpha{q}, H_perp_Allalpha{q}] = ...
                    buildSVDprojdecoders(x, V, y{q}, Offlinelags, numsides,...
                    lambda, binsamprate);
            catch exception
                ErrorCatch{q} = exception
                clear exception
                continue
            end
            clear y_* xt* yt* r_* r
            
            if q == length(FileList)
                for fi = length(FileList)-5:length(FileList); % Index for test file
                    
                    for ti = 1:length(H_para_AllLag) % Index for decoder
                        
                        if isempty(H_para_AllLag{ti}) == 1
                            continue
                        else
                            if lfps == 1
                                % Still need to fix lfp decoding
                                [y_pred_para1,xtnew,ytnew_para] = predMIMO3(n_para{fi}(:,:,1),H_para_AllLag{ti}(:,:,1),numsides,1,y{fi});
                                [y_pred_para2,xtnew,ytnew_para] = predMIMO3(n_para{fi}(:,:,2),H_para_AllLag{ti}(:,:,2),numsides,1,y{fi});
                                [y_pred_para3,xtnew,ytnew_para] = predMIMO3(n_para{fi}(:,:,1)+n_para{fi}(:,:,2),H_para_AllLag{ti}(:,:,3),numsides,1,y{fi});
                                [y_pred_para4,xtnew,ytnew_para] = predMIMO3(n_para{fi}(:,:,1)-n_para{fi}(:,:,2),H_para_AllLag{ti}(:,:,4),numsides,1,y{fi});
                                
                                for ai = 1:size(H_perp_AllLag{ti},3)
                                    [y_pred_perp{ai},xtnew,ytnew_perp] = predMIMO3(n_perp{fi}(:,:,ai),H_perp_AllLag{ti}(:,:,ai),numsides,binsamprate,y{fi});
                                end
                                
                                n_para_all = reshape(n_para{fi}(:,:,1:2),size(n_para{fi},1),size(n_perp{fi},2)*2);
                                n_perp_all = reshape(n_perp{fi},size(n_perp{fi},1),size(n_perp{fi},2)*size(n_perp{fi},3));
                                [y_pred_para_all,xtnew,ytnew_para] = predMIMO3(n_para_all,H_para_Allalpha{ti},numsides,binsamprate,y{fi});
                                [y_pred_perp_all,xtnew,ytnew_perp] = predMIMO3(n_perp_all,H_perp_Allalpha{ti},numsides,binsamprate,y{fi});
                                
                                %                             for z=1:size(y_pred_para_all,2)
                                %                                 y_pred_para_all(:,z) = P(1,z)*y_pred_para_all(:,z).^3 + P(2,z)*y_pred_para_all(:,z).^2 +...
                                %                                     P(3,z)*y_pred_para_all(:,z);
                                %                                 y_pred_para_all(:,z) = y_pred_para_all(:,z) - mean(y_pred_para_all(:,z));
                                %                                 y_pred_perp_all(:,z) = P(1,z)*y_pred_perp_all(:,z).^3 + P(2,z)*y_pred_perp_all(:,z).^2 +...
                                %                                     P(3,z)*y_pred_perp_all(:,z);
                                %                                 y_pred_perp_all(:,z) = y_pred_perp_all(:,z) - mean(y_pred_perp_all(:,z));
                                %
                                %                                 %                 ytnew{q}(:,z) = ytnew{q}(:,z)- mean(ytnew{q}(:,z));
                                %                             end
                            else
                                % Testing alpha1 (denoted as 1), alpha 2 (2), alpha1 +
                                % alpha2 (3) and alpha1 - alpha2 (4) to see
                                % their various decoding performances
                                [y_pred_para1,xtnew,ytnew_para] = predMIMO3(n_para{fi}(:,:,1),H_para_AllLag{ti}(:,:,1),numsides,binsamprate,y{fi});
                                [y_pred_para2,xtnew,ytnew_para] = predMIMO3(n_para{fi}(:,:,2),H_para_AllLag{ti}(:,:,2),numsides,binsamprate,y{fi});
                                [y_pred_para3,xtnew,ytnew_para] = predMIMO3(n_para{fi}(:,:,1)+n_para{fi}(:,:,2),H_para_AllLag{ti}(:,:,3),binsamprate,1,y{fi});
                                [y_pred_para4,xtnew,ytnew_para] = predMIMO3(n_para{fi}(:,:,1)-n_para{fi}(:,:,2),H_para_AllLag{ti}(:,:,4),binsamprate,1,y{fi});
                                
                                % MRS 2/16/2015 added this to test each alpha
                                % individually
                                for ai = 1:size(H_perp_AllLag{ti},3)
                                    [y_pred_perp{ai},xtnew,ytnew_perp] = predMIMO3(n_perp{fi}(:,:,ai),H_perp_AllLag{ti}(:,:,ai),numsides,binsamprate,y{fi});
                                end
                                
                                % MRS 2/17/2015 testing alpha 1 and alpha 2 (n_parallel) as
                                % 2 feature decoder and n_perp (alpha3:end) as
                                % multiple neuron decoder.
                                n_para_all = reshape(n_para{fi}(:,:,1:2),size(n_para{fi},1),size(n_perp{fi},2)*2);
                                n_perp_all = reshape(n_perp{fi},size(n_perp{fi},1),size(n_perp{fi},2)*size(n_perp{fi},3));
                                [y_pred_para_all,xtnew,ytnew_para] = predMIMO3(n_para_all,H_para_Allalpha{ti},numsides,binsamprate,y{fi});
                                [y_pred_perp_all,xtnew,ytnew_perp] = predMIMO3(n_perp_all,H_perp_Allalpha{ti},numsides,binsamprate,y{fi});
                                
                            end
                            
                            for j = 1:size(y{fi},2)
                                r_para1{fInd,ti,j}=corrcoef(y_pred_para1(:,j),ytnew_para(:,j));
                                r_para2{fInd,ti,j}=corrcoef(y_pred_para2(:,j),ytnew_para(:,j));
                                r_para3{fInd,ti,j}=corrcoef(y_pred_para3(:,j),ytnew_para(:,j));
                                r_para4{fInd,ti,j}=corrcoef(y_pred_para4(:,j),ytnew_para(:,j));
                                
                                % MRS 2/16/2015 added this to test each alpha
                                % individually
                                for tai = 1:length(y_pred_perp)
                                    r_perp{tai}{fInd,ti,j}=corrcoef(y_pred_perp{tai}(:,j),ytnew_perp(:,j));
                                    R2_para_perp_AllLag{j}(tai+2,ti,fInd)=r_perp{tai}{fInd,ti,j}(1,2)^2;
                                end
                                r_para_all{fInd,ti,j}=corrcoef(y_pred_para_all(:,j),ytnew_para(:,j));
                                r_perp_all{fInd,ti,j}=corrcoef(y_pred_perp_all(:,j),ytnew_perp(:,j));
                                
                                R2_para_AllLag1(fInd,ti,j)=r_para1{fInd,ti,j}(1,2)^2;
                                R2_para_perp_AllLag{j}(1,ti,fInd) = r_para1{fInd,ti,j}(1,2)^2;
                                R2_para_AllLag2(fInd,ti,j)=r_para2{fInd,ti,j}(1,2)^2;
                                R2_para_perp_AllLag{j}(2,ti,fInd) = r_para2{fInd,ti,j}(1,2)^2;
                                R2_para_AllLag3(fInd,ti,j)=r_para3{fInd,ti,j}(1,2)^2;
                                R2_para_AllLag4(fInd,ti,j)=r_para4{fInd,ti,j}(1,2)^2;
                                
                                % MRS 2/17/2015 testing alpha 1 and alpha 2 (n_parallel) as
                                % 2 feature decoder and n_perp (alpha3:end) as
                                % multiple neuron decoder.
                                R2_para_All(fInd,ti,j)=r_para_all{fInd,ti,j}(1,2)^2;
                                R2_perp_All(fInd,ti,j) = r_perp_all{fInd,ti,j}(1,2)^2;
                            end
                            
                            clear alpha* r_* y_* xt* yt*
                        end
                        %         vaf(vi,:)=RcoeffDet(y_pred{vi},ytnew{vi});
                    end
                    fInd = fInd + 1;
                end
            end
            
        elseif TestRandH == 1
                [n_para{q}, n_perp{q}, H_para_AllLag{q}, H_perp_AllLag{q}, H_para_Allalpha{q}, ...
                    H_perp_Allalpha{q}, H_2_rand{q}] = ...
                    buildSVDprojdecoders(x, V, y{q}, Offlinelags, numsides,...
                    lambda, binsamprate, TestRandH, Rand_I);
            
                if q == length(FileList)
                    for fi = length(FileList)-5:length(FileList)
                        for ti = 1:length(H_2_rand)
                            n_all = zeros(size(n_para{fi},1),10,size(x,2));
                            n_all(:,:,1:2) = n_para{fi};
                            n_all(:,:,3:size(n_perp{fi},3)+2) = n_perp{fi};
                            
                            for ai = 1:size(H_2_rand{ti},3)
                                n_2_rand = reshape(n_all(:,:,[Rand_I(ai,1) Rand_I(ai,2)]),size(n_all,1),size(n_all,2)*2);
                                ind = 1:size(x,2);
                                bia = ismember(ind,Rand_I(ai,:));
                                ind = ind(~bia);
                                n_minus_2_rand = reshape(n_all(:,:,ind),size(n_all,1),size(n_all,2)*size(n_all,3)-20);
                                [y_2_rand{ai},xtnew,ytnew_perp] = predMIMO3(n_2_rand,H_2_rand{ti}(:,:,ai),numsides,binsamprate,y{fi});
%                                 [y_n_minus2{ai},xtnew,ytnew_perp] = predMIMO3(n_minus_2_rand,H_n_minus2_rand{ti}(:,:,ai),numsides,binsamprate,y{fi});
                            end
                            
                            for j = 1:size(y{fi},2)
                                
                                for tai = 1:length(y_2_rand)
                                    r_2rand{tai}{fInd,ti,j}=corrcoef(y_2_rand{tai}(:,j),ytnew_perp(:,j));
%                                     r_n_minus2_rand{tai}{fInd,ti,j}=corrcoef(y_n_minus2{tai}(:,j),ytnew_perp(:,j));
                                    R2_2rand{j}(tai,ti,fInd)=r_2rand{tai}{fInd,ti,j}(1,2)^2;
%                                     R2_n_minus2_rand{j}(tai,ti,fInd)=r_n_minus2_rand{tai}{fInd,ti,j}(1,2)^2;
                                end
                            end
                            clear y_*
                        end
                        fInd = fInd + 1;
                    end
                end
        end
    elseif TestfullH == 1
        [H_full{q},v,mcc] = FILMIMO3_tik(x, y, numlags, numsides,lambda,binsamprate);
        
        if q >= length(FileList)-5
            for fdi = 1:length(H_full)
                
                [bestc bestf] = CalcCh_Feat_fromFeatInd(featind);
                % Build H sorted by channels to match how brain reader
                % accepts H
                [C,sortInd]=sortrows([bestc' bestf']);
                bestc = C(:,1);
                bestf = C(:,2);
                % the default operation of sortrows is to sort first on column 1, then do a
                % secondary sort on column 2, which is exactly what we want, so we're done.
                x=x(:,sortInd);
                
                [y_pred,xtnew,ytnew] = predMIMO3(x,H,numsides,10,y);
                for j = 1:size(y,2)
                    r_full{j}=corrcoef(y_pred(1:end-4,j),ytnew(5:end,j));
                end
                R2_fullX(i,fdi,fInd)=r_full{1}(1,2)^2
                R2_fullY(i,fdi,fInd)=r_full{2}(1,2)^2
                
                clear y_pred xtnew ytnew r_full
            end
            fInd = fInd + 1;
        end
    end
    
    clear x t ti i j bdf
end

clear q fInd spikes lfps


