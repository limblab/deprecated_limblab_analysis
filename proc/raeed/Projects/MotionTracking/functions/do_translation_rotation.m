function [ kinect_pos,kinect_pos2 ] = do_translation_rotation( all_medians, all_medians2, R, Tpre, Tpost, plot_flag, times_good, pos_h, colors_xy )

%Puts the kinect markers into handle coordinates

%Inputs:
%R - rotation matrix (to rotate the kinect positions)
%Tpre - translation of the kinect needed prior to rotation
%Tpost - translation of the kinect needed after rotation (to put back in
%handle coordinates)

%Outputs:
%kinect_pos and kinect_pos2 - the kinect marker locations in handle coordinates
%kinect_pos has NaNs for missing markers and kinect_pos2 has the last known
%position for previous markers

%Note that the inputs plot_flag, times_good, pos_h, colors_xy, are all just
%used for making sure this works (via a plot). These can later be removed

%% Put all kinect positions in handle coordinates

%Rename kinect positions
all_medians_v2=all_medians;
all_medians2_v2=all_medians2;

%%X-coordinate of kinect is flipped: unflip it
all_medians_v2(:,1,:)=-all_medians_v2(:,1,:);
all_medians2_v2(:,1,:)=-all_medians2_v2(:,1,:);

%Kinect is in meters, while handle is in cm
all_medians_v2=100*all_medians_v2;
all_medians2_v2=100*all_medians2_v2;

%We need to shift the positions prior to rotation, as we did when finding
%the optimal rotation. We do the same shift here.
shift_matrix=repmat(Tpre,[11,1,n_times]);
all_medians_shift=all_medians_v2-shift_matrix;
all_medians2_shift=all_medians2_v2-shift_matrix;

%These are the matrices with the kinect positions in handle coordinates
kinect_pos=NaN(size(all_medians));
kinect_pos2=NaN(size(all_medians));

%Loop through the markers. For every marker, multiply the sfhited kinect position
%by the rotation matrix.
for m=1:size(all_medians,1)
    m_pos=reshape(all_medians_shift(m,:,:),[3,n_times])';
    kinect_pos(m,:,:)=transpose(m_pos*R);
    m_pos2=reshape(all_medians2_shift(m,:,:),[3,n_times])';
    kinect_pos2(m,:,:)=transpose(m_pos2*R);
end

%Add back in translational difference between handle and kinect (to put
%things in handle coordinates, instead of having mean 0)
diff_matrix=repmat(Tpost,[11,1,n_times]);
kinect_pos=kinect_pos+diff_matrix;
kinect_pos2=kinect_pos2+diff_matrix;

%Possibly flip z-coordinate (since the rotation doesn't know up from down)
%Based on where we put the kinect, the z-coordinate (in handle coordinates) of marker 8 should be positive. Flip z's otherwise.
temp=nanmean(kinect_pos(8,:,:),3);
if temp(3)<0
    kinect_pos(:,3,:)=-kinect_pos(:,3,:);
    kinect_pos2(:,3,:)=-kinect_pos2(:,3,:);
end

%% Another plot test

if plot_flag
    
    figure; scatter3(kinect_pos(3,1,times_good),kinect_pos(3,2,times_good),kinect_pos(3,3,times_good),[],colors_xy,'fill');
    figure; scatter3(pos_h(:,1),pos_h(:,2),pos_h(:,3),[],colors_xy,'fill')
end

end

