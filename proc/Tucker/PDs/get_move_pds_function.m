function [figure_list,data_struct]=get_move_pds_function(folderpath,input_data)
close all
%%set params
    ts = 50;%binning size
    offset=-0.015; %a positive offset compensates for neural data leading kinematic data, a negative offset compensates for a kinematic lead

    %load data
    %check to see if a bdf already exists:
    folderlist=dir(strcat(folderpath,'\Output_data'));
    fnames={folderlist.name};
    if ~isempty(strmatch( 'bdf.mat',fnames))
        temp=load(strcat( folderpath,'\Output_data\bdf.mat'));
        if isfield(temp,'temp')
            bdf=temp.temp;
        elseif isfield(temp,'bdf')
            bdf=temp.bdf;
        else
            fname=follow_links([folderpath,input_data.filename]);
            disp(strcat('converting: ',fname))
            bdf=get_cerebus_data(fname,input_data.labnum,'verbose','noeye');
        end
    else
        fname=follow_links([folderpath,input_data.filename]);
        disp(strcat('converting: ',fname))
        bdf=get_cerebus_data(fname,input_data.labnum,'verbose','noeye');
    end


    
    %make single and multi unit data sets
    bdf_multiunit=remove_sorting(bdf);
    bdf_multiunit=testAllTuning(bdf_multiunit);
    data_struct.Multi_unit_bdf=bdf_multiunit;
    temp=[];
    for i=1:length(bdf.units)
        if (bdf.units(1,i).id(2)==0 | bdf.units(1,i).id(2)==255)
            continue
        else
            temp(1,length(temp)+1).id=bdf.units(1,i).id;
            temp(1,length(temp)).ts=bdf.units(1,i).ts;
        end
    end
    bdf.units=temp;
    
    bdf=testAllTuning(bdf);
    
    data_struct.bdf=bdf;

    %compute PDs for single units
    disp('computing single unit PDs and plotting results')
    array_map_path=input_data.array_map_path;
    [outdata,H_upper,H_lower,H_PD_mag,H_PD_hist,H_PD_CI_hist]=PD_plot(bdf,array_map_path,1,1);
    data_struct.Single_unit_PD_data=outdata;
    
    set(H_upper,'Name','Single_unit_Upper_half')
    set(H_lower,'Name','Single_unit_Lower_half')
    set(H_PD_mag,'Name','Single_unit_PD_magnitude_histogram')
    set(H_PD_hist,'Name','Single_unit_PD_histogram')
    set(H_PD_CI_hist,'Name','Single_unit_PD_CI_histogram')
            
    set(H_upper,'Position',[100 100 1200 1200])
    set(H_lower,'Position',[100 100 1200 1200])
    figure_list(1)=H_upper;
    figure_list(2)=H_lower;
    figure_list(3)=H_PD_mag;
    figure_list(4)=H_PD_hist;
    figure_list(5)=H_PD_CI_hist;
     
    %re-measure PDs for multiunits
    [outdata,H_upper,H_lower,H_PD_mag,H_PD_hist,H_PD_CI_hist]=PD_plot(bdf_multiunit,array_map_path,2,1);
    data_struct.Multi_unit_PD_data=outdata;
    
    pds=outdata([bdf_multiunit.units(:).tuned]',:);
    pds=pds(pds(:,1)<97,:);
    pds=pds(pds(:,3)<1,:);
    pds=sortrows(pds,2);
    data_struct.Tuned_Multi_unit_PD_data=pds;

    set(H_upper,'Name','Multi_unit_Upper_half')
    set(H_lower,'Name','Multi_unit_Lower_half')
    set(H_PD_mag,'Name','Multi_unit_PD_magnitude_histogram')
    set(H_PD_hist,'Name','Multi_unit_PD_histogram')
    set(H_PD_CI_hist,'Name','Multi_unit_PD_CI_histogram')
            
    set(H_upper,'Position',[100 100 1200 1200])
    set(H_lower,'Position',[100 100 1200 1200])
    figure_list(6)=H_upper;
    figure_list(7)=H_lower;
    figure_list(8)=H_PD_mag;
    figure_list(9)=H_PD_hist;
    figure_list(10)=H_PD_CI_hist;
end
    
