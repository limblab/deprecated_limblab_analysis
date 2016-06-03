function error = CORfun(x,markers,nM)

% computes to least squares estimate of parameters
N = size(markers,1);
error = 0;
for ii = 1:N
    for jj = 1:nM
        % Compute residual error = Euclidean dist between estimated joint
        % center and marker AND estimated radius to marker from joint
        % center
        error = error + (sqrt(sum((markers(ii,(jj-1)*3+1:jj*3)'-x(1:3)).^2)) - x(jj+3))^2; 
    end
end

