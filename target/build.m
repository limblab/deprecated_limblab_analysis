function r = build(varargin)
% BUILD     Builds the specified files acording to the dependency tree
%   BUILD(T) builds the entire dependency tree specified in T
%   BUILD(T, F) builds file F and all dependencies in the dependency tree T
%   BUILD(T, F, DEBUG) same as above but prints out debugging information
%       when DEBUG is set to TRUE.
%   R = BUILD(T) returns the result of the build: R = 1: built
%                                                 R = 0: not built
%
%   The BUILD function recognises the following file types:
%       .mex32w     Looks for the coresponding .c file and compiles it
%       .dlm        Looks for the coresponding .mdl file and builds it
%
%   Dependency tree format:
%       Each entry in the cell array represents a build rule.  It points to 
%       a cell array of strings.  The first entry is the filename of the
%       current rule target.  Subsequent entries list the dependencies.
%       
%       Example:
%           T = {{'random_walk.dlm', 'mastercon_rw.mex32w', ... 
%                                    'serPos.mex32w', 
%                                    'Byte2Bits.mex32w'}, ...
%                {'center_out.dlm',  'mastercon_co.mex32w', ...
%                                    'serPos.mex32w', ...
%                                    'Byte2Bits.mex32w'}};

% $Id: build.m 845 2012-04-03 14:26:28Z brian $

%
% Argument processing
%

if (nargin < 1 || nargin >3)
    error('Invalid number of arguments.');
end

tree = varargin(1);
tree = tree{1};

if (nargin > 1) 
    target = varargin{2};
else 
    target = 'all';
end

if (nargin > 2)
    debug = varargin{3};
else
    debug = 0;
end

%
% Recursive build
%

dbprint(sprintf('building %s', target))
must_build = 0;

if strcmp(target, 'all')
    % build each of the 
    for i = 1:length(tree)
        local_target = tree{i}{1};
        dbprint(sprintf('--- Building Target: %s ---', local_target));
        build(tree, local_target, debug);
    end
else
    %
    % We are building for a particular target
    %
    
    % see if the rule exists
    rule_index = -1;
    for i = 1:length(tree)
        if (iscell(tree{1}))
            if (strcmp(tree{i}{1}, target))
                rule_index = i;
            end
        else
            if (strcmp(tree{i}, target))
                rule_index = i;
            end
        end
    end
    
    if (rule_index ~= -1)
        % we have a rule for the particular target
        
        % build all dependencies
        for i = 2:length(tree{rule_index})
            dbprint(['entering next level for ' tree{rule_index}{i}]);
            must_build = must_build + build(tree, tree{rule_index}{i}, debug);
            dbprint(['done with ' tree{rule_index}{i}]);
            dbprint('');
        end
        
        % finally, build the target with the auto rule
        r = do_build(tree{rule_index}{1}, must_build, tree{rule_index});
    else
        % If there is no rule, just make one up
        r = do_build(target, false, []);
    end
    
end % strcmp(target, 'all')



%%%%%%%%%%%%% Begin Internal Functions %%%%%%%%%%%%%%%%%

function r = do_build(target, force, deps)
    if (regexp(target, '\.mexw32$'))
        r = do_build_mex(target, force, deps);
    elseif (regexp(target, '\.dlm$'))
        r = do_build_dlm(target, force, deps);
    elseif (regexp(target, '\.obj$'))
        r = do_build_obj(target, force, deps);
    else 
        error(['Have no rule for target: ' target]);
    end
end


function r = do_build_mex(target, force, deps)
    r = 0;
    libs = '';
    for d=1:length(deps)
        if regexp(deps{d}, '\.obj$')
            libs = [libs ',''' deps{d} ''''];
        end
    end

    compname = target;
    compdate = dir(compname);

    filename = regexp(compname, '^(\w*)\.mexw32$', 'tokens');
    filename = filename{1};
    fn = strcat(filename{1}, '.cpp');
    filedate = dir(fn);
    % support legacy code
    if (isempty(filedate))
        fn = strcat(filename{1}, '.c');
        filedate = dir(fn);
    end
    filedate = filedate.datenum;

    if (~isempty(compdate))
        compdate = compdate.datenum;
        if (filedate > compdate)
            r = 1;
        end 
    else
        r = 1;
    end

    if (r || force)
        dbprint(['  building: ' target]);
        eval(['mex(fn' libs ')']);
    else
        dbprint(['  skipped:  ' target]);
    end
end

function r = do_build_obj(target, force, deps)
    r = 0;

    compname = target;
    compdate = dir(compname);

    filename = regexp(compname, '^(\w*)\.obj$', 'tokens');
    filename = filename{1};
    fn = strcat(filename{1}, '.cpp');
    filedate = dir(fn);
    % support legacy code
    if (isempty(filedate))
        fn = strcat(filename{1}, '.c');
        filedate = dir(fn);
    end
    filedate = filedate.datenum;

    if (~isempty(compdate))
        compdate = compdate.datenum;
        if (filedate > compdate)
            r = 1;
        end
    else
        r = 1;
    end

    if (r || force)
        dbprint(['  building: ' target]);
        mex('-c', fn);
    else
        dbprint(['  skipped:  ' target]);
    end
end

function r = do_build_dlm(target, force, deps)
    r = 0;

    compname = target;
    compdate = dir(compname);

    filename = regexp(compname, '^(\w*)\.dlm$', 'tokens');
    filename = filename{1};
    buildname = filename{1};
    filename = strcat(filename{1}, '.mdl');
    filedate = dir(filename);
    filedate = filedate.datenum;

    if (~isempty(compdate))
        compdate = compdate.datenum;
        if (filedate > compdate)
            r = 1;
        end 
    else 
        r = 1;
    end

    if (r || force)
        dbprint(['  building: ' target]);
        rtwbuild(buildname);
    else
        dbprint(['  skipped:  ' target]);
    end
end

function dbprint(str)
    if (debug)
        disp(str)
    end
end

%%%%%%%%%%%%%% End Internal Functions %%%%%%%%%%%%%%%%%%


end % end of build() [mis-indented]

