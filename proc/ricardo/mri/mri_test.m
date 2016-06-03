% datapath = 'H:\DICOM\09070608\38380000\';
clear all
highpath = 'G:\';
% shortpath = 'DICOM\09070609\09420000\';
% shortpath = 'DICOM\10070609\31420000\';
shortpath = 'DICOM\09070608\38380000\';
% new_highpath = 'D:\Data\MRI\Pedro\Test\';
new_highpath = 'D:\Data\MRI\Tiki\Test\';

datapath = [highpath shortpath];

new_datapath = [new_highpath shortpath];

% rotation_angle_trans = 5;
% rotation_angle_sag = -5;
rotation_angle_trans = 5;
rotation_angle_sag = -4.4;
rotation_angle_bl = 24;

filenames = dir(datapath);
filenames = filenames(3:end);
patientName = '4c1-tiki';
seriesno = 3;
metaData = cell(length(filenames)-2,2);

for i = 1:length(filenames)
    filename = filenames(i).name;
    info = dicominfo([datapath filename]);
    metaData{i,1} = info.PatientName.FamilyName;
    metaData{i,2} = info.SeriesTime;
end

studyTimes = unique({metaData{strcmp({metaData{:,1}},patientName),2}});
filenames = filenames(strcmp({metaData{:,1}},patientName) & strcmp({metaData{:,2}},studyTimes(seriesno)));
info = dicominfo([datapath filenames(1).name]);
imageSize = [info.Rows info.Columns];

X = uint16(zeros([imageSize 1 length(filenames)]));

% Read the series of images.
for p=1:length(filenames)
    filename = filenames(p).name;
    X(:,:,1,p) = dicomread([datapath filename]);
    info = dicominfo([datapath filename]);
    minPixels(p) = info.SmallestImagePixelValue;
    maxPixels(p) = info.LargestImagePixelValue;
    slicePos = info.Private_0051_100d;
    % L is positive
    sliceCoord(p) = (-1)^(strcmp(slicePos(4),'L')+1)*str2num(slicePos(5:end));
end

[slice sortInd] = sort(sliceCoord);

X = X(:,:,1,sortInd);

Y = X;
Y_rot = squeeze(Y(:,:,1,:));
clear Y_rot2;
if rotation_angle_trans~=0
    for i = 1:size(X,2)
        Y_rot(:,i,:) = imrotate(squeeze(Y(:,i,1,:)),rotation_angle_trans,'bicubic','crop');
    end
end
% Y_rot = permute(Y_rot,[2 1 3]);

if rotation_angle_sag~=0
    for i = 1:size(X,1)
        Y_rot(i,:,:) = imrotate(squeeze(Y_rot(i,:,:)),rotation_angle_sag,'bicubic','crop');
    end
end

if rotation_angle_bl~=0
    for i = 1:size(X,4)
        Y_rot(:,:,i) = imrotate(squeeze(Y_rot(:,:,i)),rotation_angle_bl,'bicubic','crop');
    end
end

Y_rot2(:,:,1,:) = Y_rot;
Y_rot = Y_rot2;

Y_rot(:,:,1,sortInd) = Y_rot;

if ~exist(new_datapath,'dir')
    eval(['mkdir ' new_datapath]);
end
copyfile([highpath 'DICOMDIR'],new_highpath,'f')

for i=1:length(filenames)
    filename = filenames(i).name;
    info = dicominfo([datapath filename]);
    new_filename = [new_datapath filename];
    dicomwrite(Y_rot(:,:,1,i),new_filename,info);
end

b = min(minPixels);
m = 4*2^16/(max(maxPixels) - b);
Y_rot = imlincomb(double(m), Y_rot, double(-(m * b)), 'uint16');
Y_rot2 = imlincomb(double(m), Y_rot2, double(-(m * b)), 'uint16');
Y = imlincomb(double(m), Y, double(-(m * b)), 'uint16');

X = X/max(max(max(max(X))));
% Display the image stack.
montage(Y_rot,[])
figure; montage(permute(Y_rot2,[4 2 3 1]));
figure; montage(permute(Y_rot2,[1 4 3 2]));
figure; montage(permute(Y,[1 4 3 2]));
% 
figure; imshow(squeeze(Y_rot2(:,128,1,:)));
mri_stereotax = squeeze(Y_rot2);
figure; imshow(squeeze(Y(:,128,1,:)));

