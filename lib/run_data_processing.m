function data_struct = run_data_processing(main_function_name,target_directory,varargin)
    %data processing wrapper
    %1)the user must pass the name of their main function: main_function_name
    %2)the name of the directory to put all the results in: target_directory
    %3)optionally a struct of configuration parameters for their processing
    %functions
    %
    %the script then perorms the following operations:
    %a)generates the lab standard folder tree
    %b)calls the function specified in main_function_name, passing in the
    %target_directory variable in case the function needs to explicitly save
    %figures or data
    %c)saves returned figures in .fig and .pdf formats. The name of the files
    %will be the name of the figure (NOT the title). If the name is empty the
    %figure wil be saved as Figure_1, Figure_2 etc. 
    %use set(H,'Name','fig_name') to set the name of figures
    %d)Saves the three input variables as separate files so that the data 
    %processing is reproducable.
    %e)Saves each field in the output data struct as a separate field. saves 
    %pstrings in flat text files and all other data in individual m-files. 
    %The names of data files will be the names of the fields of the
    %output data struct
    %
    %the user's analysis function should accept a single argument which is the
    %target folder to save the processed data into
    %the analysis function should return one cell array, and one struct:
    %the cell array should contain the handles to all the figures
    %that need to be saved. Those figures must not be closed by the
    %analysis code
    %the struct should contain the various data objects that should be
    %saved for later use. each field should be the name of the object,
    %which will be the file tname the object is saved under. If the object
    %is a simple string, the data will be written to a flat text file.
    %Lists of data files operated on and other general information should
    %be passed in this way. All other data types will be saved as .mat
    %files. For instance, a bdf can be saved by passing the bdf as one of 
    %the elements in the outpus struct.
    
    %% sanitize input:
    if ~strcmp(target_directory(end),filesep)
        disp(['appending trailing ' filesep ' character to folder name'])
        target_directory=[target_directory filesep];
    end

    %% make directory structure if it does not already exist
    
    if exist(strcat(target_directory,'Code'),'file')~=7
        mkdir(strcat(target_directory,'Code'))
    else
        warning('RUN_DATA_PROCESSING:FOLDER_EXISTS','A folder with processed data already exists, you may lose data if you continue')
        yesno=questdlg('The target folder already exists. If you continue data may be lost. Do you want to continue?','Folder already exists','Yes','No','No');
        if strcmp(yesno,'No')
            return
        end
    end
    if exist(strcat(target_directory,'Raw_Figures'),'file')~=7
        mkdir(strcat(target_directory,'Raw_Figures'))
    end
    if exist(strcat(target_directory,['Raw_Figures' filesep 'PDF']),'file')~=7
        mkdir(strcat(target_directory,['Raw_Figures' filesep 'PDF']))
    end
    if exist(strcat(target_directory,['Raw_Figures' filesep 'FIG']),'file')~=7
        mkdir(strcat(target_directory,['Raw_Figures' filesep 'FIG']))
    end
    if exist(strcat(target_directory,['Raw_Figures' filesep 'EPS']),'file')~=7
        mkdir(strcat(target_directory,['Raw_Figures' filesep 'EPS']))
    end
    if exist(strcat(target_directory,['Raw_Figures' filesep 'PNG']),'file')~=7
        mkdir(strcat(target_directory,['Raw_Figures' filesep 'PNG']))
    end
    if exist(strcat(target_directory,'Edited_Figures'),'file')~=7
        mkdir(strcat(target_directory,'Edited_Figures'))
    end
    if exist(strcat(target_directory,'Output_Data'),'file')~=7
        mkdir(strcat(target_directory,'Output_Data'))
    end
    if exist(strcat(target_directory,'Input_Data'),'file')~=7
        mkdir(strcat(target_directory,'Input_Data'))
    end

    %% save all the custom functions in the analysis to the code folder.
    %Specifically ignore all functions that are part of the Matlab built-in
    %functions or toolboxes
    command_list=[get_user_dependencies(main_function_name);{strcat(mfilename('fullpath'),'.m')}];
    for i=1:length(command_list)
        [SUCCESS,MESSAGE,MESSAGEID] = copyfile(command_list{i},strcat(target_directory,'Code'));
        if SUCCESS
            disp(strcat('successfully copied ',command_list{i},' to the code folder'))
        else
            disp('script copying failed with the following message')
            disp(MESSAGE)
            disp(MESSAGEID)
        end
    end

    %% evaluate the main processing function
    if ~isempty(varargin)
        [figure_list,data_struct]=eval(strcat(main_function_name,'(target_directory,varargin{1})'));
    else
        [figure_list,data_struct]=eval(strcat(main_function_name,'(target_directory)'));
    end
    %% save all the figures
    for i=1:length(figure_list)
        fname=get(figure_list(i),'Name');
        if isempty(fname)
            fname=strcat('Figure_',num2str(i));
        end
        fname(fname==' ')='_';%replace spaces in name for saving
        print('-dpdf',figure_list(i),strcat(target_directory,['Raw_Figures' filesep 'PDF' filesep],fname,'.pdf'))
        print('-deps',figure_list(i),strcat(target_directory,['Raw_Figures' filesep 'EPS' filesep],fname,'.eps'))
        print('-dpng',figure_list(i),strcat(target_directory,['Raw_Figures' filesep 'PNG' filesep],fname,'.png'))
        saveas(figure_list(i),strcat(target_directory,['Raw_Figures' filesep 'FIG' filesep],fname,'.fig'),'fig')
    end

    %% save the input and output data structures
    if ~isempty(varargin)
        temp=varargin{1};
        save(strcat(target_directory,['Input_Data' filesep 'Input_structure.mat']),'temp','-mat')
    end
    fid=fopen(strcat(target_directory,['Input_Data' filesep 'target_directory.txt']),'w+');
            fprintf(fid,'%s',target_directory);
            fclose(fid);
    fid=fopen(strcat(target_directory,['Input_Data' filesep 'main_function_name.txt']),'w+');
            fprintf(fid,'%s',main_function_name);
            fclose(fid);    
    
    data_list=fieldnames(data_struct);
    for i=1:length(data_list)
        temp=getfield(data_struct,data_list{i});
        %if the object is a session summary, write a summary text file
        if strcmp(data_list{i},'session_summary')
            write_session_summary(data_struct.session_summary,strcat(target_directory,['Output_data' filesep ,'session_summary.txt']))
        end
        if ischar(temp)%if the field is just a string like a list of file names
            fid=fopen(strcat(target_directory,['Output_Data' filesep],data_list{i},'.txt'),'w+');
            fprintf(fid,'%s',temp);
            fclose(fid);
        else
            eval([data_list{i} '= data_struct.(data_list{i});'])            
            save(strcat(target_directory,['Output_Data' filesep],data_list{i},'.mat'),data_list{i},'-mat')
            warn_message = lastwarn;
            %% Check to make sure that Matlab saved the data, if not, save as v7.3
            if strfind(warn_message,'Variable ')
                disp('Ignore previous warning, data is being saved')
                dummy_var = [];  % Matlab will compress the first variable saved, making it slower to load, so we compress an empty array.
                save(strcat(target_directory,['Output_Data' filesep],data_list{i},'.mat'),'dummy_var',data_list{i},'-mat','-v7.3')
                lastwarn('')
            end
                    
        end
    end
end
function functionlist=get_user_dependencies(fname)
    %returns a cell array with strings containing the functions that the
    %function fname depends on
    functionlist={};
    command_list=depfun_limblab(fname,'-toponly','-quiet');
    functionlist=command_list(1);
    for i=2:length(command_list)%skip the first element since that is the calling function
        if strfind(command_list{i},matlabroot)
            continue
        else
            temp=get_user_dependencies(command_list{i});
            if isempty(temp)
                functionlist(length(functionlist)+1)=command_list(i);
            else
                functionlist=[functionlist;temp];
            end
        end
    end
end