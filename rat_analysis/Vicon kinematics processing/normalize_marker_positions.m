function [nx,ny,nz,mnx,mny,mnz] = normalize_marker_positions(onsets,x,y,z,newnsamp)

ncycles = size(onsets,1);

for ii = 1:ncycles
    ind = onsets(ii,1):onsets(ii,2);
    nsamp = length(ind);
    temp = x(ind,:);
    off = .5*(temp(1,:) + temp(end,:));
    temp2 = temp - repmat(off,nsamp,1);
    temp3 = resample(temp2,newnsamp,nsamp,3);
    nx{ii} = temp3+repmat(off,newnsamp,1);
    all_nsamp(ii) = nsamp;

    temp = y(ind,:);
    off = .5*(temp(1,:) + temp(end,:));
    temp2 = temp - repmat(off,nsamp,1);
    temp3 = resample(temp2,newnsamp,nsamp,3);
    ny{ii} = temp3+repmat(off,newnsamp,1);
    all_nsamp(ii) = nsamp;

    temp = z(ind,:);
    off = .5*(temp(1,:) + temp(end,:));
    temp2 = temp - repmat(off,nsamp,1);
    temp3 = resample(temp2,newnsamp,nsamp,3);
    nz{ii} = temp3+repmat(off,newnsamp,1);
    all_nsamp(ii) = nsamp;

end

tempx = cell2mat(nx);
tempy = cell2mat(ny);
tempz = cell2mat(nz);
for ii = 1:6
    mnx(:,ii) = mean(tempx(:,ii:6:end)');
    mny(:,ii) = mean(tempy(:,ii:6:end)');
    mnz(:,ii) = mean(tempz(:,ii:6:end)');
end
