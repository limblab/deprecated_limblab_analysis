%file runisospch runs isolatespikechans for batch processing


% fil='ChewieSpikeLFP'
% Sfilelist={'MiniSpikeLFP046-10','MiniSpikeLFP083-06','MiniSpikeLFP108-25','MiniSpikeLFP144&145-11'}
% Sfilelist={'ChewieSpikeLFP068-final-02','ChewieSpikeLFP114-final-02','ChewieSpikeLFP220-final','ChewieSpikeLFP270-03','ChewieSpikeLFP281-01'};
% FPlist={'046','083','108','144-5'}
% FPlist={'068','114','220','270fp4','281'};
fil='MiniSpikeLFPL'
Sfilelist={'MiniSpikeLFPL037sorted','MiniSpikeLFPL040sorted','MiniSpikeLFPL045sorted'}
FPlist={'037sorted','040sorted','045sorted'}

for ii=1:length(FPlist)
    
    for jj=1:length(FPlist)
        if ii>=jj
            continue    %Don't compare in the same file, obviously
        end
        % file2='ChewieSpikeLFP114'
        file1num=FPlist{ii};
        file2num=FPlist{jj};
        file1=[fil,file1num];
        file2=[fil,file2num];
%         Sdir='E:\Data\Chewie\Spikes\';
        Sdir='E:\Data\Mini\Spikes\';
        Sfile1=[Sdir,Sfilelist{ii}];
        Sfile2=[Sdir,Sfilelist{jj}];
        
%         if ii==4
%             badchans1=[3,5,6,45,51,63,70,72,76,77,78,79,88,92,95,96];  
%         elseif ii==5
%             badchans1=[3,30,64,68,70,79,82,94,95]; 
%         else
%             badchans1=[14,79];
%         end
badchans1=[70];
badchans2=[70];
%         if jj==4
%             badchans2=[3,5,6,45,51,63,70,72,76,77,78,79,88,92,95,96];   %badchans for
%         elseif jj==5
%         % new Chewie spike files
%         badchans2=[3,30,64,68,70,79,82,94,95]; %for 281
%         else
%             badchans2=[14,79];
%         end
        % 
        
%         badchans1=[18,71];
%         badchans2=[18,71];
        isolatespikechans_emg
    end
end