addpath('C:\Users\Nicholas Sachs\Lab Code\s1_analysis\proc\boubker\PDs');
filePDs = PDs_from_spikes('C:\Users\Nicholas Sachs\Desktop\temporary work files\SD Data\Chewie_Spike_02202012008-sorted',18,32,0,-0.25,0.2,0.05);

PDs = filePDs{1,1};
PDs(:,13) = [1:length(PDs)]';
sortedPDs = sortrows(PDs,4);

bins = round(movement_decoder.fillen/movement_decoder.binsize);

    for x = 1:length(movement_decoder.H)
        move_weights_x(ceil(x/bins),round(mod(x,bins)) + 1) = double(movement_decoder.H(x,1));
        post_weights_x(ceil(x/bins),round(mod(x,bins)) + 1) = double(posture_decoder.H(x,1));
        move_weights_y(ceil(x/bins),round(mod(x,bins)) + 1) = double(movement_decoder.H(x,2));
        post_weights_y(ceil(x/bins),round(mod(x,bins)) + 1) = double(posture_decoder.H(x,2));
    end

    for x = 1:length(movement_decoder.H)
        scale_move_weights_x(ceil(x/bins),round(mod(x,bins)) + 1) = double(movement_decoder.H(x,1)*mean(binnedData.spikeratedata(:,ceil(x/bins))));
        scale_post_weights_x(ceil(x/bins),round(mod(x,bins)) + 1) = double(posture_decoder.H(x,1)*mean(binnedData.spikeratedata(:,ceil(x/bins))));
        scale_move_weights_y(ceil(x/bins),round(mod(x,bins)) + 1) = double(movement_decoder.H(x,2)*mean(binnedData.spikeratedata(:,ceil(x/bins))));
        scale_post_weights_y(ceil(x/bins),round(mod(x,bins)) + 1) = double(posture_decoder.H(x,2)*mean(binnedData.spikeratedata(:,ceil(x/bins))));
    end

    for x = 1:length(movement_decoder.H)
        move_speed_weights(ceil(x/bins),round(mod(x,bins)) + 1) = sqrt(move_weights_x(ceil(x/bins),round(mod(x,bins)) + 1)^2 + move_weights_y(ceil(x/bins),round(mod(x,bins)) + 1)^2);
        post_speed_weights(ceil(x/bins),round(mod(x,bins)) + 1) = sqrt(post_weights_x(ceil(x/bins),round(mod(x,bins)) + 1)^2 + post_weights_y(ceil(x/bins),round(mod(x,bins)) + 1)^2);
        scale_move_speed_weights(ceil(x/bins),round(mod(x,bins)) + 1) = sqrt(scale_move_weights_x(ceil(x/bins),round(mod(x,bins)) + 1)^2 + scale_move_weights_y(ceil(x/bins),round(mod(x,bins)) + 1)^2);
        scale_post_speed_weights(ceil(x/bins),round(mod(x,bins)) + 1) = sqrt(scale_post_weights_x(ceil(x/bins),round(mod(x,bins)) + 1)^2 + scale_post_weights_y(ceil(x/bins),round(mod(x,bins)) + 1)^2);
    end
    
    figure;

    subplot(1,2,1)
    surf([move_speed_weights zeros(size(move_speed_weights,1),1); zeros(1,size(move_speed_weights,2) + 1)])
%     surf([move_speed_weights(sortedPDs(:,13),:) zeros(size(move_speed_weights,1),1); zeros(1,size(move_speed_weights,2) + 1)])
    axis([1 size(move_speed_weights,2)+1 1 size(move_speed_weights,1)+1 -max(max(abs(move_speed_weights))) max(max(abs(move_speed_weights)))])
    caxis([0 max(max(abs(move_speed_weights)))])
    colorbar
    title('Movement Filter')
    ylabel('Unit')
    xlabel('Bin')
    view([0 90])

    subplot(1,2,2)
    surf([post_speed_weights zeros(size(post_speed_weights,1),1); zeros(1,size(post_speed_weights,2) + 1)])
%     surf([post_speed_weights(sortedPDs(:,13),:) zeros(size(post_speed_weights,1),1); zeros(1,size(post_speed_weights,2) + 1)])
    axis([1 size(post_speed_weights,2)+1 1 size(post_speed_weights,1)+1 -max(max(abs(post_speed_weights))) max(max(abs(post_speed_weights)))])
    caxis([0 max(max(abs(post_speed_weights)))])
    colorbar
    title('Posture Filter')
    ylabel('Unit')
    xlabel('Bin')
    view([0 90])
    
    figure
    plot(mean(post_speed_weights,1),'r')
    hold on
    plot(mean(move_speed_weights,1),'b')
          

    figure;

    subplot(1,3,1)
%     surf([scale_move_speed_weights zeros(size(scale_move_speed_weights,1),1); zeros(1,size(scale_move_speed_weights,2) + 1)])
    surf([scale_move_speed_weights(sortedPDs(:,13),:) zeros(size(scale_move_speed_weights,1),1); zeros(1,size(scale_move_speed_weights,2) + 1)])
    axis([1 size(scale_move_speed_weights,2)+1 1 size(scale_move_speed_weights,1)+1 -max(max(abs(scale_move_speed_weights))) max(max(abs(scale_move_speed_weights)))])
    caxis([0 max(max(abs(scale_move_speed_weights)))])
    colorbar
    title('Scaled Movement Filter')
    ylabel('Unit')
    xlabel('Bin')
    view([0 90])

    subplot(1,3,2)
%     surf([scale_post_speed_weights zeros(size(scale_post_speed_weights,1),1); zeros(1,size(scale_post_speed_weights,2) + 1)])
    surf([scale_post_speed_weights(sortedPDs(:,13),:) zeros(size(scale_post_speed_weights,1),1); zeros(1,size(scale_post_speed_weights,2) + 1)])
    axis([1 size(scale_post_speed_weights,2)+1 1 size(scale_post_speed_weights,1)+1 -max(max(abs(scale_post_speed_weights))) max(max(abs(scale_post_speed_weights)))])
    caxis([0 max(max(abs(scale_post_speed_weights)))])
    colorbar
    title('Scaled Posture Filter')
    ylabel('Unit')
    xlabel('Bin')
    view([0 90])
    
    subplot(1,3,3)
    surf([sortedPDs(:,4) zeros(size(sortedPDs,1),1); zeros(1,2)])
    axis([1 2 1 size(sortedPDs,1)+1 0 6.2832]);caxis([0 6.2832])
    colorbar
    title('PDs')
    ylabel('Unit')
    xlabel('PD')
    view([0 90])

    
    figure
    plot(mean(scale_post_speed_weights,1),'r')
    hold on
    plot(mean(scale_move_speed_weights,1),'b')
          