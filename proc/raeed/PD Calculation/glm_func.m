function result = glm_func(data)
% Data is in format:
%   [spikes, posx, posy, velx, vely, speed]
    result = glmfit(data(:,2:end),data(:,1),'poisson');
    result = result';
end