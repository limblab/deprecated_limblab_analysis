%test of executing m-file saving itself
fname=strcat(mfilename,'.m')
mkdir(strcat(pwd,'\'),strcat('test',date))
folderpath=strcat(pwd,'\','test',date,'\')

disp('copying file:')
strcat(pwd,'\',fname)
[SUCCESS,MESSAGE,MESSAGEID] = copyfile(strcat(pwd,'\',fname),folderpath)

