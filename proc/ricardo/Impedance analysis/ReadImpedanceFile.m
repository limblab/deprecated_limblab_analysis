
function electrodes = ReadImpedanceFile(filename)
fid = fopen(filename);

tline = fgetl(fid);
electrode_number = 0;
while ischar(tline)
    if tline(1)~='*' && isempty(strfind(tline,'elec'))
        electrode_number = electrode_number+1;
%         disp(tline);  
        electrodes(electrode_number).id = tline(5:7);
        electrodes(electrode_number).impedance = str2double(tline(8:15));
    end
    tline = fgetl(fid);
end

fclose(fid);