function [fhcal,rotcal,Fy_invert]=getLabParams(labnum,datetime,rothandle)
    %wrapper function to contain the logic that selects load cell calibrations
    %and rotation data. Intended for use when converting robot handle load cell
    %data from raw form into room coordinates. Provides load cell calibration
    %matrices, rotation matrices, and a variable used to invert the y axis in
    %the case of data where the load cell was installed upside down. This
    %function is called when preprocessing data as it is loaded into
    %matlab. It is not intended for end user use.
    %
    %Each lab with a robot should have a block dedicated to it
    %every time the lab 
    if labnum==3 %If lab3 was used for data collection
        % Check date of recording to see if it's before or after the
        % change to force handle mounting.
        if datenum(datetime) < datenum('5/27/2010')            
            fhcal = [ 0.1019 -3.4543 -0.0527 -3.2162 -0.1124  6.6517; ...
                     -0.1589  5.6843 -0.0913 -5.8614  0.0059  0.1503]';
            rotcal = [0.8540 -0.5202; 0.5202 0.8540];                
            Fy_invert = -1; % old force setup was left hand coordnates.
        elseif datenum(datetime) < datenum('6/28/2011')
            fhcal = [0.0039 0.0070 -0.0925 -5.7945 -0.1015  5.7592; ...
                    -0.1895 6.6519 -0.0505 -3.3328  0.0687 -3.3321]';
            rotcal = [1 0; 0 1];                
            Fy_invert = 1;
        else
            % Fx,Fy,scaleX,scaleY from ATI calibration file:
            % \\citadel\limblab\Software\ATI FT\Calibration\Lab 3\FT7520.cal
            % fhcal = [Fx;Fy]./[scaleX;scaleY]
            % force_offsets acquired empirically by recording static
            % handle.
            fhcal = [-0.0129 0.0254 -0.1018 -6.2876 -0.1127 6.2163;...
                    -0.2059 7.1801 -0.0804 -3.5910 0.0641 -3.6077]'./1000;
            
            Fy_invert = 1;
            if rothandle
                rotcal = [-1 0; 0 1];  
            else
                rotcal = [1 0; 0 1];  
            end
        end
    elseif labnum==2 %if lab2 was used for data collection
        warning('calc_from_raw_script:Lab2LoadCellCalibration','No one noted what the calibration for the Lab2 robot was, so this processing assumes the same parameters as the original LAB3 values. THE FORCE VALUES RESULTING FROM THIS ANALYSIS MAY BE WRONG!!!!!!!!!!!!!!')
        if datenum(datetime) < datenum('5/27/2010')            
            fhcal = [ 0.1019 -3.4543 -0.0527 -3.2162 -0.1124  6.6517; ...
                     -0.1589  5.6843 -0.0913 -5.8614  0.0059  0.1503]';
            rotcal = [0.8540 -0.5202; 0.5202 0.8540];                
            Fy_invert = -1; % old force setup was left hand coordnates.
        elseif datenum(out_struct.meta.datetime) < datenum('6/28/2011')
            fhcal = [0.0039 0.0070 -0.0925 -5.7945 -0.1015  5.7592; ...
                    -0.1895 6.6519 -0.0505 -3.3328  0.0687 -3.3321]';
            rotcal = [1 0; 0 1];                
            Fy_invert = 1;
        elseif rothandle
            %included this section for consistency. Old Lab2 files 
            %would never have used a rotated handle
            error('calc_from_raw_script:Lab2RotHandle','the rotate handle option was never used in Lab2. If lab2 has been updated with a loadcell and you are using the handle in a rotated position you need to modify raw2handleforce to reflect this')
        end
    elseif labnum==6 %If lab6 was used for data collection
        % Fx,Fy,scaleX,scaleY from ATI calibration file:
        % \\citadel\limblab\Software\ATI FT\Calibration\Lab 6\FT16018.cal
        % fhcal = [Fx;Fy]./[scaleX;scaleY]
        % force_offsets acquired empirically by recording static
        % handle.
        fhcal = [0.02653 0.02045 -0.10720 5.94762 0.20011 -6.12048;...
                0.15156 -7.60870 0.05471 3.55688 -0.09915 3.44508]'./1000;
        Fy_invert = 1;    
        if rothandle
            rotcal = [-1 0; 0 1];  
        else
            rotcal = [1 0; 0 1];  
        end
    else
        error('getLabParams:BadLab',['lab: ',labnum,' is not configured properly']);
    end
end