function save_figures(figHandles,behaviorfilename,output_dir,filenamesuffix,figuretitle)

if ~exist([output_dir 'Results\'],'dir')
    mkdir([output_dir 'Results\'])
end    

for iFig = 1:length(figHandles)
%     printname = [output_dir 'Results\' behaviorfilename filenamesuffix '_' num2str(iFig,'%3.3d')];
    tmp = figuretitle{iFig};
    if ~exist([output_dir 'Results\' behaviorfilename],'dir')
        mkdir([output_dir 'Results\' behaviorfilename])
    end
    if isempty(filenamesuffix)
        printname = strcat([output_dir 'Results\' behaviorfilename '\' behaviorfilename],tmp);
    else
        printname = strcat([output_dir 'Results\' behaviorfilename '\' behaviorfilename filenamesuffix '_'],tmp);
    end
    set(figHandles(iFig),'Units','inches')
    set(figHandles(iFig),'OuterPosition',[0 0 11 8.5])
    set(figHandles(iFig),'PaperPosition',[0 0 11 8.5])
    set(figHandles(iFig),'PaperOrientation','landscape')
    set(figHandles(iFig),'PaperType','usletter')
    set(figHandles(iFig),'PaperUnits','inches')
    set(figHandles(iFig),'Renderer','painters')
    try
        print(figHandles(iFig),'-dpdf',printname{1})
    catch
        print(figHandles(iFig),'-dpdf',printname)
    end
end