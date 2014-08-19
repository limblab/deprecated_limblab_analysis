function [params,numBlocks] = estimateGLMError(x,y,blockLength,randSample)
% Break a file into pieces and fit multiple GLMs to get a sense for the
% variability of parameter estimates
%
%   x: independent variable; M observations by K variables (ie pos, vel)
%   y: dependent variable; M observations by 1 for model (ie firing rate)
%   numBlocks: split the data into this many samples
%   randSample: (bool) whether to randomly sample or use chunks
%
%   Finds weights of parameters

glm_statistics = 'poisson';

% get total amount of data
m = size(x,1);

% find how many blocks
numBlocks = floor(m/blockLength);

% scramble data
if randSample
    % scramble the data
    I = randperm(length(y));
    x = x(I,:);
    y = y(I);
end

% store all of the parameters
params = zeros(numBlocks,size(x,2)+1);
for idx = 1:numBlocks;
    use_x = x(1+blockLength*(idx-1):blockLength*idx,:);
    use_y = y(1+blockLength*(idx-1):blockLength*idx);
    
    b = glmfit(use_x,use_y,glm_statistics);
    params(idx,:) = b';
end

