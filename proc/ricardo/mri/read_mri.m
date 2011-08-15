function mri_mat = read_mri(datapath,patientName,seriesNo)

% datapath = 'G:\DICOM\09070608\38380000\';
% patientName = '4c1-tiki';
% seriesno = 3;

filenames = dir(datapath);
filenames = filenames(3:end);

metaData = cell(length(filenames)-2,2);

for i = 1:length(filenames)
    filename = filenames(i).name;
    info = dicominfo([datapath filename]);
    metaData{i,1} = info.PatientName.FamilyName;
    metaData{i,2} = info.SeriesTime;
end

studyTimes = unique({metaData{strcmp({metaData{:,1}},patientName),2}});
filenames = filenames(strcmp({metaData{:,1}},patientName) & strcmp({metaData{:,2}},studyTimes(seriesNo)));
info = dicominfo([datapath filenames(1).name]);
imageSize = [info.Rows info.Columns];

X = uint16(zeros([imageSize length(filenames)]));

% Read the series of images.
for p=1:length(filenames)
    filename = filenames(p).name;
    X(:,:,p) = dicomread([datapath filename]);
    
    minPixels(p) = info.SmallestImagePixelValue;
    maxPixels(p) = info.LargestImagePixelValue;
%     b = min(minPixels(p));
%     m = 4*2^16/(max(maxPixels(p)) - b);
%     X(:,:,p) = imlincomb(double(m), double(X(:,:,p)), -double(m * b), 'uint16');
    
    info = dicominfo([datapath filename]);
    slicePos = info.Private_0051_100d;
    % L is positive
    if strcmp(slicePos(4),'A')
        slicePos(4) = 'R';
    elseif strcmp(slicePos(4),'P')
        slicePos(4) = 'L';
    end
    sliceCoord(p) = (-1)^(strcmp(slicePos(4),'L')+1)*str2num(slicePos(5:end));
end

[slice sortInd] = sort(sliceCoord);

X = X(:,:,sortInd);
X = permute(X,[1 3 2]);
X = X(end:-1:1,:,:);

b = min(minPixels);
% b = min(min(min(X)));
m = 4*2^16/(max(maxPixels) - b);

% mri_mat = imlincomb(double(m), double(X), -double(m * b), 'uint16');
mri_mat = X;
