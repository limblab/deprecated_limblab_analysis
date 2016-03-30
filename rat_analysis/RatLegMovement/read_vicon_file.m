function markers = read_vicon_file(fname,OPTS,varargin)
% read in a Vicon CSV file as exported from Vicon.  Does some basic
% processing of the file, according to the parameters in OPTS.
%

if nargin == 3  % they sent in information about how to parse the markersets
    DATADESC = varargin{1};
else 
    DATADESC = struct([]);
end

[num,txt,raw_data] = xlsread(fname);
[blocked_data,frames] = find_frameblocks(num,OPTS);
nblocks = length(blocked_data);
allx = []; ally = []; allz = []; allframes = [];
for ii = 1:nblocks
    [x,y,z] = separate_points(blocked_data{ii});
    allx = [allx; x];
    ally = [ally; y];
    allz = [allz; z];   
    allframes = [allframes; frames{ii}];
end
x = allx/OPTS.SCALING;
y = ally/OPTS.SCALING;
z = allz/OPTS.SCALING;


% figure out which markers belong to which set
temp = unique(txt(3,:));  % this is the row that has the marker labels
nentries = length(temp);
subjectlist = {''};
nn = 1;
for jj = 1:nentries  % find the list of different subjects
    if ~isempty(temp{jj})
        subjectname = strtok(temp{jj},':');
        if ~strcmp(subjectlist,subjectname);
            subjectlist{nn} = subjectname;
            subjectind{nn} = [];
            nn = nn +1;
        end
    end
end
nmarkers = nn -1;  % the number of unique labels

if nmarkers == 0
    nmarkers = nentries;  % the number of unique labels
end

if isfield(DATADESC,'MARKERIND')   % this is for when the user has set them from the outside
    for ii = 1:length(DATADESC.MARKERIND)
        subjectind{ii} = DATADESC.MARKERIND{ii};  % this is potentially dangerous as it's assuming that the order given matches the label order
        subjectlist{ii} = DATADESC.MARKERLABEL{ii};  % the name for each of the markersets
    end
else    % this is for figuring them out from the CSV file - for some reason this seems to break down sometimes from VICON    
    nentries = length(txt(3,:));
    for jj = 1:nentries
        temp = txt{3,jj};
        rem = strtok(temp,':');
        ind = find(strcmp(rem,subjectlist));
        if ~isempty(ind)
            subjectind{ind}(end+1) = jj/3;  % divide by 3 to get the index for the marker
            subjectlist{ind} = (rem);
        end
    end
end

for jj = 1:nmarkers
    ind = subjectind{jj};
    markers(jj).name = subjectlist{jj};
    markers(jj).file = fname;
    markers(jj).x = x(:,ind);
    markers(jj).y = y(:,ind);
    markers(jj).z = z(:,ind);
    markers(jj).frames = allframes;    
end

