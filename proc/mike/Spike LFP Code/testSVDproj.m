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
   
spikes = 1;
lfps = 0;
TestfullH = 0;
FileList = Mini_MSP_DaysNames;
DecoderStartDate = '01-24-2012';
DecoderSVD
   
for q = 1:length(FileList);
    %% Load file
    if exist('fnam','var') == 0
        fnam{q} =  findBDFonCitadel(FileList{q,1});
    elseif length(fnam) >= q
        if isempty(fnam{q}) == 1
            fnam{q} = findBDFonCitadel(FileList{q,1});
        end
    else
        fnam{q} =  findBDFonCitadel(FileList{q,1});
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
        
        [sig, samplerate, ~, ~,~,~,~,~,~, analog_time_base] = SetPredictionsInputVar(out_struct);
        fpAssignScript2
        bdf = out_struct;
        clear out_struct fpchans
                
        [PB, ~, ~, ~, y, t] = MRScalcFeatMat(sig, 'vel', numfp, ...
            binsize, folds, numlags,numsides,samplerate, fp,fptimes, ...
            analog_time_base,fnam);
        
        for i=1:length(bestc)
            bestPB(i,:)=PB(bestf(i),bestc(i),:);
        end
        x=bestPB';
        clear bestPB sig analog_time_base
    end
    %% Bin spikes if using spikes
    if spikes == 1
        bdf = out_struct;
        clear out_struct
        t = bdf.vel(1,1):binsize:bdf.vel(end,1);
        y = bdf.vel(:,2:3);
        y = [interp1(bdf.vel(:,1), y(:,1), t); interp1(bdf.vel(:,1), y(:,2), t)]';
        
        cells = unit_list(bdf);
        x = zeros(length(y), length(V{1}));
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
        
        
        clear b cells i ts t
    end

    %% Now build decoders 
    
    try
        [y,x,ytnew] = predMIMO3(x,H,numsides,1,y);
        [n_para, n_perp, H_para_AllLag{q}, H_perp_AllLag{q}] = buildSVDprojdecoders(x, V, y, Offlinelags, numsides, lambda, binsamprate);
    catch exception
        ErrorCatch{q} = exception
        clear exception
        continue
    end
    clear y_* xt* yt* r_* r
    
    if q >= length(FileList)-10
        for ti = 1:length(H_para_AllLag)
            
            if isempty(H_para_AllLag{ti}) == 1
                continue
            else
                if lfps == 1
                    [y_pred_para,xtnew,ytnew_para] = predMIMO3(n_para,H_para_AllLag{ti},numsides,1,y);
                    [y_pred_perp,xtnew,ytnew_perp] = predMIMO3(n_perp,H_perp_AllLag{ti},numsides,1,y);
                else
                    [y_pred_para,xtnew,ytnew_para] = predMIMO3(n_para,H_para_AllLag{ti},numsides,binsamprate,y);
                    [y_pred_perp,xtnew,ytnew_perp] = predMIMO3(n_perp,H_perp_AllLag{ti},numsides,binsamprate,y);
                end
                
                for j = 1:size(y,2)
                    r_para{fInd,ti,j}=corrcoef(y_pred_para(:,j),ytnew_para(:,j));
                    r_perp{fInd,ti,j}=corrcoef(y_pred_perp(:,j),ytnew_perp(:,j));
                    
                    R2_para_AllLag(fInd,ti,j)=r_para{fInd,ti,j}(1,2)^2;
                    R2_perp_AllLag(fInd,ti,j)=r_perp{fInd,ti,j}(1,2)^2;
                end
                
                clear alpha* r_* y_* xt* yt*
            end
            %         vaf(vi,:)=RcoeffDet(y_pred{vi},ytnew{vi});
        end
        fInd = fInd + 1;
    end
    if TestfullH == 1
        [y_pred,xtnew,ytnew] = predMIMO3(x,H,numsides,1,y); 
         
         for j = 1:size(y,2)
             r_full{fInd,j}=corrcoef(y_pred(:,j),ytnew(:,j));
             R2_full(fInd,j)=r_full{fInd,j}(1,2)^2;
         end
    end
    
    clear x y t n_* ti i j bdf
end

clear q fInd spikes lfps

R2_para_AllLag_Mean = nanmean(nanmean(R2_para_AllLag(:,:,:),3));
R2_perp_AllLag_Mean = nanmean(nanmean(R2_perp_AllLag(:,:,:),3));
R2_para_AllLag_Mean_NoZ = R2_para_AllLag_Mean(R2_para_AllLag_Mean ~= 0);
R2_perp_AllLag_Mean_NoZ = R2_perp_AllLag_Mean(R2_perp_AllLag_Mean ~= 0);

figure
plot([R2_para_AllLag_Mean_NoZ' R2_perp_AllLag_Mean_NoZ'])
legend('R2 Parallel','R2 Perpendicular')

R2_para_AllLag_Mean_X = nanmean(R2_para_AllLag(7:11,:,1));
R2_para_AllLag_Mean_Y = nanmean(R2_para_AllLag(7:11,:,2));
R2_para_AllLag_Mean_X_NoZ = R2_para_AllLag_Mean_X(R2_para_AllLag_Mean_X ~= 0);
R2_para_AllLag_Mean_Y_NoZ = R2_para_AllLag_Mean_Y(R2_para_AllLag_Mean_Y ~= 0);

R2_perp_AllLag_Mean_X = nanmean(R2_perp_AllLag(:,:,1));
R2_perp_AllLag_Mean_X_NoZ = R2_perp_AllLag_Mean_X(R2_perp_AllLag_Mean_X ~= 0);

R2_perp_AllLag_Mean_X = nanmean(R2_perp_AllLag(7:11,:,1));
R2_perp_AllLag_Mean_Y = nanmean(R2_perp_AllLag(7:11,:,2));
R2_perp_AllLag_Mean_X_NoZ = R2_perp_AllLag_Mean_X(R2_perp_AllLag_Mean_X ~= 0);
R2_perp_AllLag_Mean_Y_NoZ = R2_perp_AllLag_Mean_Y(R2_perp_AllLag_Mean_Y ~= 0);

[FileList, DateNames] = CalcDecoderAge(Chewie_MSP_tsNum, DecoderStartDate)
[R2_para_DayAvg_X R2_para_DayAvg_Y DayNames] = DayAverage(R2_para_AllLag_Mean_X, R2_para_AllLag_Mean_Y, FileList(:,1), FileList(:,2))

[R2_perp_DayAvg_X R2_perp_DayAvg_Y DayNames] = DayAverage(R2_perp_AllLag_Mean_X, R2_perp_AllLag_Mean_Y, FileList(:,1), FileList(:,2))

figure
plot([R2_para_DayAvg_X' R2_perp_DayAvg_X'])
legend('R2 Parallel','R2 Perpendicular')

figure
plot([R2_para_DayAvg_Y' R2_perp_DayAvg_Y'])
legend('R2 Parallel','R2 Perpendicular')

[FileList, DateNames] = CalcDecoderAge(FileList, DecoderStartDate)
[r_map,r_map_mean, rho, pval, f, x] = CorrCoeffMap(R2_para(:,R2_para_AllLag_Mean ~= 0,1),1,FileList(R2_para_AllLag_Mean ~= 0,2))

[r_map,r_map_mean, rho, pval, f, x] = CorrCoeffMap(R2_perp(:,R2_perp_AllLag_Mean ~= 0,1),1,FileList(R2_perp_AllLag_Mean ~= 0,2))

        
       