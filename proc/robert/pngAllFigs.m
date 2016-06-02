function pngAllFigs(pathName)

currPath=pwd;

if nargin==0
    pathName=uigetdir('','select a folder with .figs');
    if isnumeric(pathName) && pathName==0
        disp('cancelled.')
        return
    end
else
    if exist(pathName,'file')~=7
        pathName=uigetdir(pathName,'select a folder with .figs');
    end
end
cd(pathName)
D=dir(pathName);
D(cellfun(@isempty,regexp({D.name},'\.fig')))=[];

for n=1:length(D)
    open(D(n).name)
    print(gcf,regexprep(D(n).name,'\.fig','.png'),'-dpng')
    close
end

cd(currPath)