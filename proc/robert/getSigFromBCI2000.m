function sig=getSigFromBCI2000(signal,states,parameters,SIGNALTOUSE)

fprintf(1,'finding %s signal...\n',SIGNALTOUSE)
switch SIGNALTOUSE
    case 'force'
        sig=[rowBoat(1:size(signal,1))/1000, ...
            signal(:,strcmpi(parameters.ChannelNames.Value,SIGNALTOUSE))];
    case 'CG'
        for i=1:22
            cg(:,i)=eval(['states.GloveSensor',int2str(i)]);
        end
        clear i
        % make sure and delete outrageously large deviations
        % within the signals, often occurring at the beginning of files.
        % Also, employ this for EMGs after filtering/rectification/etc.
        cgz=zscore(double(cg))'; clear cg
        %Remove the noise "pops" that occur from using >1 file, or just inherent
        %noise from the sensors, by interpolating in the parts that are >2SDs from
        %the mean
        %Do each channel separately in case they are different on different
        %channels
        cgnew=cgz;
        for j=1:size(cgz,1)
            clear badinds badepoch badstartinds badendinds
            badinds=find(cgz(j,:)<-3);
            if ~isempty(badinds)
                badepoch=find(diff(badinds)>1);
                badstartinds=[badinds(1) badinds(badepoch+1)];
                badendinds=[badinds(badepoch) badinds(end)];
                if badendinds(end)==length(cgnew)
                    badendinds(end)=badendinds(end)-1;
                end
                if badstartinds(1)==1 %If at the very beginning of the file need a 0 at start of file
                    cgnew(j,1)=cgnew(j,badendinds(1)+1);
                    badstartinds(1)=2;
                end
                for i=1:length(badstartinds)
                    cgnew(j,badstartinds(i):badendinds(i))=interp1([(badstartinds(i)-1) ...
                        (badendinds(i)+1)],[cgnew(j,badstartinds(i)-1) cgnew(j,badendinds(i)+1)], ...
                        (badstartinds(i):badendinds(i)));
                end
            else
                cgnew(j,:)=cgz(j,:);
            end
        end
        cgz=cgnew;
        clear cgnew

        [junk,scores,variances,junk] = princomp(cgz');

        % to determine how many components to use, find the # that account for
        % >= 90% of the variance.
        % FOR POSITION THE FUNCTION EXPECTS A TIME VECTOR PREPENDED
        temp=cumsum(variances/sum(variances));
        positionData=[rowBoat(1:size(cgz,2))/1000, scores(:,1:3)];
        fprintf(1,'Using 3 PCs, which together account for\n')
        fprintf(1,'%.1f%% of the total variance in the PC signal\n',100*temp(size(positionData,2)-1))

        sig=positionData;
end
