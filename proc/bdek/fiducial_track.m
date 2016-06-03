function[handle_cent,distal,medial]= fiducial_track(preimage)

% fiducial_track.m takes an image, finds the two wrist markers and the
% handle, and returns the coordinates for all three.
%
% IF THE PROGRAM IS FAILING OR UNDERPERFORMING:
%     attempt to adjust the parameters bw_thresh, size_thresh, and
%     wrist_marker_ecc. 
%
%         bw_thresh: defines the cutoff luminance for the conversion to
%                    black and white. A higher value will 'keep' only very
%                    luminous regions.  Default is 0.93.
%
%       size_thresh: defines the size cutoff for regions found in black
%                    and white image. A higher value will 'keep' only
%                    larger regions.  Default is 130 (pixels)
%
%  wrist_marker_ecc: defines the lower bound of possible eccentricity for a
%                    wrist marker. A higher value will expect the wrist
%                    markers to have a higher eccentricity (1 being a
%                    perfectly straight line, 0 being a circle).  Default
%                    is 0.95.

%%%%%%%%%%%%%%%%%%%%%%%% ADJUSTABLE PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
bw_thresh = 0.93;
size_thresh = 130;
wrist_marker_ecc = 0.95;
image = imcrop(preimage, [80 0 600 480]); %crop image.  If using track.m, 
        %make sure that the cropping is the same.  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h = fspecial('average',3);
blurred = imfilter(image,h);
    %blur image to help prevent discontinuity in a single marker

img_bw = im2bw(blurred,bw_thresh);
    %convert image to black and white, with given threshold
img_bw = imfill(img_bw,'holes');
img_bw = bwareaopen(img_bw,size_thresh);
    %remove regions in image with size (pixels) less than threshold

[~,L] = bwboundaries(img_bw);
stats = regionprops(L,'all');
    %retrieve properties for regions found with bwboundaries

shapes = [stats.Eccentricity]; %vector of region eccentricities (roundness)
sizes = [stats.Area];          %vector of region sizes
wrist = find(shapes>wrist_marker_ecc);
handle = find(shapes<0.7 & [stats.Area]==max([stats.Area]));

while length(wrist)>2
    wrist(sizes(wrist)==min(sizes(wrist)))=[];
    % if the program finds more than 2 wrist markers, discard the one that
    % is smallest. Repeat this utnil only 2 wrist markers remain.
end

if length(wrist)<2 || isempty(handle)
    handle_cent=0;distal=0;medial=0;
    % if not enough markers are found, set output coordinates to 0.
return
end

[handle_cent] = stats(handle).Centroid;
wrist_1 = stats(wrist(1)).Centroid;
wrist_2 = stats(wrist(2)).Centroid;
    %find the centroid coordinates for the three markers
  
medial_ind = wrist(2-(wrist_1(2) > wrist_2(2)));
distal_ind = wrist(wrist~= medial_ind);
    %determine which wrist marker is distal and which one is medial

distal = stats(distal_ind).Centroid;
medial = stats(medial_ind).Centroid;

