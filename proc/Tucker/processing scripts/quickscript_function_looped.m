function [figure_list,data_struct]=quickscript_function(fpath,input_data)
% %quickscript
% 
% %set the mount drive to scan and convert
close all

foldercontents=dir(fpath);
fnames={foldercontents.name};%extracts just the names from the foldercontents
aggregate_bdf = dir([fpath filesep 'Output_data' filesep 'aggregate_bdf.mat']);
if ~isempty(aggregate_bdf)
    warning('quickscript_function_looped:FoundAggregateBDF','Loading aggregate bdf. Remove aggregate_bdf.mat from the folder to load individual files')
    load([fpath,'Output_data',filesep,aggregate_bdf.name])
    bdf=aggregate_bdf;
    clear aggregate_bdf;
end
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
bdf=make_tdf_function(bdf);
data_struct.aggregate_bdf=bdf;

 H=catch_trials_all(bdf.TT,bdf.TT_hdr,[0,1,2,3],1);
    title('Catch trials: reaching rate to secondary target') 
    set(H,'Name','Catch Trials')
    figure_list(1)=H;

[H]=error_rate(bdf.TT,bdf.TT_hdr,[0,1,2,3,4]);
    title('error rate by stim condition') 
    set(H,'Name','error rate by stim condition')
    figure_list(length(figure_list)+1)=H;

[H]=error_rate_aggregate(bdf.TT,bdf.TT_hdr);
    title('error rate Stim vs No-stim') 
    set(H,'Name','error rate Stim vs No-stim')
    figure_list(length(figure_list)+1)=H;

    %get number of stim directions
    for i=1:input_data.num_stim_cases
        %new fitting plus inverting the y axis of the sigmoid
        [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian] =  bc_psychometric_curve_stim6(bdf.TT,bdf.TT_hdr,input_data.stimcodes(i),1);
        temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
        str=strcat(num2str(input_data.currents(i)),'uA');
        data_struct.(strcat('reach_data_',str))=temp;
        figure(H_cartesian)
            title(strcat('Psychometric cartesian ',str,' inverted'))
            set(H_cartesian,'Name',strcat('Psychometric cartesian ',str,' inverted'))
            figure_list(length(figure_list)+1)=H_cartesian;

        %new fitting plus inverting the y axis of the sigmoid and folding into a
        %single hemispace
        [dirs_stim,proportion_stim,number_reaches_stim,dirs_no_stim,proportion_no_stim,number_reaches_no_stim,H_cartesian] =  bc_psychometric_curve_stim6_compressed(bdf.TT,bdf.TT_hdr,input_data.stimcodes(i),1);
        temp=[dirs_stim,proportion_stim,number_reaches_stim,ones(length(dirs_stim),1);dirs_no_stim,proportion_no_stim,number_reaches_no_stim,zeros(length(dirs_no_stim),1)];
        data_struct.(strcat('reach_data_compressed_',str))=temp;
        figure(H_cartesian)
            title(strcat('Psychometric cartesian ',str,' inverted compressed'))
            set(H_cartesian,'Name',strcat('Psychometric cartesian ',str,' inverted compressed'))
            figure_list(length(figure_list)+1)=H_cartesian;
    end
