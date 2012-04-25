
%runpredfp6 
%Uses MRSpredictionsfromfp6allDecoderBuild
direct = 'C:\Documents and Settings\Administrator\Desktop\ChewieData\Spike LFP Decoding\Chewie';
%Set directory to desired directory

cd(direct);

Days=dir(direct);
Days(1:2)=[];
DaysNames={Days.name};

for i = 1:length(DaysNames)
    %Convert plx to bdf
    DayName = [direct,'\',DaysNames{i},'\'];
    cd(DayName);

    %Get mat file names and create decoder
    Files=dir(DayName);
    FileNames={Files.name};
    MATfiles=FileNames(cellfun(@isempty,regexpi(FileNames,'_Spike_LFP.*(?<!poly.*)(?<!decoder)\.mat'))==0);
    if isempty(MATfiles)
        fprintf(1,'no MAT files found.  Make sure no files have ''only'' in the filename\n.')
        disp('quitting...')
        return
    end

    %Set file to desired filename(s)

    
    %Variables are declared inside and outside loop the same order they are input
    %to fxn: MRSpredictionsfromfp6allDecoderBuild

    %***Declare all input arguments that stay constant through all loop
    %iterations outside loop (vars to be declared inside loop are commented out below):

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
    
    for l=1:length(MATfiles)
        
        %if i == 2 || i == 3
         %   load('Mini_Spike_LFPL_734-spikedecoder.mat')
          %  Hbest = H(:,1:2);
           % bestneuronIDs = neuronIDs;
            %Pbest = P;
            
       
        %else
            if l == 2
            %Load previous H matrix for offline predictions if desired
            %load(['Chewie_Spike_LFP_08082011001_sub-binned_Decoder.mat']);
            load([sname,'spikes tik velpred ',num2str(binlen),'ms bins lambda',...
                num2str(lambda),' Poly',num2str(Poly),'.mat']);
            BEST_ind = find(max(sum(r2,2))==sum(r2,2));
            Hbest = H{BEST_ind};
            Pbest = P;
            r2best(:,:) = r2(BEST_ind,:);
            bestneuronIDs = neuronIDs;
            save([sname,'spikes tik velpred ',num2str(binlen),'ms bins lambda',...
                num2str(lambda),' Poly',num2str(Poly),'_BEST','.mat'],'Hbest',...
                'Pbest','bestneuronIDs','r2best','featind');
            disp('Saved best decoder from first file');
            end
        %end
        fnam = MATfiles{l}
        fname=[direct,fnam];
        sname=[direct,fnam];
        load(fnam);
        
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
        cells = unit_list(bdf);
        neuronIDs = cells;
        featind = [];
        P = [];
        end
        %Declare input variables within loop that vary in each loop iteration:
        
        %Sample Rate for this file
        words=bdf.words;

        [vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,H,x,y,ytnew,xtnew,P,t]=...
        MRSpredictions_mwstikpoly(bdf,signal,cells,binsize,folds,numlags,numsides,...
        lambda,Poly,Use_Thresh,fnam,emglpf,H,P,neuronIDs);

        save([sname,'spikes tik velpred ',num2str(binlen),'ms bins lambda',...
                num2str(lambda),' Poly',num2str(Poly),'.mat'],...%<-Filename
        'v*','y*','r*','x','H','P','neuronIDs','t');

        clear v* y* x r* neuronIDs bdf P H...%Hbest Pbest bestneuronIDs<--if reloading decoder on every iteration
              words cells
              
        close all

    end
    clear H Hbest neuronIDs bestneuronIDs P Pbest
    
    direct = 'C:\Documents and Settings\Administrator\Desktop\ChewieData\Spike LFP Decoding\Chewie';
    %Set directory to desired directory
    cd(direct);

    Days=dir(direct);
    Days(1:2)=[];
    DaysNames={Days.name};
end