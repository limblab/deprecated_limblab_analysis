function track(open_path,beg_num,end_num,extension,save_path)

%track.m takes an image sequence from an unprocessed video and saves an 
%image sequence including fiducial markers to save_path
table = zeros(end_num-beg_num+1,6);

for i = beg_num:end_num
   %prec_zeros = repmat('0',1,3-length(int2str(i)));
    img = imread([open_path int2str(i)],extension);
    [a,b,c] = fiducial_track(img);
    table(i-beg_num+1,:)= [a b c];
    clear img; clear a; clear b; clear c;
end

[~,adj_table] = adj_dist_fiduc(table);

for i = beg_num:end_num
   %prec_zeros = repmat('0',1,3-length(int2str(i)));
    img = imread([open_path int2str(i)],extension);
    heldimage = imcrop(img, [80 0 600 480]);
%%%%%%% MAKE SURE CROPPING IS THE SAME AS IN FIDUCIAL_TRACK.M
    
    imshow(heldimage); hold on;
    
    if table((i-beg_num+1),1)~=0    
        h = imline(gca,[adj_table(i-beg_num+1,1) adj_table(i-beg_num+1,3)],...
            [adj_table(i-beg_num+1,2) adj_table(i-beg_num+1,4)]);
        h2 = imline(gca,[adj_table(i-beg_num+1,3) adj_table(i-beg_num+1,5)],...
            [adj_table(i-beg_num+1,4) adj_table(i-beg_num+1,6)]);
        setColor(h,[1 0 0]); setColor(h2, [1 0 0]);
    end
    saveas(gcf,[save_path int2str(i)], 'jpg');
    clear img; clear a; clear b; clear c; clear angle;
    close all; clc;
end
    