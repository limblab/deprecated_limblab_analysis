function file2cds(cds,filePath,varargin)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %file2cds(folderPath,fileName) loads the file(s) specified into an
    %NEVNSx and then loads it into the cds using NEVNSx2cds. fileName can
    %be any prefix accepted by cerebus2NEVNSx
    
    
%     %see if the 'noDB' flag was passed
%     noDB=0;
%     for i=1:length(varargin)
%         if strcmp(varargin{i},'noDB')
%             noDB=1;
%         end
%     end
%     %check the database to see if the file has already been processed and
%     %load it if it has:
%     dataFromDB=0;
%     if ~noDB
%         try
%             conn=database('LLTestingDB','LLMatlabScript','mvemjlht','Vendor','PostgreSQL','Server','vfsmmillerwiki.fsm.northwestern.edu');
%             data=fetch(conn,['select *** from session where sourceFile = ',fileName]
%             if ~isempty(data)
%                 %load from database
%                 cds.database2cds(conn,data,varargin)
%                 dataFromDB=1;
%             end
%             close(conn);
%         catch 
%             warning('file2cds:databaseError','Failed to connect or fetch data from the LLSessionsDB database')
%             
%         end
%     end
%     if ~dataFromDB
%         varargin=[varargin,{'dbEmpty'}];
        cds.nev2NEVNSx(filePath);
        cds.NEVNSx2cds(varargin{:});
        cds.clearTempFields()
        evntData=loggingListenerEventData('file2cds',[]);
        notify(cds,'ranOperation',evntData)
%     end
end