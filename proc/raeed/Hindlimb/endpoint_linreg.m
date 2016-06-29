%% plot neural firing rates against length and orientation
figure
for i = 1:length(neurons)
%     plot3(x1,x2,activity_unc(i,:),'bo',x1,x2,activity_con(i,:),'r+')
        plot3(zerod_ep(:,1),zerod_ep(:,2),activity_unc(i,:),'bo',zerod_ep(:,1),zerod_ep(:,2),activity_con(i,:),'r+')

%     mesh(rsg,asg,reshape(activity_unc(i,:),[10,10]))
    hold on;
%     mesh(rsg,asg,reshape(activity_con(i,:),[10,10]))
    
%     unc_plane = predict(pol_fit_unc{i},[x1' x2']);
%     con_plane = predict(pol_fit_con{i},[x1' x2']);

    [mesh_thingx, mesh_thingy] = meshgrid(linspace(-12,12,10),linspace(-4,5,10));
    
    unc_plane = predict(cart_fit_unc{i},[mesh_thingx(:), mesh_thingy(:)]);
    con_plane = predict(cart_fit_con{i},[mesh_thingx(:), mesh_thingy(:)]);
    
%     mesh(rsg,asg,reshape(unc_plane,[10 10]))
%     mesh(rsg,asg,reshape(con_plane,[10 10]))

    mesh(linspace(-12,12,10),linspace(-4,5,10),reshape(unc_plane,[10 10]))
    mesh(linspace(-12,12,10),linspace(-4,5,10),reshape(con_plane,[10 10]))

    hold off;
    grid on;
    axis equal;
    axis square;
%     while(waitforbuttonpress~=1)
%     end
end