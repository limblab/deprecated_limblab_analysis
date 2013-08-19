function impedances=get_impedance_data(filename,channeltag)
    %accepts a file name as a string. filename should include full folder
    %path to avoid undefined behavior also accepts a string which will be
    %used to locate the channel number in the input strings. By default
    %this will probably be 'elec' in your data file unless you changed the
    %channel names deliberately
    
    fid=fopen(filename,'r');
    imp_text = char(fread(fid,inf,'char'))';
    fclose(fid);
    last_asterisk = strfind(imp_text,'*');
    last_asterisk = last_asterisk(end);
    imp_text = imp_text(last_asterisk+1:end);
    imp_text = regexp(imp_text,'\n','split');
    impedances = -1*ones(numel(imp_text),1); %leave a -1 in each unfilled position
    for i = 1:size(imp_text,2);
        channel_pos=strfind(imp_text{i},channeltag);
        if ~isempty(channel_pos)%if we found the channel label in the current line
            elec_num=str2num(   imp_text{i}(    (channel_pos+4):(channel_pos+6)  ) );%parse out the actual number
            ohmpos=strfind(imp_text{i},'Ohm');%find the position of the impedance unit label
            if ~isempty(ohmpos)%if the label actually was for impedance not voltage or something
                impedances(elec_num)=str2num(imp_text{i}(ohmpos-9:ohmpos-2));%set the impedance value
            end
        end
        
    end
end