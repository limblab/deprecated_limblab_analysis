%script to plot the move paths of CO bump data
close all

% %set the mount drive to scan and convert
folderpath_base='E:\processing\CO_bump\CO_bump_training\Dec_5\';
matchstring='Kramer';
% %matchstring2='BC';
disp('converting nev files to bdf format')
file_list=autoconvert_nev_to_bdf(folderpath_base,matchstring);
% autoconvert_nev_to_bdf(folderpath,matchstring2)
disp('concatenating bdfs into single structure')
bdf=concatenate_bdfs_from_folder(folderpath_base,matchstring,0,1,0);
%load('E:\processing\210degstim2\Kramer_BC_03182013_tucker_4ch_stim_001.mat')

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

%make folder to save into:
mkdir(folderpath_base,strcat('Move_paths_',date));
folderpath=strcat(folderpath_base,'Move_paths_',date,'\');
disp('saving new figures and files to:')
disp(folderpath)
fid=fopen(strcat(folderpath,'file_list.txt'),'w+');
fprintf(fid,'%s',file_list);
fclose(fid);

H=plot_move_paths_CO_bump_split2(bdf,'go','pos','center');
set(H,'Position',[100 100 1200 1200])
print('-dpdf',H,strcat(folderpath,'move_paths.pdf'))
H=plot_mean_move_paths_CO_bump2(bdf,'go','pos','center');
set(H,'Position',[100 100 1200 1200])
print('-dpdf',H,strcat(folderpath,'mean_move_paths.pdf'))

close all

 %save the executing script to the same folder as the figures and data

fname=strcat(mfilename('fullpath'),'.m')
[SUCCESS,MESSAGE,MESSAGEID] = copyfile(fname,folderpath);
if SUCCESS
    disp(strcat('successfully copied the running script to the processed data folder'))
else
    disp('script copying failed with the following message')
    disp(MESSAGE)
    disp(MESSAGEID)
end
