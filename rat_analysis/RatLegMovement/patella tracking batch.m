%%  read in the femur and patella models
load(OPTS.FEMUR_MODEL,'femur_model');
load(OPTS.PATELLA_MODEL,'patella_model');

%%  read in all the Vicon files for this animal

allstim = read_vicon_filelist(OPTS.DATASET(3),OPTS);

%% add the virtual markers to the data 
[nlist, nfiles] = size(allstim);
for jj = 1:nlist
    for ii = 1:nfiles
        markers = allstim{jj,ii};
        patella = markers(1);
        femur = markers(2);
        patella = add_virtual_marker(patella, patella_model);
        femur = add_virtual_marker(femur, femur_model);
        markers(1).x = patella.x; markers(1).y = patella.y; markers(1).z = patella.z;
        markers(2).x = femur.x; markers(2).y = femur.y; markers(2).z = femur.z;
        allstim{jj,ii} = markers;
    end
end

%%
figure
p = markers(1);
plot3(p.x,p.y,p.z,'b.')
hold on
p = markers(2);
plot3(p.x,p.y,p.z,'r.')
axis('equal')
grid on

%%
markers = allstim{5,5};
p = markers(1);
nmkr = size(p.x,2);
ind = 4:2:nmkr;
ind2 = 100:1:200;
plot3(p.x(ind2,ind),p.y(ind2,ind),p.z(ind2,ind),'r.')
hold on
markers = allstim{6,5};
p = markers(1);
plot3(p.x(ind2,ind),p.y(ind2,ind),p.z(ind2,ind),'b.')
axis('equal')
grid on
hold off
%%
for mm = 1:length(list)
    disp(mm)
        for ii = 1:length(list{mm})
            filelist = list{mm};
%             fname = [fname_root num2str(filelist(ii) + kk-1) '.csv'];
            fnum = filelist(ii);
            markers = read_vicon_file(fnum,OPTS);  % reads in the vicon CSV file
            nmarkers = length(markers);
            
            % find the femur markers with the different labels (femur,
            % patella, wand
            for jj = 1:nmarkers
                ind = regexp(markers(jj).name,'fem');
                if ~isempty(ind)
                    allfemur(mm,ii) = markers(jj);
                end
                ind = regexp(markers(jj).name,'pat');
                if ~isempty(ind)
                    allpatella(mm,ii) = markers(jj);
                end
                ind = regexp(markers(jj).name,'wand');
                if ~isempty(ind)
                    allwand(mm,ii) = markers(jj);
                end
                ind = regexp(markers(jj).name,'tib');
                if ~isempty(ind)
                    alltibia(mm,ii) = markers(jj);
                end
            end
%             if size(allfemur(mm,kk,ii).x,2) ~=4
%                 disp([num2str(size(allfemur(mm,kk,ii).x,2)) ' ' allfemur(mm,kk,ii).file])
%             end
        end  % ii
    end  % kk
end

%%  reexpress patellar markers in femur coordinate frame

for mm = 1:length(list)
        for ii = 1:length(list{mm})
            p = allpatella(mm,ii);
            f = allfemur(mm,ii);
            t = alltibia(mm,ii);
 
            nsamps = size(p.x,1);
            nmarkersp = size(p.x,2);
            nmarkersf = size(f.x,2);
            nmarkerst = size(t.x,2);
            
            for jj = 1:nsamps  
                fp = [f.x(jj,:); f.y(jj,:); f.z(jj,:)];
                pp = [p.x(jj,:); p.y(jj,:); p.z(jj,:)];
                tp = [t.x(jj,:); t.y(jj,:); t.z(jj,:)];
                [newframe, origin] = define_frame(fp);
                newfp = coord_transform(fp,newframe,origin);
                newpp = coord_transform(pp,newframe,origin);
                newtp = coord_transform(tp,newframe,origin);
                
                % put the femur referenced points in to the data as well
                f.femur_x(jj,:) = newfp(1,:); f.femur_y(jj,:) = newfp(2,:); f.femur_z(jj,:) = newfp(3,:);
                p.femur_x(jj,:) = newpp(1,:); p.femur_y(jj,:) = newpp(2,:); p.femur_z(jj,:) = newpp(3,:);
                t.femur_x(jj,:) = newtp(1,:); t.femur_y(jj,:) = newtp(2,:); t.femur_z(jj,:) = newtp(3,:);
                if jj == 1  % this is the transformation to return the markers to the original world frame
                    allinvframe{mm,ii} = inv(newframe');
                    allorigin{mm,ii} = origin;
                end

            end  % jj samples

            allnewpatella(mm,ii) = p;
            allnewfemur(mm,ii) = f;
            allnewtibia(mm,ii) = t;
                       
        end % ii stim levels
end % positions

                
%%

mm = 1;  ii = 2;
f = allnewfemur(mm,ii);
p = allnewpatella(mm,ii);
t = allnewtibia(mm,ii);

for ii = 1:3
    plot3(p.femur_x(:,ii), p.femur_y(:,ii), p.femur_z(:,ii),'b.')
    hold on
end
grid on

for ii = 1:3
    plot3(f.femur_x(:,ii), f.femur_y(:,ii), f.femur_z(:,ii),'r.')
    hold on
end

for ii = 1:3
    plot3(t.femur_x(:,ii), t.femur_y(:,ii), t.femur_z(:,ii),'g.')
    hold on
end

axis('equal')
grid on
hold off


%%

for ii = 1:4
    plot3(p.femur_x(:,ii), p.femur_y(:,ii), p.femur_z(:,ii),'b.')
    hold on
end
grid on
hold off

figure
for ii = 1:4
    plot3(p.x(:,ii), p.y(:,ii), p.z(:,ii),'r.')
    hold on
end
grid on
hold off


%%  this does the screw axes analysis
    %  find max displacement for each file - assume the femur is stationary
for mm = 1:length(list)
    for jj = 1:3
        for ii = 1:length(list{mm})
            x = allnewpatella(mm,jj,ii).femur_x;
            y = allnewpatella(mm,jj,ii).femur_y;
            z = allnewpatella(mm,jj,ii).femur_z;

            cx = mean(x,2);
            cy = mean(y,2);
            cz = mean(z,2);
            
            points = [cx cy cz];
            init = [mean(cx(1:100)) mean(cy(1:100))  mean(cz(1:100))];
            
            nframes = length(cx);
            init2 = repmat(init,nframes,1);
            dist = sqrt(sum((init2 - points).^2,2));
            [mx,mxind] = max(dist(1:(end-10)));

            mxind = max([11 mxind]);
            mxind = min([mxind nframes-10]);
            % ok, now put together the frames for rotation
            initind = 1:100;
            dispind = (mxind-10):(mxind+10);
            
            initmarkers = [mean(x(initind,:)); mean(y(initind,:)); mean(z(initind,:))];
            dispmarkers = [mean(x(dispind,:)); mean(y(dispind,:)); mean(z(dispind,:))];
            
            [regParams,Bfit,ErrorStats]=absor(initmarkers,dispmarkers);
            T = [regParams.R regParams.t; 0 0 0 1];
            [v,point,phi,t] = screw(T);
            allphi(mm,jj,ii) = phi;
            allt(mm,jj,ii) = t;
            allv(mm,jj,ii,1:3) = v;
            allpt(mm,jj,ii,1:3) = point;
            allv2(mm,jj,ii,1:3) = allinvframe{mm,jj,ii}*v;
            allpt2(mm,jj,ii,1:3) = allinvframe{mm,jj,ii}*point + allorigin{mm,jj,ii};
        end
    end
end



                
                