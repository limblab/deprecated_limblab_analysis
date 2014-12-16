%[R2_para R2_perp] = testSVDproj(H,neuronIDs,shuntedch,r2,r2chan_index)
%Test n_parallel and n_perpendicular with Single Weiner Decoder

binsize  = .05;
numlags  = 10;
numsides = 1;
lambda   = 1;
binsamprate = floor(1/binsize);

FileList = Mini_MSP_DaysNames;
for q = 1:length(Mini_MSP_DaysNames);
    %% Load file
    if exist('fnam','var') == 0
        fnam{q} =  findBDFonCitadel(FileList{q,1})
    elseif length(fnam) >= q
        if isempty(fnam{q}) == 1
            fnam{q} = findBDFonCitadel(FileList{q,1})
        end
    else
        fnam{q} =  findBDFonCitadel(FileList{q,1})
    end
    
    try
        load(fnam{q})
    catch exception
        FilesNotRun{q,2} = exception;
        FilesNotRun{q,1} = fnam
        continue
    end
    
    bdf = out_struct
    clear out_struct
    
    %% Prepare variables for building decoder and making predictions
    t = bdf.vel(1,1):binsize:bdf.vel(end,1);
    y = bdf.vel(:,2:3);
    y = [interp1(bdf.vel(:,1), y(:,1), t); interp1(bdf.vel(:,1), y(:,2), t)]';
    
    cells = unit_list(bdf);
    x = zeros(length(y), length(cells));
    for i = 1:length(cells)
        if cells(i,1) ~= 0
            ts = get_unit(bdf, cells(i, 1), cells(i, 2));
            b = train2bins(ts, t);
            x(:,i) = b;
        else
            x(:,i) = zeros(length(y),1);
        end
    end
    
    clear b cells i ts t
    
    DecoderSVD
    
    %% Now start projecting neuron firing rates onto SVD eigen vectors
    for vi = 1:length(V)
        alpha1 = x*V{vi}(:,1)
        alpha2 = x*V{vi}(:,2)
        
        n_para(:,vi) = sqrt(alpha1.^2+alpha2.^2);
        
        for ni = 3:size(V,2)
            alpha_n(ni,:) = x*V{:,vi}(:,ni);
        end
        
        n_perp(:,vi) = sqrt(sum(alpha_n.^2,1))'
        i = 1;
 
    end
    
    [H_para{vi,q},v,mcc] = FILMIMO3_tik(n_para, y, numlags, numsides,lambda,binsamprate);
    [H_perp{vi,q},v,mcc] = FILMIMO3_tik(n_perp, y, numlags, numsides,lambda,binsamprate);
    
    [y_pred_para{vi},xtnew{vi},ytnew_para{vi}] = predMIMO3(n_para,H_para{vi,q},numsides,binsamprate,y);
    [y_pred_perp{vi},xtnew{vi},ytnew_perp{vi}] = predMIMO3(n_perp,H_perp{vi,q},numsides,binsamprate,y);
    
    for j = 1:size(y,2)
        r_para{vi,q,j}=corrcoef(y_pred_para{vi}(:,j),ytnew_para{vi}(:,j));
        r{vi,q,j}=corrcoef(y_pred_para{vi}(:,j),ytnew_para{vi}(:,j));
        
        r_perp{vi,q,j}=corrcoef(y_pred_perp{vi}(:,j),ytnew_perp{vi}(:,j));
        r{vi,q,j}=corrcoef(y_pred_perp{vi}(:,j),ytnew_perp{vi}(:,j));
        
        R2_para(vi,q,j)=r_para{vi,q}(1,2)^2;
        R2_perp(vi,q,j)=r_perp{vi,q}(1,2)^2;
    end
    
    clear alpha* n_* 
    %         vaf(vi,:)=RcoeffDet(y_pred{vi},ytnew{vi});
end

