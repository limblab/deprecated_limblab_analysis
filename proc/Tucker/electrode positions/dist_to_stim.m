function  [min_dist,mean_dist,dist]=dist_to_stim(e_pos,stim_list)
    %takes in an electrode positions object, and a list of stimulated
    %electrodes and returns, the minimum distnace, mean distance and all
    %distances to the electrodes in the stim list, for every electrode in
    %the electrode positions object.
    dist=-1*ones(length(e_pos.position.electrode),1);
    for i=1:length(stim_list)
        temp=[e_pos.position.shank_pos(:),e_pos.position.depth_pos(:),e_pos.position.bank_pos(:)];
        temp2=repmat([e_pos.position.shank_pos(stim_list(i)),e_pos.position.depth_pos(stim_list(i)),e_pos.position.bank_pos(stim_list(i))],length(e_pos.position.electrode),1);
        dist(:,i)=sqrt(sum((temp-temp2).^2,2));
    end
    min_dist=min(dist,[],2);
    mean_dist=mean(dist,2);
end