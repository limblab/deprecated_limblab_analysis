function [IsoEMGsNormed WmEMGsNormed SprEMGsNormed] = NormalizeGeneralizableEMGs(IsoEMGs,WmEMGs,SprEMGs, SpringFile)

% Normalize
if SpringFile == 1
    EMGacrossTasks = cat(1,IsoEMGs,WmEMGs,SprEMGs);
    SortedEMGacrossTasks = sort(EMGacrossTasks,'descend');
    NinetyNinthEMGpercentile = SortedEMGacrossTasks(floor(.0005*length(SortedEMGacrossTasks)),:);
    for a=1:length(NinetyNinthEMGpercentile)
        IsoEMGsNormed(:,a) = IsoEMGs(:,a)./ NinetyNinthEMGpercentile(a);
        WmEMGsNormed(:,a) = WmEMGs(:,a)./ NinetyNinthEMGpercentile(a);
        SprEMGsNormed(:,a) = SprEMGs(:,a)./ NinetyNinthEMGpercentile(a);
    end

else
    EMGacrossTasks = cat(1,IsoEMGs,WmEMGs);
    SortedEMGacrossTasks = sort(EMGacrossTasks,'descend');
    NinetyNinthEMGpercentile = SortedEMGacrossTasks(floor(.0005*length(SortedEMGacrossTasks)),:);
    for a=1:length(NinetyNinthEMGpercentile)
        IsoEMGsNormed(:,a) = IsoEMGs(:,a)./ NinetyNinthEMGpercentile(a);
        WmEMGsNormed(:,a) = WmEMGs(:,a)./ NinetyNinthEMGpercentile(a);
    end
end