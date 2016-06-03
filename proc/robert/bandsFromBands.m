function VAFstruct=bandsFromBands(PB,bandToPredict,nfeat,testFlag,sameElectrode)

% syntax VAFstruct=bandsFromBands(PB,bandToPredict,nfeat,testFlag,sameElectrode);
%
%       INPUTS
% 
%           PB              - powerband matrix from predictions code
%           bandToPredict   - on the set 1:6, just one value
%                             (to do two or more run this function again)
%           nfeat           - number of features to be included*
%                             this input is optional.
%           testFlag        - if ==1, function will evaluate and predict
%                             using the same band, in order to do a sanity
%                             check (vafs should be quite high in this
%                             case). this input is optional.
%           sameElectrode   - if ==1, will evaluate and predict using the
%                             same electrode. this input is optional.
%
%       OUTPUTS
% 
%           VAFstruct       - has the following fields:
%                               PolynomialOrder
%                               nfeat
%                               binsize
%                               vaf
%
%       *this may be modified within the structure, in the case of certain
%        flag combinations (see Examples).
%
%       EXAMPLES
%
%           1.  Evaluate the abillity to predict Delta (0-4 Hz) using the
%               other bands.  Do not train and predict on the same electrode
%               (monkey file):
%                   VAFstruct=bandsFromBands(PB,2,90);
%                   reshape(cellfun(@nanmedian,{VAFstruct.vaf}),size(VAFstruct));
%                   nanmedian(ans,2)
%
%               ans = 
% 
%                   0.3123
%                   NaN
%                   0.2414
%                   0.1023
%                   0.0942
%                   0.0134
%
%               VAFstruct is a 6x96 structure.  In converting to a
%               cell structure so that cellfun can be used, what should be
%               a 6x96 double array gets concatenated into a column array.
%               Thus, reshape.  Taking the mean across columns tells us the
%               overall average ability of each band to decode for delta.
%               Delta itself is NaN because the code skips over it.
%
%           2.  Evaluate the ability to predict Delta (0-4 Hz) using Delta.
%               Do not train and predict on the same electrode (human MS
%               electrodes):
%                   VAFstruct=bandsFromBands(PB,2,10,1)
%                   nanmedian(cellfun(@nanmedian,{VAFstruct.vaf}))
%
%               ans = 
% 
%                   0.7890
%
%           3.  Evaluate the abillity to predict Delta (0-4 Hz) using the
%               other bands.  Train and predict on the same electrode
%               (human MS electrodes):
%                   VAFstruct=bandsFromBands(PB,2,~,0,1);
%                   reshape(cellfun(@nanmedian,{VAFstruct.vaf}),size(VAFstruct));
%                   nanmedian(ans,2)
%
%               ans = 
% 
%                   0.3123
%                   NaN
%                   0.2414
%                   0.1023
%                   0.0942
%                   0.0134
%
%               Supply a number input for nfeat, but it will be modified
%               internally.
%
%
%           4.  Evaluate the ability to predict Delta using Delta.  Train
%               and predict on the same electrode.  This should be used for
%               testing purposes only.
%                   VAFstruct=bandsFromBands(PB,2,10,1,1)
%                   nanmedian(cellfun(@nanmedian,{VAFstruct.vaf}))
%
%               ans = 
% 
%                   0.9996
%
%
%           see run_bandsFromBands.m


% assumes bin size =0.05 sec.
% testFlag=1; => test mode; bandToPredict from electrode M will be predicted using
% bandToPredict from the other electrodes.
%
% testFlag=1; sameElectrode=1; => bandToPredict from electrode M will be
% predicted using other bands, in turn, from electrode M
PolynomialOrder=3;
Use_Thresh=0;
lambda=1;
numlags=10;
numsides=1;
folds=10;
if nargin < 3 
    % default monkey file, will be 95 features/band
    nfeat=90;
end
binsize=1; % because we're dealing directly with PB, which is already downsampled to the bin sampling rate.
if nargin < 4
    testFlag=0;
end
if nargin < 5
    sameElectrode=0;
end

VAFstruct=struct('PolynomialOrder',PolynomialOrder,'nfeat',nfeat,'binsize',binsize,'vaf',[]);

bandsToUse=setdiff(1:size(PB,1),bandToPredict);
if testFlag
    bandsToUse=bandToPredict; % for sanity check
end
tic
for band=bandsToUse
    for elecInd=1:size(PB,2)
        fprintf(1,'band %d, electrode %d\n',band,elecInd)
        VAFstruct(band,elecInd).PolynomialOrder=PolynomialOrder;
        VAFstruct(band,elecInd).nfeat=nfeat;
        VAFstruct(band,elecInd).binsize=binsize;
        % use for fps, the 'band' band, taken from all the electrodes
        % except from the one we're trying to predict.
        if sameElectrode
            fpUse=rowBoat(squeeze(PB(band,elecInd,:)))';
            nfeat=1; % doesn't matter what we try to ask for, if it's 1 electrode,
                     % 1 band, then it's 1 feature.
        else
            fpUse=reshape(PB(band,setdiff(1:size(PB,2),elecInd),:),[],size(PB,3));
        end
        sigUse=[((1:size(fpUse,2))*0.05)' squeeze(PB(bandToPredict,elecInd,:))];
        if sameElectrode
            % only if we ask for 'sameElectrode' mode is it appropriate to
            % try to find the mutual information between bands, as it is
            % only defined for 2 inputs, not more.
            N=9;   % precision of the mesh
                    % arg2,3 are x_grid,y_grid. Use for: mesh(x_grid,y_grid,jpdf)
            [~,jpdf,~,~]=kde2d([fpUse' sigUse(:,2)],2^N);
            jpdf(jpdf<0)=0;
            jpdf=jpdf./sum(jpdf(:));
            margX=sum(jpdf,1); margY=sum(jpdf,2);
            
            % take log, but apply convention that log(0)=0
            logjpdf=jpdf; logjpdf(logjpdf==0)=NaN; logjpdf=log(logjpdf); 
            logjpdf(isnan(logjpdf))=0;
            margX(margX==0)=NaN; margX=log(margX); margX(isnan(margX))=0;
            margY(margY==0)=NaN; margY=log(margY); margY(isnan(margY))=0;
            VAFstruct(band,elecInd).MI=sum(sum(jpdf.*(logjpdf- ...
                repmat(margX,size(logjpdf,1),1)-repmat(margY,1,size(logjpdf,2)))));
        end        
        % to do Wiener cascade decoding of one band with the other
                                         % ... y_pred,~,ytnew] 
        [~,VAFstruct(band,elecInd).vaf,~,~,~,~,~,~,~]=predonlyxy_newVAF(fpUse',sigUse(:,2),PolynomialOrder,Use_Thresh, ...
            lambda,numlags,numsides,binsize,folds,nfeat);
    end
end
toc
