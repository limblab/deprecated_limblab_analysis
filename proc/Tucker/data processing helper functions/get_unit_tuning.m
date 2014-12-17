function [tuning,stats,methodData]=get_unit_tuning(data,method,statTest)
    %[tunCurves,stats,methodData]=get_unit_tuning(data,method,sigTest)
    %estimates tuning of the specified unit on the given bdf
    %data should be a column matrix. first column should contain firing
    %rate, all additional columns should contain associated kinematic or
    %kinetic data. Each row will constitute a single data point for
    %estimatein the tuning of the unit.
    %'method' should be a cell array. The first field should be a string
    %indicating the type of method used for computing the tuning.
    %Subsequent cells should contain data and flags relevent for computing 
    %the tuning using that method:
    %for the 'mean' method, no additional cells are necessary
    %for the 'glm' method, one additional field is necessary. that field
    %should contain a structure with the following fields:
    %s.mdl=fit type, available options are: 'pos', 'vel', 'posvel',
    %'nospeed','velforce', 'forceonly', 'posvelforce'
    %optionally the structure can contain the following field
    %s.noiseModel, which contains the type of model the GLM will use for
    %noise. If this is empty the function will assume 'poisson'
    %
    %statTest should be a cell array. the first cell should be a string
    %specifying the type of significance test to use. subsequent cells
    %should contain data and flags for computing statistics using that
    %method
        
    % use the appropriate method to get tuning and generate confidence 
    %intervals:
    switch statTest{1}
        case 'bootstrap'
            %make anonymous function and call with bootstrapping
            %[stats,trialResults,trialInputs]=bootstrap_with_stats(fhandle, data, options, varargin)
            if length(statTest)>1
                %fhandle=@(x,ops) get_tuning(x,ops);
                [bootstrapStats,methodData.trialResults,methodData.trialInputs]=bootstrap_with_stats(@get_tuning, data, method, statTest{2});
            else
                %fhandle=@(x) get_tuning(x);
                [bootstrapStats,methodData.trialResults,methodData.trialInputs]=bootstrap_with_stats(@get_tuning, data, method);
            end
            tuning=bootstrapStats.mean;
            stats.CI=bootstrapStats.CI;
            stats.var=bootstrapStats.var;
        case 'anova'
            confLevel = statTest{2};
            stats.alpha = anova1(data(:,1),data(:,2),'off');
            stats.pd_sig = ap <= confLevel;
            [tuning,methodData]=get_tuning(data,method);
        case 'glm'
            if ~strcmp(method{1},'glm')
                error('GET_UNIT_TUNING:MethodIncompatibleWithGLMSignificanceChecking',strcat('Tuning computation method: ',method{1}, 'cannot be used with GLM significance testing'))
            end
            [tuning,methodData]=getGLMPD(data,method{2});
            stats=methodData.stats;
        case 'none'
            
            [tuning,methodData]=get_tuning(data,method{2});
            stats=[];
            
        otherwise
            error('GET_UNIT_TUNING:UNRECOGNIZED_TEST',strcat(statTest{1},' is not a recognized method for testing significance'))
    
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%

function [tuning,methodData]=get_tuning(data,method)
%wrapper allowing bootstrap to operate on any method
    %use switch to compute tuning curve using the selected method
    switch method{1}
        case 'mean'
            %compute curves simply as the mean firing rate across angle bins
            %returns a vector of mean FR for each unique angle
            [tuning,methodData]=getMeanFR(data);
        case 'glm'
            %use a GLM to estimate the tuning as an exponentiated sinusoid.
            %this method accounts for poisson distributions of noise rather
            %than gaussians. the second tem of the method. The data matrix
            %is assumed to be a column of firing rates or spike counts,
            %followed by columns of data
            
            [tuning,methodData]=getGLMPD(data,method{2});
        case 'fit'
            %fit a simple sinusoid model of tuning. returns a vector:
            %[b0 b1 b2]=[baseline FR, modulation depth, tuning angle] for model:
            %b0+b1*cos(theta)+b2*sin(theta)
            %expects FR and kinData to be vectors. kinData should contain
            %the angle associated with each firing rate in FR
            [tuning,methodData]=regressTCs( data);
        otherwise 
            error('GET_UNIT_TUNING:UNRECOGNIZED_METHOD',strcat(method{1},' is not a recognized method for computing tuning'))
    end
    
end

function [tuning,method_data]=getMeanFR(data)
    %subfunction to find mean FR data
    %returns a 2xN matrix, where N is the number of unique angles
    %row 1 is the mean FR, row2 is the variance
    
    angles=unique(data(:,1));
    tuning=zeros(size(angles));
    for i=1:length(angles)
        mask=data(:,2)==angles(i);
        tuning(i)=mean(data(mask,1));
        method_data.variance(i)=var(data(mask,1));
        method_data.N=sum(mask);
    end

end

function [tuning,methodData]=getGLMPD(data,model)
%expects data to be a column vector, columns are binned spike count, posx, 
%posy, velx, vely, forcex, forcey
%expects a second input model, which is a structure specifying the model
%type for the glm. this input can also have a field specifying the noise
%model used by the GLM. If this field is not present, the function assumes
%a poisson distribution.
    if ~isfield(model,'noiseModel')
        model.noiseModel='poisson';
    end
    %Template:
        %glm_input=[subset of data(:,2:end)]
        %[methodData.mdl,methodData.dev,methodData.stats] = glmfit(glm_input,data(:,1),method.noiseModel);
        %tuning=[PD,MD,...]
        %PD computed as atan2(weights(1),weight(2))
        %MD computed as norm(weights)
    switch model.mdl
        case 'pos'
            glm_input = data(:,2:3);
            [methodData.mdl,methodData.dev,methodData.stats] = glmfit(glm_input,data(:,1),model.noiseModel);
            tuning=[atan2(methodData.mdl(2),methodData.mdl(3)),norm(methodData.mdl)];           %[PD_pos,MD_pos]
        case 'vel'
            glm_input = [data(:,4:5) sqrt(data(:,4).^2 + data(:,5).^2)];
            [methodData.mdl,methodData.dev,methodData.stats] = glmfit(glm_input,data(:,1),model.noiseModel);
            tuning=[atan2(methodData.mdl(2),methodData.mdl(3)),norm(methodData.mdl(2:3))];      %[PD_vel, MD_vel]
        case 'posvel'
            glm_input = [data(:,2:3) data(:,4:5) sqrt(data(:,4).^2 + data(:,5).^2)];
            [methodData.mdl,methodData.dev,methodData.stats] = glmfit(glm_input,data(:,1),model.noiseModel);
            tuning=[atan2(methodData.mdl(2),methodData.mdl(3)),norm(methodData.mdl(2:3)), ...   %[PD_pos,MD_pos,...
                atan2(methodData.mdl(4),methodData.mdl(5)),norm(methodData.mdl(4:5))];          % PD_vel, MD_vel]
        case 'nospeed'
            glm_input = [data(:,2:3) data(:,4:5)];
            [methodData.mdl,methodData.dev,methodData.stats] = glmfit(glm_input,data(:,1),model.noiseModel);
            tuning=[atan2(methodData.mdl(2),methodData.mdl(3)),norm(methodData.mdl(2:3)),...    %[PD_pos,MD_pos,...
                atan2(methodData.mdl(4),methodData.mdl(5)),norm(methodData.mdl(4:5))];          %PD_vel, MD_vel]
        case 'velforce'
            glm_input = [data(:,4:5) data(:,6:7)];
            [methodData.mdl,methodData.dev,methodData.stats] = glmfit(glm_input,data(:,1),model.noiseModel);
            tuning=[atan2(methodData.mdl(2), methodData.mdl(3)),norm(methodData.mdl(2:3)),...   %[PD_vel,MD_vel,
                atan2(methodData.mdl(4), methodData.mdl(5)),norm(methodData.mdl(4:5))];         %PD_force, MD_force]
        case 'forceonly'
            glm_input = data(:,6:7);
            [methodData.mdl,methodData.dev,methodData.stats] = glmfit(glm_input,data(:,1),model.noiseModel);
            tuning=[atan2(methodData.mdl(2), methodData.mdl(3)),norm(methodData.mdl(2:3))];     %[PD_force,MD_force]
        case 'posvelforce'
            glm_input = [data(:,2:3) data(:,4:5) data(:,6:7)];
            [methodData.mdl,methodData.dev,methodData.stats] = glmfit(glm_input,data(:,1),model.noiseModel);
            tuning=[atan2(methodData.mdl(2), methodData.mdl(3)),norm(methodData.mdl(2:3)),...   %[PD_pos,MD_pos,...
                atan2(methodData.mdl(4), methodData.mdl(5)),norm(methodData.mdl(4:5)),...       %PD_vel,MD_vel,...
                atan2(methodData.mdl(6), methodData.mdl(7)),norm(methodData.mdl(6:7))];         %PD_force, MD_force]
        otherwise
            error('unknown model: %s', mdl);
    end
   
    lambda = glmval(methodData.mdl, glm_input, 'log');
    methodData.logLiklihood = sum(log(lambda.^(data(:,1))) - lambda - log(factorial(data(:,1))));
    lambda = sum(data(:,1))/length(data(:,1));
    methodData.nullLogLiklihood = sum(log(lambda.^(data(:,1))) - lambda - log(factorial(data(:,1))));
end

function [tuning,methodData] = regressTCs(data)
%   Subfunction to regress the tuning curves
%   fits model b0 + b1*cos(theta + b2) to firing rate/angle data
%       b2 is preferred direction
%       input is a column matrix, col1 is FR values, col2 is associated
%       directions
%       returns rsq

    st = sin(data(:,1));
    ct = cos(data(:,1));
    X = [ones(size(data(:,1))) st ct];

    % use multiple linear regression to fit model:
    % b0+b1*cos(theta)+b2*sin(theta)
    [b,~,~,~,methodData.stats] = regress(data(:,2),X);
    % convert to model b0 + b1*cos(theta+b2)
    tuning  = [b(1); sqrt(b(2).^2 + b(3).^2); atan2(b(2),b(3))];
end