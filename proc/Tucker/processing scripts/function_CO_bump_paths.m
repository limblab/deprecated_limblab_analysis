function [figure_list,data_struct]=function_CO_bump_paths(folderpath_base)%script to plot the move paths of CO bump data
close all
figure_list=[];
%% process and load raw data into bdf


matchstring='Kramer';
disp('converting nev files to bdf format')
[file_list,bdf_list]=autoconvert_nev_to_bdf_listreturn(folderpath_base,matchstring,6);

bdf=[];
for i=1:length(bdf_list)
    [tempfolder,tempname,tempext]=fileparts(file_list{i});
    
    data_struct.(tempname)=bdf_list{i};
    if isempty(bdf)
        %if our new bdf is empty start it
        bdf=bdf_list{i};
        data_struct.file_list=strcat(tempname);
    else
        bdf=concatenate_bdfs(  bdf,   bdf_list{i},    30,     do_units,   do_kin, do_force);
        data_struct.file_list=strcat(',',tempname);
    end
end

%% convert bdf into tdf

[bdf.tt,bdf.tt_hdr]=CO_bump_trial_table(bdf);
%[bdf.tt,bdf.tt_hdr]=rw_trial_table_hdr(bdf);

ts = 50;
offset=-0.015; %a positive offset compensates for neural data leading kinematic data, a negative offset compensates for a kinematic lead

if isfield(bdf,'units')
    vt = bdf.vel(:,1);
    t = vt(1):ts/1000:vt(end);

    for i=1:length(bdf.units)
        if isempty(bdf.units(i).id)
            %bdf.units(unit).id=[];
        else
            spike_times = bdf.units(i).ts+ offset;%the offset here will effectively align the firing rate to the kinematic data
            spike_times = spike_times(spike_times>t(1) & spike_times<t(end));
            bdf.units(i).fr = [t;train2bins(spike_times, t)]';
        end
    end
end

data_struct.Full_bdf=bdf;
%% generate plots
H=plot_move_paths_CO_bump_split2(bdf,'go','pos','center');
format_for_lee(H)
set(H,'Position',[100 100 1200 1200])
set(H,'Name','All_Move_Paths')
figure_list(end+1)=H;
H=plot_mean_move_paths_CO_bump2(bdf,'go','pos','center');
format_for_lee(H)
set(H,'Position',[100 100 1200 1200])
set(H,'Name','Mean_Move_Paths')
figure_list(end+1)=H;


