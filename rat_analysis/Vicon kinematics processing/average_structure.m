function out = average_structure(in)

names = fieldnames(in);

for ii = 1:length(names)
    temp = in.(names{ii});
    if strfind(names{ii},'ang')
        c1 = cos(temp'*pi/180);
        c2 = sin(temp'*pi/180);
        out.(names{ii}) = atan2(mean(c2),mean(c1))*180/pi;
    else
        out.(names{ii}) = mean(temp');
    end
end