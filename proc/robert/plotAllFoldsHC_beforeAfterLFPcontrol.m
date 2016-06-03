function plotAllFoldsHC_beforeAfterLFPcontrol

        
HC_firstOverall_dates=datenum(regexp(HC_firstOverall_6targ,'[0-9]{8}', ...
    'match','once'),'mmddyyyy');

HC_postLFPcontrol_dates=datenum(regexp(HC_postLFPcontrol_6targ,'[0-9]{8}', ...
    'match','once'),'mmddyyyy');

datesToUse=intersect(unique(HC_firstOverall_dates), ...
    unique(HC_postLFPcontrol_dates));

figure, set(gcf,'Position',[18         386        1417         420],'Color',[1 1 1])
clusterVec=linspace(-0.3,0.3,10);
spreadFactor=5;

for n=1:length(datesToUse)
    firstFiles_match=find(cellfun(@isempty,regexp(HC_firstOverall_6targ, ...
        datestr(datesToUse(n),'mmddyyyy')))==0,1,'last');
    afterFiles_match=find(cellfun(@isempty,regexp(HC_postLFPcontrol_6targ, ...
        datestr(datesToUse(n),'mmddyyyy')))==0,1,'first');
    
    ticDate{n}=regexp(char(HC_firstOverall_6targ(firstFiles_match)),'[0-9]{8}','match','once');    
    
    if ispc
        remoteDriveLetter='Y:';
        pathToCitadelLimblab=fullfile(remoteDriveLetter,'user_folders', ...
            'Robert','data','monkey','outputs','LFPcontrol');
        [status,result1]=dos(['cd /d ',pathToCitadelLimblab,' && dir *',...
            char(HC_firstOverall_6targ(firstFiles_match)),'* /s /b']);
        result1(regexp(result1,sprintf('\n')))=[];
        if status
            error([mfilename, ' error: ',result1])
        end
        if exist(result1,'file')~=2
            error([mfilename, ': did not find ',HC_firstOverall_6targ(firstFiles_match)])
        end
        
        [status,result2]=dos(['cd /d ',pathToCitadelLimblab,' && dir *',...
            char(HC_postLFPcontrol_6targ(afterFiles_match)),'* /s /b']);
        result2(regexp(result2,sprintf('\n')))=[];
        if status
            error([mfilename, ' error: ',result2])
        end
        if exist(result2,'file')~=2
            error([mfilename, ': did not find ',HC_postLFPcontrol_6targ(afterFiles_match)])
        end
    else
        remoteDriveLetter='/Volumes/limblab';
        pathToCitadelLimblab=fullfile(remoteDriveLetter,'user_folders', ...
            'Robert','data','monkey','outputs','LFPcontrol');
        [status,result1]=unix(['find ',pathToCitadelLimblab,' -name "*', ...
            char(HC_firstOverall_6targ(firstFiles_match)),'*" -print']);
        result1(regexp(result1,sprintf('\n')))=[];
        if status
            error([mfilename, ' error: ',result1])
        end
        if exist(result1,'file')~=2
            error([mfilename, ': did not find ',char(HC_firstOverall_6targ(firstFiles_match))])
        end

        [status,result2]=unix(['find ',pathToCitadelLimblab,' -name "*', ...
            char(HC_postLFPcontrol_6targ(afterFiles_match)),'*" -print']);
        result2(regexp(result2,sprintf('\n')))=[];
        if status
            error([mfilename, ' error: ',result2])
        end
        if exist(result2,'file')~=2
            error([mfilename, ': did not find ',char(HC_postLFPcontrol_6targ(afterFiles_match))])
        end        
    end
    
    
    % if we make it to this point without erroring out, we're good to
    % proceed.
    load(result1,'vaf')
    vaf_before=vaf; clear vaf
    load(result2,'vaf')
    vaf_after=vaf; clear vaf
        
    plot((n-1)*spreadFactor+(spreadFactor-1)+clusterVec,mean(vaf_before,2),'r.')
    hold on
    plot(n*spreadFactor+clusterVec,mean(vaf_after,2),'b.')
end
set(gca,'box','off','XTick',(1:n)*spreadFactor-0.5)
% XTickLabelMaker(ticDate,gca,'Rotation',90);
hText = xticklabel_rotate(get(gca,'XTick'),90,ticDate);
set(gca,'Position',[0.0303    0.1595    0.9464    0.7655])