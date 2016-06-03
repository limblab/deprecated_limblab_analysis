function [DecNeuronIDsOUT,r2_X_SingleUnits,r2_Y_SingleUnits,H_SingleUnits]=batch_runpredspikesSingleUnit(Monkeys,outputFile)

% Monkeys should be a list of filenames, but it could be for both, i.e.
%       {Chewie_FileNames,Mini_Filenames}
% Even if it's only 1 monkey, that filename list needs to be encased
% within a 1-element cell so that the indexing will work properly.

if nargin < 2
    outputFile='output.mat';
end
[direct,fileName,fileExt]=fileparts(outputFile);
fileName=[fileName,fileExt];                                                %#ok<*NASGU>
if isempty(direct), direct=pwd; end

for m = 1:length(Monkeys)
    DaysNames = Monkeys{m};
    MATfiles = DaysNames;
    
    signal = 'vel';
    cells = [];
    folds = 10;
    numlags= 10;
    numsides = 1;
    lambda = 1;
    Poly = 0;
    Use_Thresh = 0;
    emglpf=0;
    binlen=50;
    binsize = binlen/1000;
    if ~exist('H_SingleUnits.mat','file')
        for l=1:length(MATfiles)
            fnam =  findBDFonCitadel(DaysNames{l});
            fprintf(1,'loading %s...\n',fnam)
            load(fnam)
            fprintf(1,'building decoder...\n')
            
            if exist('out_struct','var')
                bdf = out_struct;
                clear out_struct
            end
            
            if exist('Hbest','var')
                H = Hbest; %<- Use if inputting H matrix, also don't 'clear' H in loop
                neuronIDs = bestneuronIDs;
                cells = [];
                P = Pbest;
            else
                H = [];
                
                try
                    cells = unit_list(bdf);
                    neuronIDs{l} = cells;
                catch
                    NoSpikeFileNames{l} = fnam
                    continue
                end
                
                featind = [];
                P = [];
            end
            
            words=[];
            
            [vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,H,x,y,ytnew,xtnew,P]=            ... %,t]=...
                predictions_SingleUnitmwstikpoly(bdf,signal,cells,binsize,folds,numlags,numsides,...
                lambda,Poly,Use_Thresh,fnam,emglpf,H,P,neuronIDs{l});
            
            try
                H_SingleUnits{l,m} = H';
                save('H_SingleUnits.mat','H_SingleUnits')
                save('neuronIDs.mat','neuronIDs')
            catch exception
                continue
            end
            P_SingleUnits{l,m} = P;
            
            clear v* y* x r* bdf P H...%Hbest Pbest bestneuronIDs<--if reloading decoder on every iteration
                words
            close all
        end
    else
        load('H_SingleUnits.mat')
        load('neuronIDs.mat')        
    end
    
    z =1;
    for k = (size(Monkeys{m},1)-5):(size(Monkeys{m},1)-1)
        for j = 1:size(Monkeys{m},1)
            if j==1
                try
                    Testfiles{k}=findBDFonCitadel(MATfiles{k});
                    fprintf(1,'testing on %s...\n',Testfiles{k})
                    load(Testfiles{k})
                    bdf{k}=out_struct;
                    clear out_struct
                catch exception
                    continue
                end
            end
            
            if exist('out_struct','var')
                bdf = out_struct;
                clear out_struct
            end
            
            DecNam=findBDFonCitadel(MATfiles{j});
            fprintf(1,'predicting with %s decoder...\n',DecNam)
            
            DecNeuronIDsIN{j,m,z}=neuronIDs{j};
            
            [vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,H,x,y,ytnew,xtnew,P,NewCells]... %,t]=...
                =predictions_SingleUnitmwstikpoly(bdf{k},signal,[],binsize,folds,numlags,numsides,...
                lambda,Poly,Use_Thresh,DecNam,emglpf,H_SingleUnits{j,m},[],DecNeuronIDsIN{j,m,z});
            
            DecNeuronIDsOUT{j,m,z} = NewCells;
            vaf_X_SingleUnits{j,m,z} = vaf(:,1);
            vaf_Y_SingleUnits{j,m,z} = vaf(:,2);
            
            r2_X_SingleUnits{j,m,z} = r2(:,1); %#ok<*AGROW>
            r2_Y_SingleUnits{j,m,z} = r2(:,2);
            
            KJ=[k j];
            save([mfilename,'_interstitial.mat'],'vaf_X_SingleUnits', ...
                'vaf_Y_SingleUnits','r2_X_SingleUnits', ...
                'r2_Y_SingleUnits','KJ','DecNeuronIDsOUT','MATfiles');
        end
        z = z + 1;
    end
end

vaf_SingleUnits=[vaf_X_SingleUnits, vaf_Y_SingleUnits];
r2_SingleUnits=[r2_X_SingleUnits, r2_Y_SingleUnits];

% if exist('H_SingleUnits.mat','file')
%     delete('H_SingleUnits.mat')
%     delete('neuronIDs.mat')
% end

