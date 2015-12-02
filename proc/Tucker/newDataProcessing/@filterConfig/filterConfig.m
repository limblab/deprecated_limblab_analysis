classdef filterConfig < matlab.mixin.SetGet%handle
    %class for filter definitions to be used while loading raw data into
    %the common_data_structure class This class is intended for use with 
    %the common_data_structure class for specificing parameters to be used 
    %when filtering and decimating data
    properties (SetAccess = public)
        SR
        poles
        cutoff
    end
    methods (Static = true)
        function FC=filterConfig(varargin)
            %constructor function for the filterConfig class. 
            SR=100;
            poles=8;
            cutoff=25;
            if ~isempty(varargin)
               for i=1:2:length(varargin)-1
                   switch varargin{i}
                       case 'poles'
                           poles=varargin{i+1};
                       case 'cutoff'
                           cutoff=varargin{i+1};
                       case 'SR'
                           SR=varargin{i+1};
                       otherwise
                            error('filterConfig:BadPropertyName',['the filterConfig class does not have a property named: ' varargin{i+1}])
                   end
               end
            end
            set(FC,'SR',SR)
            set(FC,'poles',poles)
            set(FC,'cutoff',cutoff)
        end
    end
    methods 
        function set.poles(FC,p)
            %setter function for the filterconfig class. Sets the poles
            %property
            
            %check that p is of the appropriate type:
            if isempty(p) || numel(p)~=1 || ischar(p) || p<1
                error('poles:BadPoleValue','Poles must be an integer value greater than or equal to 1')
            else
                if p>8
                    warning('poles:LargePoleValue',['The specified pole value of: ',num2str(p),' is fairly large. Consider whether a smaller pole value will work'])
                end
                FC.poles=p;
            end
        end
        function set.SR(FC,SR)
            %setter function for the filterconfig class. Sets the sample
            %rate property
            
            %check that SR is of the appropriate type:
            if ischar(SR) || ~isreal(SR) || numel(SR)~=1 || SR<=0
                error('poles:BadPoleValue','Poles must be an real value greater than or equal to 0')
            else
                if SR>8
                    warning('poles:LargePoleValue',['The specified pole value of: ',num2str(SR),' is fairly large. Consider whether a smaller pole value will work'])
                end
                FC.SR=SR;
            end
        end
        function set.cutoff(FC,c)
            %setter function for the filterconfig class. Sets the poles
            %property
            
            %check that c is of the appropriate type:
            if isempty(c) || ischar(c) || ~isempty(find(~isreal(c),1)) ||  ~isempty(find(c<=0,1)) || numel(c)>2
                error('cutoff:BadCutoffValue','Cutoff must be an Real or pair of Real values greater than or equal to 0')
            else
                if c>FC.SR/2
                    warning('cutoff:cutoffLargerThanSR',['The specified cutoff value of: ',num2str(c),' is larger than half the specified sample rate: ' num2str(FC.SR)])
                end
                FC.cutoff=c;
            end
        end
    end
end