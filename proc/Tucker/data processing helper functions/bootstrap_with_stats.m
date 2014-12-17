function [stats,varargout]=bootstrap_with_stats(fhandle, data, options, varargin)
    %performs bootstrapping and basic statistics on a function and
    %arbitrary data set. 
    %[stats,variable_ouput]=bootstrap_with_stats(@function, data, varargin)
    %Input is:
    %A handle to the function to boostrap: @fucntion. this function must
    %   accept an array of doubles as input. If necessary, the function can
    %   take an additional input of a struct containing flags and options to
    %   dictation execution parameters
    %A matrix of data that will be used to generate input data sets for the
    %   function specified by the user. The data is assumed to be formatted
    %   in columns with each row corresponding to a single data point
    %A struct of options for the function. IF the function does not take an
    %   options struct pass an empty vector here.
    %additional optional struct specifying options for the bootstrapping. 
    %   fields of the struct must be: reps, n_samp, replace, CI_range
    %   reps is the number of bootstrap repetitions
    %   n_samp is the number of data points to draw for every repetition
    %   replace is a boolean flag indicating whether to draw with
    %       replacement
    %   CI_int is the confidence interval to report bounds for. 0.95 will
    %       return the upper and lower bounds of the 95% confidence interval
    %
    %output is a struct with the following fields:
    %stats.mean  :   the mean of the function output across iterations
    %stats.var   :   the variance of the function output across iterations
    %stats.CI    :   95%CI of the function output across iterations
    %
    %complete function call is:
    %[stats,Raw_ouput,Raw_input]=bootstrap_with_stats(fhandle, data, options, reps, n_samp, replace, CI_range)

    if length(varargin)>0
        reps=varargin{1}.reps;
        n_samp=varargin{1}.n_samp;
        replace=varargin{1}.replace;
        CI_int=varargin{1}.CI_int;
    else
        reps=1000;
        n_samp=size(data,1);
        replace=true;
        CI_int=0.95;
    end

    %make empty arrays for input data set and ouptut data set
    input_data_mat=zeros(reps,n_samp,size(data,2));
        
    %find output data size by testing:
    
    if ~isempty(options)
        temp=fhandle(data,options);
    else
        temp=fhandle(data);
    end
    output_data_mat=zeros(reps,size(temp,1),size(temp,2));
    %initialize variables for mean and variance
    
    for i=1:reps
        %make new input data matrix and add it to the input data array
        input_data_mat(i,:,:)=datasample(data,n_samp,'Replace',replace);
        %call function on new input data to generate output
        if ~isempty(options)
            output_data_mat(i,:,:)=fhandle(input_data_mat(i,:,:),options);
        else
            output_data_mat(i,:,:)=fhandle(squeeze(input_data_mat(i,:,:)));
        end
    end

    stats.mean=squeeze(mean(output_data_mat,1));
    stats.var=squeeze(var(output_data_mat,0,1));%0 causes default weighting, 1 is computing across first dimension
    stats.CI=get_CI_from_dist(output_data_mat,CI_int);

    if nargout>1
        %set varargout(3) to array of output used to compose mean and variance
        varargout{1}=output_data_mat;
    end
    if nargout>2
        %set varargout(4) to array of input used to generate all outputs
        varargout{4}=input_data_mat;
    end
end