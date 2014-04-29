function [figure_list,data_struct]=get_move_pds_function(folderpath,input_data)

%%set params
    ts = 50;%binning size
    offset=-0.015; %a positive offset compensates for neural data leading kinematic data, a negative offset compensates for a kinematic lead

    %load data
    fname=follow_links([folderpath,input_data.filename]);
    disp(strcat('converting: ',fname))
    foldercontents=dir(strcat(folderpath,'Output_Data\'));
    fnames={foldercontents.name};%extracts just the names from the foldercontents
    if ~isempty(strmatch( 'bdf.mat',fnames))
        temp=load(strcat( folderpath,'Output_data\bdf.mat'));
        bdf=temp.temp;
        clear temp
    else
        bdf=get_cerebus_data(fname,3,'verbose','noeye');
    end
    data_struct.bdf=bdf;

    %identify time vector for binning
    vt = bdf.vel(:,1);
    t = vt(1):ts/1000:vt(end);

    disp('computing PDs and plotting results')
    array_map_path='C:\Users\limblab\Desktop\kramer_array_map\6251-0922.cmp';
    [outdata,H_upper,H_lower]=PD_plot(bdf,array_map_path,2,1);
    data_struct.PD_data=outdata;
    
      set(H_upper,'Name','Upper_half')
      set(H_lower,'Name','Lower_half')
      set(H_upper,'Position',[100 100 1200 1200])
      set(H_lower,'Position',[100 100 1200 1200])
     figure_list(1)=H_upper;
     figure_list(2)=H_lower;
end
    
