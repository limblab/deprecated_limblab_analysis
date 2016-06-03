% addpath('C:\Users\Nicholas Sachs\Lab Code\s1_analysis\proc\boubker\PDs');
% filePDs = PDs_from_spikes('C:\Users\Nicholas Sachs\Desktop\temporary work files\SD Data\Chewie_Spike_01092012001-sorted',18,32,0,-0.25,0.2,0.05);
% 
% PDs = filePDs{1,1};
% PDs(:,13) = [1:length(PDs)]';
% sortedPDs = sortrows(PDs,4);
% 
bins = round(movement_decoder.fillen/movement_decoder.binsize);

for d = 1:3
%     for x = 1:length(movement_decoder.H)
%         gen_weights(ceil(x/bins),round(mod(x-1,bins))+1) = general_decoder.H(x,d);
%         move_weights(ceil(x/bins),round(mod(x-1,bins))+1) = movement_decoder.H(x,d);
%         post_weights(ceil(x/bins),round(mod(x-1,bins))+1) = posture_decoder.H(x,d);
%     end

%     for x = 1:length(movement_decoder.H)
%         gen_weights(ceil(x/bins),round(mod(x-1,bins))+1) = general_decoder.H(x,d)*mean(binnedData.spikeratedata(:,ceil(x/bins)));
%         move_weights(ceil(x/bins),round(mod(x-1,bins))+1) = movement_decoder.H(x,d)*mean(binnedData.spikeratedata(:,ceil(x/bins)));
%         post_weights(ceil(x/bins),round(mod(x-1,bins))+1) = posture_decoder.H(x,d)*mean(binnedData.spikeratedata(:,ceil(x/bins)));
%     end

    for x = 1:length(movement_decoder.H)
        gen_weights(ceil(x/bins),round(mod(x-1,bins))+1) = general_decoder.H(x,d)/max(abs(general_decoder.H(x-round(mod(x-1,bins)):x-round(mod(x-1,bins))-1+bins,d)));
        move_weights(ceil(x/bins),round(mod(x-1,bins))+1) = movement_decoder.H(x,d)/max(abs(movement_decoder.H(x-round(mod(x-1,bins)):x-round(mod(x-1,bins))-1+bins,d)));
        post_weights(ceil(x/bins),round(mod(x-1,bins))+1) = posture_decoder.H(x,d)/max(abs(posture_decoder.H(x-round(mod(x-1,bins)):x-round(mod(x-1,bins))-1+bins,d)));
    end
    
    gen_weights = double(gen_weights);
    move_weights = double(move_weights);
    post_weights = double(post_weights);
    
    figure;

    subplot(1,3,1)
    surf([abs(gen_weights) zeros(size(gen_weights,1),1); zeros(1,size(gen_weights,2) + 1)])
%     surf([gen_weights zeros(size(gen_weights,1),1); zeros(1,size(gen_weights,2) + 1)])
%     surf([gen_weights(sortedPDs(:,13),:) zeros(size(gen_weights,1),1); zeros(1,size(gen_weights,2) + 1)])
    axis([1 size(gen_weights,2)+1 1 size(gen_weights,1)+1 -max(max(abs(gen_weights))) max(max(abs(gen_weights)))])
    caxis([0 max(max(abs(gen_weights)))])
%     caxis([-max(max(abs(gen_weights))) max(max(abs(gen_weights)))])
    colormap('gray')
    colorbar
    title('Standard Filter')
    ylabel('Unit')
    xlabel('Bin')
    view([0 90])

    subplot(1,3,2)
    surf([abs(move_weights) zeros(size(move_weights,1),1); zeros(1,size(move_weights,2) + 1)])
%     surf([move_weights zeros(size(move_weights,1),1); zeros(1,size(move_weights,2) + 1)])
%     surf([move_weights(sortedPDs(:,13),:) zeros(size(move_weights,1),1); zeros(1,size(move_weights,2) + 1)])
    axis([1 size(move_weights,2)+1 1 size(move_weights,1)+1 -max(max(abs(move_weights))) max(max(abs(move_weights)))])
    caxis([0 max(max(abs(move_weights)))])
%     caxis([-max(max(abs(move_weights))) max(max(abs(move_weights)))])
    colormap('gray')
    colorbar
    title('Movement Filter')
    ylabel('Unit')
    xlabel('Bin')
    view([0 90])

    subplot(1,3,3)
    surf([abs(post_weights) zeros(size(post_weights,1),1); zeros(1,size(post_weights,2) + 1)])
%     surf([post_weights zeros(size(post_weights,1),1); zeros(1,size(post_weights,2) + 1)])
%     surf([post_weights(sortedPDs(:,13),:) zeros(size(post_weights,1),1); zeros(1,size(post_weights,2) + 1)])
    axis([1 size(post_weights,2)+1 1 size(post_weights,1)+1 -max(max(abs(post_weights))) max(max(abs(post_weights)))])
    caxis([0 max(max(abs(post_weights)))])
%     caxis([-max(max(abs(post_weights))) max(max(abs(post_weights)))])
    colormap('gray')
    colorbar
    title('Posture Filter')
    ylabel('Unit')
    xlabel('Bin')
    view([0 90])
    
    figure
    plot(mean(abs(post_weights),1),'r')
%     plot(mean(post_weights,1),'r')
    hold on
    plot(mean(abs(move_weights),1),'b')
%     plot(mean(move_weights,1),'b')
    plot(mean(abs(gen_weights),1),'k')
%     plot(mean(gen_weights,1),'k')
    
end
        