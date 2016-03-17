function out = normalize_structure(in,nsamp)

names = fieldnames(in);

for ii = 1:length(names)
    temp = in.(names{ii});
    out.(names{ii}) = normalize_cyclesNaN(temp,nsamp);
end
