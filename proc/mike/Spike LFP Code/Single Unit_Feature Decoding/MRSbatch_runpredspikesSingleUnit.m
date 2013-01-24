%runpredfp6
%Uses MRSpredictionsfromfp6allDecoderBuild
input = 2;

Monkeys = [{Chewie_filenames} {Mini_filenames}];

for m = 1%:length(Monkeys)
    
    if m ==2
        
        if input == 1 % Remember to clear featind if building decoders on diff feat
            % Need proper folder structure if using input = 1
            
            direct = 'C:\Documents and Settings\Administrator\Desktop\Mike_Data\Spike LFP Decoding\Mini';
            %Set directory to desired directory
            cd(direct);
            
            Days=dir(direct);
            Days(1:2)=[];
            DaysNames={Days.name};
            
            MATfiles = DaysNames;
            
        elseif input == 2
            % Need to start out with list of file names if using input =2
            %DaysNames = [{kinStructOut.name}' {kinStructOut.decoder_age}'];
            DaysNames = Monkeys{m};
            MATfiles = DaysNames;
            %DaysNames = DaysNames(cellfun(@isnan,{kinStructOut.decoder_age})==0,:);
            direct = 'C:\Documents and Settings\Administrator\Desktop\Mike_Data\Spike LFP Decoding\Mini';
            
        end
        
        signal = 'vel';
        cells = [];
        folds = 10;
        numlags= 10;
        numsides = 1;
        lambda = 1;
        Poly = 0;
        Use_Thresh = 0;
        emglpf=0;
        binlen=50;  %[50,100]
        binsize = binlen/1000;
        % H_SingleUnits = cell([90, 117, 2]);
        for l=155:length(MATfiles)
            
            if input == 1
                fnam = MATfiles{l}
                sname=[direct,'\','Decoders','\',fnam];
                load(fnam);
                
            elseif input == 2
                fnam =  findBDFonCitadel(DaysNames{l})
                sname=[direct,'\',DaysNames{l}];
                try
                    load(fnam)
                catch exception
                    continue
                end
                
            end
            
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
                    neuronIDs = cells;
                catch
                    NoSpikeFileNames{l} = fnam
                    continue
                end
                
                featind = [];
                P = [];
            end
            
            %Sample Rate for this file
            words=bdf.words;
            
            [vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,H,x,y,ytnew,xtnew,P]=... %,t]=...
                MRSpredictions_SingleUnitmwstikpoly(bdf,signal,cells,binsize,folds,numlags,numsides,...
                lambda,Poly,Use_Thresh,fnam,emglpf,H,P,neuronIDs);
            
            try
                H_SingleUnits{l,m} = H';
            catch
                continue
            end
            P_SingleUnits{l,m} = P;
            
            save([sname,'spikes tik velpred ',num2str(binlen),'ms bins lambda',...
                num2str(lambda),' Poly',num2str(Poly),'.mat'],...%<-Filename
                'v*','y*','r*','x','H*','P','neuronIDs');%'t');
            
            clear v* y* x r* bdf P H...%Hbest Pbest bestneuronIDs<--if reloading decoder on every iteration
                words
            
            close all
            
        end
        
        
        vaf_X_SingleUnits = zeros(90, 117, 2);
        vaf_Y_SingleUnits = zeros(90, 117, 2);
        
        r2_X_SingleUnits = zeros(90, 117, 2);
        r2_Y_SingleUnits = zeros(90, 117, 2);
        
    elseif m == 2 || m == 1
        
        
        for k = [size(Monkeys{m},1)-5:size(Monkeys{m},1)]
            if m ==1
                start = 167;
            else
                start = 155;
            end
            for j = start:size(Monkeys{m},1)
                
                if input == 1
                    fnam = MATfiles{length(MATfiles)};
                    fname=[direct,fnam];
                    sname=[direct,fnam];
                    load(fnam);
                    
                else
                    fnam = findBDFonCitadel(MATfiles{k})
                    sname=[direct,'\',DaysNames{l}];
                    try
                        load(fnam)
                    catch exception
                        continue
                    end
                    
                end
                
                if exist('out_struct','var')
                    bdf = out_struct;
                    clear out_struct
                end
                
                DecNam =  findBDFonCitadel(MATfiles{j})
                load(DecNam)
                
                try
                    DecNeuronIDsIN{j-start+1,m} = unit_list(out_struct)
                catch
                    NoSpikeFileNames{l} = fnam
                    continue
                end
                
                clear outstruct
                
                %try
                    %[vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,H,x,y,ytnew,xtnew,P,
                    [NewCells]=... %,t]=...
                        MRSpredictions_SingleUnitmwstikpoly(bdf,signal,[],binsize,folds,numlags,numsides,...
                        lambda,Poly,Use_Thresh,fnam,emglpf,H_SingleUnits{j,m},P_SingleUnits{j},DecNeuronIDsIN{j-start+1,m});
                %catch exception
                 %   rethrow(exception)
                 %   continue
                %end
                
                  DecNeuronIDsOUT{j-start+1,m} = NewCells;
%                 vaf_X_SingleUnits{j-start+1,m,k} = vaf(:,1);
%                 vaf_Y_SingleUnits{j-start+1,m,k} = vaf(:,2);
%                 
%                 r2_X_SingleUnits{j-start+1,m,k} = r2(:,1);
%                 r2_Y_SingleUnits{j-start+1,m,k} = r2(:,2);
                
                save('SingleUnitDec_LFP_BC_Decoder1_Chewie_NeuronIDs_Output.mat','DecNeuronIDs*');
            end
        end
    end
    
end
% end

% Plot code

% r2_X_Mini = squeeze(vaf_X_SingleUnits(:,:,1));
% r2_Y_Mini = squeeze(vaf_Y_SingleUnits(:,:,1));
%
% r2_X_Chewie = squeeze(vaf_X_SingleUnits(:,:,2));
% r2_Y_Chewie = squeeze(vaf_Y_SingleUnits(:,:,2));
%
% r2_X_SingleUnitsSorted = sortrows(r2_X_Chewie,-1);
% r2_Y_SingleUnitsSorted = sortrows(r2_Y_Chewie,-3);
%
% r2_X_SingleUnitsSorted_Mini = sortrows(r2_X_Mini,-1);
% r2_Y_SingleUnitsSorted_Mini = sortrows(r2_Y_Mini,-1);
% %
% imagesc(r2_X_SingleUnitsSorted);figure(gcf);
% title('X Vel Spike Decoder Perf -- Chewie')
% caxis([0 .5])
%
% figure;
% imagesc(r2_Y_SingleUnitsSorted_Mini);figure(gcf);
% title('Y Vel Spike Decoder Perf -- Chewie')
% caxis([0 .5])
