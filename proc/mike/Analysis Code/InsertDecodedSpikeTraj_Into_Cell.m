direct = 'C:\Documents and Settings\Administrator\Desktop\ChewieData\Spike LFP Decoding\Chewie\LFP vel pred using LFP decoder from HC';
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
    MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,'_Spike_LFP.*(?<!poly.*)\.mat'))==0);

    
    
    for l=1:length(MATfiles)
        
        fnam = MATfiles{l}
        fname=[direct,fnam];
        load(fnam);
        
        a = [];

        for k = 1:length(y_pred)
        a = [a; y_pred{k}]; %<-- LFP Predictions

        end
        
        Inval_Ind_x = find((isnan(a(:,1))==1)|(isinf(a(:,1))==1));
        Inval_Ind_y = find((isnan(a(:,2))==1)|(isinf(a(:,2))==1));
        
        a(Inval_Ind_x,:) = 0;
        a(Inval_Ind_y,:) = 0;
        
        %b = t;

        %a = [b a];
        All_Predictions_BC_HC_Decoders{i,l,2}(:,:) = a;
        
    end
end


