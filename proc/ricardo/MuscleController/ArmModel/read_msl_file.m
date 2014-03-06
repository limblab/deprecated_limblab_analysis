function muscles = read_msl_file(filename)
% CREATE A MATLAB STRUCTURE FROM THE SIMM MUSCLE FILE
% 
% Loads SIMM .msl files
% 
% Sherwin Chan  3/28/2005
% last edited:  3/28/2005 SSC
%

if ~strcmp(filename(end-2:end),'msl')
    error('File is likely not a muscle file, please check the input filename.');
end

Path = 'C:\Documents and Settings\Sherwin Chan\My Documents\Moran Lab\Data and Work\SIMM - 2004\Frank\';
full_filename = [Path filename];
num_max_muscles = 40;
i = 1;

if (exist(full_filename))
    fid = fopen(full_filename,'r');
    
    while i<num_max_muscles
        line = fgetl(fid);
        while strncmp(line,'/*',2)
            line = fgetl(fid);
        end
        if (strncmp(line,'beginmuscle',11))
            muscles(i).par.name = sscanf(line(13:end),'%s');
            muscles(i).var.length = 0;
            muscles(i).var.velocity = 0;
            muscles(i).var.torq = zeros(7,1);
            muscles(i).var.force = 0;
            muscles(i).var.reaction_load = 0;
            muscles(i).var.stress = 0;
            
        elseif (strncmp(line,'max_force',9))
            muscles(i).par.max_force = sscanf(line(10:end),'%f');
            
        elseif (strncmp(line,'optimal_fiber_length',20))
            muscles(i).par.opt_fib_len = sscanf(line(21:end),'%f');
            
        elseif (strncmp(line,'tendon_slack_length',19))
            muscles(i).par.ten_slack_len = sscanf(line(20:end),'%f');
            
        elseif (strncmp(line,'pennation_angle',15))
            muscles(i).par.pen_angle = sscanf(line(16:end),'%f');

        elseif (strncmp(line,'beginpoints',11))
            point = 1;
            line = fgetl(fid);
            while strncmp(line,'/*',2)
                line = fgetl(fid);
            end
            while ~strncmp(line,'endpoints',9)
                line_in = sscanf(line,'%f %f %f %s %s');
                % Need to convert units from mm in SIMM to m in MATLAB
                muscles(i).par.point(point).coord(1:3) = line_in(1:3) / 1000;
                segment = char(line_in(11:end)');
                muscles(i).par.point(point).seg = segment;
                line_in = sscanf(line,'%f %f %f %s %s %s %d %s');
                viapts = line_in(11+size(segment,2):end);
                if viapts
                    rangeangle = char(viapts(8:end)');
                    if strcmp(rangeangle,'shoulder_adduction')
                        muscles(i).par.point(point).rangeangle = 'Shoulder Adduction';
                    elseif strcmp(rangeangle,'shoulder_internal_rotation')
                        muscles(i).par.point(point).rangeangle = 'Shoulder Internal Rotation';
                    elseif strcmp(rangeangle,'shoulder_flexion')
                        muscles(i).par.point(point).rangeangle = 'Shoulder Flexion';
                    elseif strcmp(rangeangle,'elbow_flexion')
                        muscles(i).par.point(point).rangeangle = 'Elbow Flexion';
                    elseif strcmp(rangeangle,'radial_pronation')
                        muscles(i).par.point(point).rangeangle = 'Pronation';
                    elseif strcmp(rangeangle,'wrist_flexion')
                        muscles(i).par.point(point).rangeangle = 'Wrist Flexion';
                    elseif strcmp(rangeangle,'wrist_abduction')
                        muscles(i).par.point(point).rangeangle = 'Wrist Abduction';
                    end
                    line_in = sscanf(line,'%f %f %f %s %s %s %d %s %s %f %s %f');
                    muscles(i).par.point(point).range(1) = line_in(end-2);
                    muscles(i).par.point(point).range(2) = line_in(end);
                else
                    muscles(i).par.point(point).range = [];
                end
                point = point+1;
                line = fgetl(fid);
                while strncmp(line,'/*',2)
                    line = fgetl(fid);
                end
            end
                
        elseif (strncmp(line,'endmuscle',9))
            if ~strcmp(muscles(i).par.name, 'defaultmuscle')
                i = i + 1;
            end
            
        elseif ~isstr(line)
            break;
        end
    end % end while
    fclose(fid);
end % if exist
