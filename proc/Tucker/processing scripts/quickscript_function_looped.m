function [figure_list,data_struct]=quickscript_function_looped(fpath,input_data)
% %quickscript
% 
% %set the mount drive to scan and convert
close all

foldercontents=dir(fpath);
fnames={foldercontents.name};%extracts just the names from the foldercontents
aggregate_bdf = dir([fpath 'Output_data' filesep 'aggregate_bdf.mat']);
if ~isempty(aggregate_bdf)
    warning('quickscript_function_looped:FoundAggregateBDF','Loading aggregate bdf. Remove aggregate_bdf.mat from the folder to load individual files')
    disp(['opening: ' fpath,'Output_data',filesep,aggregate_bdf.name])
    load([fpath,'Output_data',filesep,aggregate_bdf.name])
    bdf=aggregate_bdf;
    clear aggregate_bdf;
else
    file_list={};
    bdf_list={};
    for i=1:length(foldercontents)
        if (length(fnames{i})>3)
            if exist(strcat(fpath,fnames{i}),'file')~=2
                continue
            end
            temppath=follow_links(strcat(fpath,fnames{i}));
            [tempfolder,tempname,tempext]=fileparts(temppath);
            if (strcmp(tempext,'.nev') & ~isempty(strfind(tempname,input_data.matchstring)))
                file_list{end+1}=temppath;
                try
                    disp(strcat('Working on: ',temppath))
                    if isempty(dir( [fpath,filesep,'Output_data',filesep,tempname, '.mat']))
                        %if we haven't found a .mat file to match the .nev then make
                        %one
                        NEVNSx=cerebus2NEVNSx(tempfolder, tempname);
                        bdf=get_nev_mat_data(NEVNSx,'verbose','noeye','noforce','nokin',input_data.labnum);
                        data_struct.(tempname)=bdf;
                        bdf_list{end+1}=bdf;
                    else
                        load([fpath,filesep,'Output_data',filesep,tempname, '.mat']);%loads a variable named bdf from the file
                        eval(['bdf_list{end+1}=',tempname,';']);
                        clear(tempname)
                    end
                catch temperr
                    disp(strcat('Failed to process: ', temppath,filesep,tempname))
                    disp(temperr.identifier)
                    disp(temperr.message)
                    for k=1:length(temperr.stack)
                        disp(['in function: ',temperr.stack(k).name])
                        disp(['on line: ',num2str(temperr.stack(k).line)])
                    end
                end
            end
        end
    end
    if length(bdf_list)==1
        bdf=bdf_list{1};
        clear bdf_list
    else
        for i=1:length(bdf_list)
            if i==1
                %initialize the aggregate bdf
                bdf=bdf_list{i};
            else
                %if our new bdf already has something in it, append to
                %the end of the new bdf
                bdf=concatenate_bdfs(  bdf,   bdf_list{i},    30,     0,   0, 0);%concatenate bdfs with no kinematics, no units and no force
            end
        end
    end
    bdf.meta.task='BC';
end
if ~isfield(bdf,'TT')
    [bdf.TT,bdf.TT_hdr]=bc_trial_table4(bdf);
end
data_struct.aggregate_bdf=bdf;

 H=catch_trials_all(bdf.TT,bdf.TT_hdr,[0,1,2,3],1);
    title('Catch trials: reaching rate to primary target') 
    set(H,'Name','Catch Trials')
    set(H,'Position',[100 100 1200 1200])
    figure_list(1)=H;

[H]=error_rate(bdf.TT,bdf.TT_hdr,[0,1,2,3,4]);
    title('error rate by stim condition') 
    set(H,'Name','error rate by stim condition')
    set(H,'Position',[100 100 1200 1200])
    figure_list(length(figure_list)+1)=H;

[H]=error_rate_aggregate(bdf.TT,bdf.TT_hdr);
    title('error rate Stim vs No-stim') 
    set(H,'Name','error rate Stim vs No-stim')
    set(H,'Position',[100 100 1200 1200])
    figure_list(length(figure_list)+1)=H;

    %get number of stim directions
    for i=1:input_data.num_stim_cases
        %new fitting plus inverting the y axis of the sigmoid
        [fitdata,H_cartesian] =  bc_psychometric_curve_stim8(bdf.TT,bdf.TT_hdr,input_data.stimcodes(i),1);
        data_struct.(strcat('fit_data_',num2str(input_data.currents(i)),'uA'))=fitdata;
        temp=[fitdata.dirs_stim,fitdata.proportion_stim,fitdata.number_reaches_stim,ones(length(fitdata.dirs_stim),1);fitdata.dirs_no_stim,fitdata.proportion_no_stim,fitdata.number_reaches_no_stim,zeros(length(fitdata.dirs_no_stim),1)];
        str=num2str(input_data.currents(i));
        str0=num2str(0);
        data_struct.(strcat('reach_data_',str))=temp;
        figure(H_cartesian)
        set(H_cartesian,'Position',[100 100 1200 1200])
        title_handle=title(['\fontsize{14}','Psychometric cartesian ',str,'\muA inverted','\newline',...
                '\fontsize{10}',str,'\muA:0-180, min=',num2str(fitdata.g_stim_lower(1)),', max=',num2str(fitdata.g_stim_lower(2)),', PSE=',num2str(fitdata.g_stim_lower(3)),', \tau=',num2str(fitdata.g_stim_lower(4)),'\newline',...
                str,'\muA:180-360, min=',num2str(fitdata.g_stim_upper(1)),', max=',num2str(fitdata.g_stim_upper(2)),', PSE=',num2str(fitdata.g_stim_upper(3)),', \tau=',num2str(fitdata.g_stim_upper(4)),'\newline',...
                str0,'\muA:0-180, min=',num2str(fitdata.g_no_stim_lower(1)),', max=',num2str(fitdata.g_no_stim_lower(2)),', PSE=',num2str(fitdata.g_no_stim_lower(3)),', \tau=',num2str(fitdata.g_no_stim_lower(4)),'\newline',...
                str0,'\muA:180-360, min=',num2str(fitdata.g_no_stim_upper(1)),', max=',num2str(fitdata.g_no_stim_upper(2)),', PSE=',num2str(fitdata.g_no_stim_upper(3)),', \tau=',num2str(fitdata.g_no_stim_upper(4))]);
        set(title_handle,'interpreter','tex')
        set(H_cartesian,'Name',strcat('Psychometric cartesian ',str,'uA inverted'))
        figure_list(length(figure_list)+1)=H_cartesian;

        %new fitting plus inverting the y axis of the sigmoid and folding into a
        %single hemispace
        [fitdata,H_cartesian] =  bc_psychometric_curve_stim8_compressed(bdf.TT,bdf.TT_hdr,input_data.stimcodes(i),1);
        temp=[fitdata.dirs_stim,fitdata.proportion_stim,fitdata.number_reaches_stim,ones(length(fitdata.dirs_stim),1);fitdata.dirs_no_stim,fitdata.proportion_no_stim,fitdata.number_reaches_no_stim,zeros(length(fitdata.dirs_no_stim),1)];
        data_struct.(strcat('reach_data_compressed_',str))=temp;
        figure(H_cartesian)
        set(H_cartesian,'Position',[100 100 1200 1200])
        title_handle=title(['\fontsize{14}','Psychometric cartesian ',str,'\muA, inverted compressed','\newline',...
                '\fontsize{10}',str,'\muA', 'min=',num2str(fitdata.g_stim(1)),', max=',num2str(fitdata.g_stim(2)),', PSE=',num2str(fitdata.g_stim(3)),', \tau=',num2str(fitdata.g_stim(4)),'\newline',...
                str0,'\muA, min=',num2str(fitdata.g_no_stim(1)),', max=',num2str(fitdata.g_no_stim(2)),', PSE=',num2str(fitdata.g_no_stim(3)),', \tau=',num2str(fitdata.g_no_stim(4))]);
        set(title_handle,'interpreter','tex')

        set(H_cartesian,'Name',strcat('Psychometric cartesian ',str,'uA inverted compressed'))
        figure_list(length(figure_list)+1)=H_cartesian;
    end
    
        data_struct.(strcat('fit_data_',str0))=fitdata;