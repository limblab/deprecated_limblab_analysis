function batch_handControl_decoderPerformance

originalPath=pwd;

BatchList6targAll={...
    'Chewie_Spike_LFP_09022011001',...
    'Chewie_Spike_LFP_09022011004',...
    'Chewie_Spike_LFP_09062011001',...
    'Chewie_Spike_LFP_09062011005',...
    'Chewie_Spike_LFP_09072011001',...
    'Chewie_Spike_LFP_09072011006',...
    'Chewie_Spike_LFP_09082011001',...
    'Chewie_Spike_LFP_09082011004',...
    'Chewie_Spike_LFP_09082011007',...
    'Chewie_Spike_LFP_09092011001',...
    'Chewie_Spike_LFP_09092011004',...
    'Chewie_Spike_LFP_09092011007',...
    'Chewie_Spike_LFP_11302011001',...
    'Chewie_Spike_LFP_12012011001',...
    'Chewie_Spike_LFP_12022011001',...
    'Chewie_Spike_LFP_12052011001',...
    'Chewie_Spike_LFP_12062011002',...
    'Chewie_Spike_LFP_12072011001',...
    'Chewie_Spike_LFP_12082011001',...
    'Chewie_Spike_LFP_12092011001',...
    'Chewie_Spike_LFP_12122011001',...
    'Chewie_Spike_LFP_12132011001',...
    'Chewie_Spike_LFP_12142011002',...
    'Chewie_Spike_LFP_12152011001',...
    'Chewie_Spike_LFP_12192011001',...
    'Chewie_Spike_LFP_12202011001',...
    'Chewie_Spike_LFP_12212011001',...
    'Chewie_Spike_LFP_12222011005',...
    'Chewie_Spike_LFP_12222011008',...
    'Chewie_Spike_LFP_12272011001',...
    'Chewie_Spike_LFP_12272011004',...
    'Chewie_Spike_LFP_12282011001',...
    'Chewie_Spike_LFP_12282011005',...
    'Chewie_Spike_LFP_12292011001',...
    'Chewie_Spike_LFP_12292011005',...
    'Chewie_Spike_LFP_01032012001',...
    'Chewie_Spike_LFP_01032012005',...
    'Chewie_Spike_LFP_01042012001',...
    'Chewie_Spike_LFP_01042012005',...
    'Chewie_Spike_LFP_01052012001',...
    'Chewie_Spike_LFP_01052012006',...
    'Chewie_Spike_LFP_01062012001',...
    'Chewie_Spike_LFP_01092012005',...
    'Chewie_Spike_LFP_01132012009',...
    'Chewie_Spike_LFP_01162012002',...
    'Chewie_Spike_LFP_01162012006',...
    'Chewie_Spike_LFP_01172012006',...
    'Chewie_Spike_LFP_01182012001',...
    'Chewie_Spike_LFP_01192012001',...
    'Chewie_Spike_LFP_01202012001',...
    'Chewie_Spike_LFP_01232012001',...
    'Chewie_Spike_LFP_01232012002',...
    'Chewie_Spike_LFP_01232012003',...
    'Chewie_Spike_LFP_01232012007',...
    'Chewie_Spike_LFP_01232012007',...
    'Chewie_Spike_LFP_01272012001',...
    'Chewie_Spike_LFP_01272012008',...    
    'Chewie_Spike_LFP_01302012001',...
    'Chewie_Spike_LFP_01302012008',...
    'Chewie_Spike_LFP_01312012001',...
    'Chewie_Spike_LFP_01312012008',...
    'Chewie_Spike_LFP_02012012001',...
    'Chewie_Spike_LFP_02012012008',...
    'Chewie_Spike_LFP_02022012001',...
    'Chewie_Spike_LFP_02022012008',...
    'Chewie_Spike_LFP_02032012001',...
    'Chewie_Spike_LFP_02032012004',...
    'Chewie_Spike_LFP_02062012001',...
    'Chewie_Spike_LFP_02062012006',...
    'Chewie_Spike_LFP_02082012001',...
    'Chewie_Spike_LFP_02082012005',...
    'Chewie_Spike_LFP_02102012001',...
    'Chewie_Spike_LFP_02102012005',...
    'Chewie_Spike_LFP_02132012001',...
    'Chewie_Spike_LFP_02132012004',...
    'Chewie_Spike_LFP_02152012001',...
    'Chewie_Spike_LFP_02152012005',...
    'Chewie_Spike_LFP_02172012001',...
    'Chewie_Spike_LFP_02172012005',...
    'Chewie_Spike_LFP_02202012001',...
    'Chewie_Spike_LFP_02202012004',...
    'Chewie_Spike_LFP_02222012001',...
    'Chewie_Spike_LFP_02222012005',...
    'Chewie_Spike_LFP_02242012001',...
    'Chewie_Spike_LFP_02242012005',...
    'Chewie_Spike_LFP_02272012004',...
    'Chewie_Spike_LFP_02292012001',...
    'Chewie_Spike_LFP_02292012005',...
    'Chewie_Spike_LFP_03022012001',...
    'Chewie_Spike_LFP_03022012008',...
    'Chewie_Spike_LFP_03052012001',...
    'Chewie_Spike_LFP_03072012001',...
    'Chewie_Spike_LFP_03072012005',...
    'Chewie_Spike_LFP_03092012001',...
    'Chewie_Spike_LFP_03092012004',...
    'Chewie_Spike_LFP_03122012004',...
    'Chewie_Spike_LFP_03142012001',...
    'Chewie_Spike_LFP_03142012005',...
    'Chewie_Spike_LFP_03162012001',...
    'Chewie_Spike_LFP_03162012005',...
    'Chewie_Spike_LFP_03192012004',...
    'Chewie_Spike_LFP_03212012001',...
    'Chewie_Spike_LFP_03212012005',...
    'Chewie_Spike_LFP_03262012004',...
    'Chewie_Spike_LFP_03282012001',...
    'Chewie_Spike_LFP_03282012005',...
    'Chewie_Spike_LFP_03302012001',...
    'Chewie_Spike_LFP_03302012004',...    
    'Mini_Spike_LFPL_107',...
    'Mini_Spike_LFPL_112',...
    'Mini_Spike_LFPL_119',...
    'Mini_Spike_LFPL_	125',...
    'Mini_Spike_LFPL_130',...
    'Mini_Spike_LFPL_139',...
    'Mini_Spike_LFPL_146',...
    'Mini_Spike_LFPL_153',...
    'Mini_Spike_LFPL_158',...
    'Mini_Spike_LFPL_164',...
    'Mini_Spike_LFPL_	505',...
    'Mini_Spike_LFPL_	514',...
    'Mini_Spike_LFPL_	521',...
    'Mini_Spike_LFPL_	528',...
    'Mini_Spike_LFPL_	537',...
    'Mini_Spike_LFPL_	544',...
    'Mini_Spike_LFPL_	551',...
    'Mini_Spike_LFPL_	561',...
    'Mini_Spike_LFPL_	568',...
    'Mini_Spike_LFPL_	575',...
    'Mini_Spike_LFPL_	581',...
    'Mini_Spike_LFPL_	591',...
    'Mini_Spike_LFPL_	628',...
    'Mini_Spike_LFPL_	632',...
    'Mini_Spike_LFPL_	639',...
    'Mini_Spike_LFPL_	647',...
    'Mini_Spike_LFPL_	683',...
};

BatchList6targAllFilesChewie=BatchList6targAll(~isempty(regexp(BatchList6targAll,'Chewie')));

% the following only goes up to 1-19-2012 or so.
BatchListAllTargFirstFile={...              % doesn't have to be the very
    'Chewie_Spike_LFP_09022011001',...      % first file of the day, but
    'Chewie_Spike_LFP_09062011001',...      % it has to proceed any 
    'Chewie_Spike_LFP_09072011001',...      % brain control files for
    'Chewie_Spike_LFP_09082011001',...      % the day.
    'Chewie_Spike_LFP_09092011001',...
    'Chewie_Spike_LFP_09122011002',...      % 3 targets.  1st 10-min HC
    'Chewie_Spike_LFP_09152011001',...      % 3 targets.
    'Chewie_Spike_LFP_09162011001',...      % 3 targets.
    'Chewie_Spike_LFP_09192011001',...      % 3 targets.
    'Chewie_Spike_LFP_09232011001',...      % 3 targets.
    'Chewie_Spike_LFP_09302011001',...      % 7.5 min file!  3 targets.  sub-par LFP control performance.
    'Chewie_Spike_LFP_10032011001',...      % 3 targets.  sub-par LFP control performance.
    'Chewie_Spike_LFP_10072011001',...      % 3 targets.
    'Chewie_Spike_LFP_10102011001',...      % 3 targets.
    'Chewie_Spike_LFP_10142011001',...      % 3 targets.  sub-par LFP control performance.
    'Chewie_Spike_LFP_10212011001',...      % 3 targets.
    'Chewie_Spike_LFP_10282011001',...      % 3 targets.  sub-par LFP control performance.
    'Chewie_Spike_LFP_11042011001',...      % 3 targets.  sub-par LFP control performance.
    'Chewie_Spike_LFP_11112011001',...      % 3 targets.  sub-par LFP control performance.
    'Chewie_Spike_LFP_11182011001',...      % 3 targets.  sub-par LFP control performance.
    'Chewie_Spike_LFP_11212011001',...      % 3 targets.
    'Chewie_Spike_LFP_11302011001',...
    'Chewie_Spike_LFP_12012011001',...
    'Chewie_Spike_LFP_12022011001',...
    'Chewie_Spike_LFP_12062011002',...
    'Chewie_Spike_LFP_12072011001',...
    'Chewie_Spike_LFP_12082011001',...
    'Chewie_Spike_LFP_12092011001',...
    'Chewie_Spike_LFP_12122011001',...
    'Chewie_Spike_LFP_12132011001',...
    'Chewie_Spike_LFP_12142011002',...
    'Chewie_Spike_LFP_12152011001',...
    'Chewie_Spike_LFP_12192011001',...
    'Chewie_Spike_LFP_12202011001',...
    'Chewie_Spike_LFP_12212011001',...
    'Chewie_Spike_LFP_12272011001',...
    'Chewie_Spike_LFP_12282011001',...
    'Chewie_Spike_LFP_12292011001',...
    'Chewie_Spike_LFP_01032012001',...
    'Chewie_Spike_LFP_01042012001',...
    'Chewie_Spike_LFP_01052012001',...
    'Chewie_Spike_LFP_01062012001',...
    'Chewie_Spike_LFP_01092012001',...      % 3 targets.  Also has 6, but not before LFP control.
    'Chewie_Spike_LFP_01132012001',...      % 3 targets.  Also has 6, but not before LFP control.
    'Chewie_Spike_LFP_01162012002',...      % file 2 is six-target, comes before LFP control.
    'Chewie_Spike_LFP_01182012001',...
    'Mini_Spike_LFPL_107',...
    'Mini_Spike_LFPL_112',...
    'Mini_Spike_LFPL_119',...
    'Mini_Spike_LFPL_130',...
    'Mini_Spike_LFPL_139',...
    'Mini_Spike_LFPL_146',...
    'Mini_Spike_LFPL_153',...
    'Mini_Spike_LFPL_158',...
    'Mini_Spike_LFPL_164',...
    'Mini_Spike_LFPL_	171',...            % 3 targets.  comment: FP1-FP32 did not look good.
    'Mini_Spike_LFPL_	182',...            % 3 targets.  comment: LFPs look good.  sub-par LFP control day.
    'Mini_Spike_LFPL_	187',...            % 3 targets.  sub-par LFP control day.
    'Mini_Spike_LFPL_	193',...            % 3 targets.  sub-par LFP control day.
    'Mini_Spike_LFPL_	217',...            % 3 targets.  09/23/2011
    'Mini_Spike_LFPL_	284',...            % 3 targets.  this was 10/07, also a candidate on 09/30 but power failure that day.
    'Mini_Spike_LFPL_	312',...            % 3 targets.  sub-par LFP control day.
    'Mini_Spike_LFPL_	346',...            % 3 targets.
    'Mini_Spike_LFPL_	389',...            % 3 targets.
    'Mini_Spike_LFPL_	422',...            % 3 targets.  sub-par LFP control day.
    'Mini_Spike_LFPL_	429',...            % 3 targets.
    'Mini_Spike_LFPL_	450',...            % 3 targets.
    'Mini_Spike_LFPL_	490',...            % 3 targets.
    'Mini_Spike_LFPL_	499',...            % 3 targets.
    'Mini_Spike_LFPL_	505',...
    'Mini_Spike_LFPL_	514',...
    'Mini_Spike_LFPL_	521',...
    'Mini_Spike_LFPL_	528',...
    'Mini_Spike_LFPL_	537',...
    'Mini_Spike_LFPL_	544',...
    'Mini_Spike_LFPL_	551',...
    'Mini_Spike_LFPL_	561',...
    'Mini_Spike_LFPL_	568',...
    'Mini_Spike_LFPL_	575',...
    'Mini_Spike_LFPL_	581',...
    'Mini_Spike_LFPL_	591',...            % the 20-day gap following this is because of the
    'Mini_Spike_LFPL_	628',...            % bump experiments & holiday break.  no help for it.
    'Mini_Spike_LFPL_	632',...
    'Mini_Spike_LFPL_	639',...
    'Mini_Spike_LFPL_	647',...
    'Mini_Spike_LFPL_	683',...
};

BatchList=BatchList6targAllFilesChewie;

for n=1:length(BatchList)
    BatchList{n}=regexprep(BatchList{n},'\t',''); 

    try
        VAFstruct(n)=handControl_decoderPerformance_RDF(BatchList{n});
    end
    close
    cd(originalPath)
    save(fullfile(originalPath,'VAFstruct.mat'),'VAFstruct')
    assignin('base','VAFstruct',VAFstruct)
end


