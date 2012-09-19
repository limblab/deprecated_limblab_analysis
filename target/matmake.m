function matmake(varargin)
%MATMAKE A minimal subset of GNU make, implemented for MATLAB.
%   GNU Make "is a tool which controls the generation of executables and 
%   other non-source files of a program from the program's source files.
%   Make gets its knowledge of how to build your program from a file called
%   the makefile, which lists each of the non-source files and how to 
%   compute it from other files." For details see: www.gnu.org/software/make
%
%   Only a minimal subset of GNU Make features are implemented. Notably:
%   - Makefile parsing (looks for Matmakefile by default)
%       - Immediate assignments (var := value)
%       - Variable expansion via ${var} or $(var)
%       - The basic make 'rule' syntax (target : dependencies, followed by
%         tabbed MATLAB commands)
%       - Wildcards in targets (*.x : common.h)
%       - Pattern rules (%.x : %.y)
%       - Auto variables in rule commands:
%           - $@ = the target
%           - $< = first dependency
%           - $^ = all dependencies (with duplicates removed)
%           - $+ = all dependencies (in the exact order they are listed)
%           - $* = the pattern matched by '%' in a pattern rule
%   - Implicit rules
%       - %.mexext is automatically built with 'mex' from %.c or %.cpp
%       - %.dlm is automatically built with rtwbuild('%')
%       - %.o/%.obj is automatically build with 'mex' from %.c or %.cpp
%
%   When called without any arguments, MATMAKE searches the current working
%   directory for a file named 'Matmakefile' and builds the first target
%   listed. With one argument, it builds that target from any rules listed
%   in 'Matmakefile' (if it exists in the current working directory) or the
%   implicit rules. The optional second argument may be used to specify a
%   Matmakefile in another directory or saved as a different name.


%% Argument parsing and setup

if (nargin == 0)
    state = read_matmakefile('Matmakefile');
    target = state.rules(1).target{1};
elseif (nargin == 1)
    target = varargin{1};
    state = read_matmakefile('Matmakefile');
elseif (nargin == 2)
    target = varargin{1};
    state = read_matmakefile(varargin{2});
else
    error 'matmake: Wrong number of input arguments';
end

%% Implicit rules... TODO: do this better.
idx = 1;
state.implicitrules(idx).target   = {['%.' mexext]};
state.implicitrules(idx).deps     = {'%.c'};
state.implicitrules(idx).commands = {'mex ${CFLAGS} $<'};
idx = idx+1;
state.implicitrules(idx).target   = {['%.' mexext]};
state.implicitrules(idx).deps     = {'%.cpp'};
state.implicitrules(idx).commands = {'mex ${CPPFLAGS} ${CFLAGS} $<'};
idx = idx+1;
state.implicitrules(idx).target   = {'%.o'};
state.implicitrules(idx).deps     = {'%.c'};
state.implicitrules(idx).commands = {'mex -c ${CFLAGS} $<'};
idx = idx+1;
state.implicitrules(idx).target   = {'%.o'};
state.implicitrules(idx).deps     = {'%.cpp'};
state.implicitrules(idx).commands = {'mex -c ${CPPFLAGS} ${CFLAGS} $<'};
idx = idx+1;
state.implicitrules(idx).target   = {'%.obj'};
state.implicitrules(idx).deps     = {'%.c'};
state.implicitrules(idx).commands = {'mex -c ${CFLAGS} $<'};
idx = idx+1;
state.implicitrules(idx).target   = {'%.obj'};
state.implicitrules(idx).deps     = {'%.cpp'};
state.implicitrules(idx).commands = {'mex -c ${CPPFLAGS} ${CFLAGS} $<'};
idx = idx+1;
state.implicitrules(idx).target   = {'%.dlm'};
state.implicitrules(idx).deps     = {'%.mdl'};
state.implicitrules(idx).commands = {'rtwbuild(''$*'')'};

%% Make the target
result = make(target, state);
switch (result)
    case -1
        error('matmake: No rule found for target %s', target);
    case 0
        disp(sprintf('Nothing to be done for target %s', target));
    case 1
        disp(sprintf('Target %s successfully built', target));
end
end %function

%% Private functions %%

function result = make(target, state)
    % see if we have a rule to make the target
    target_rules = find_matching_rules(target, state.rules);
    
    cmds = {};
    deps = {};
    
    for i=1:length(target_rules)
        if (~isempty(cmds) && ~isempty(target_rules(i).commands))
            error('matmake: Multiple commands found to build target %s',target);
        elseif (~isempty(target_rules(i).commands))
            cmds = target_rules(i).commands;
        end
        % Concatenate the dependencies on the back
        deps = {deps{:}, target_rules(i).deps{:}};
    end
    
    if (isempty(cmds))
        % We didn't find any explicit commands to make this target; try
        % the implicit rules
        matching_implicit_rules = find_matching_rules(target, state.implicitrules);
        for i=1:length(matching_implicit_rules)
            deps_exist = false;
            for j = 1:length(matching_implicit_rules(i).deps)
                deps_exist = deps_exist | ~isempty(matching_implicit_rules(i).deps{j});
            end
            if (deps_exist)
                deps = {deps{:}, matching_implicit_rules(i).deps{:}};
                cmds = matching_implicit_rules(i).commands;
                break;
            end
        end
    end
    
    % TODO: This should be better (elsewhere?)
    if (isempty(cmds) && isempty(deps))
        % We don't know how to make it; ensure it exists:
        file = dir(target);
        if (isempty(file))
            result = -1;
        else
            result = 0;
        end
        return;
    end
    
    
    if (isempty(deps))
        newest_dependent_timestamp = inf;
    else
        newest_dependent_timestamp = 0;
        for i=1:length(deps)
            % Recursively make all the dependents
            status = make(deps{i}, state);
            if (status == -1)
                error('matmake: No rule to build %s as required by %s', deps{i}, target);
            end

            % Ensure the dependent exists and check its timestamp
            file = dir(deps{i});
            if (isempty(file))
                error('matmake: File %s not found as required by %s', deps{i}, target);
            end
            newest_dependent_timestamp = max(newest_dependent_timestamp, file.datenum);
        end
    end
    
    target_timestamp = -1;
    file = dir(target);
    if (~isempty(file))
        target_timestamp = file.datenum;
    end
    
    
    if (target_timestamp < newest_dependent_timestamp)
        for i = 1:length(cmds)
            cmd = expand_vars(cmds{i}, state.vars);
            disp(cmd);
            eval(cmd);
        end
        result = 1;
    else
        result = 0;
    end
end

function state = read_matmakefile(path)
    fid = fopen(path);
    
    % Parse all variables
    state.vars = struct();
    line = fgetl(fid);
    while (ischar(line))
        line = strip_comments(line);
        
        % Check for an immediate := assignment
        variable = regexp(line, '^\s*([A-Za-z]\w*)\s*:=\s*(.*)\s*$', 'tokens', 'once');
        if (length(variable) == 2)
            fldnm = variable(1); % not allowed to do variable(1){1} !?
            state.vars.(fldnm{1}) = expand_vars(variable(2), state.vars);
        end
        line = fgetl(fid);
    end
    frewind(fid);
    
    % Parse all rules
    state.rules = [];
    line = fgetl(fid);
    while (ischar(line))
        line = strip_comments(line);
        
        % Check for a : that's missing the =
        rule = regexp(line, '^\s*(\S.*):(?!=)(.*)$', 'tokens', 'once');
        if (length(rule) >= 1)
            loc = length(state.rules)+1;
            state.rules(loc).target = strread(expand_vars(rule(1), state.vars), '%s');
            state.rules(loc).deps   = strread(expand_vars(rule(2), state.vars), '%s');
            
            % And check the next line for a rule
            line = fgetl(fid);
            state.rules(loc).commands = {};
            while (ischar(line) && ~isempty(regexp(line, '^(\t|\s\s\s\s)', 'once')))
                cmdloc = length(state.rules(loc).commands)+1;
                state.rules(loc).commands{cmdloc} = strtrim(line);
                line = fgetl(fid);
            end
        else
            line = fgetl(fid);
        end
    end
    
    % cleanup
    fclose(fid);
end

function out = strip_comments(str)
    loc = strfind(str, '#');
    if(loc)
        out = str(1:loc(1)-1);
    else
        out = str;
    end
end

function out = expand_vars(value, vars)
    if (isempty(value))
        out = value;
        return;
    end

    if (iscell(value))
        value = value{1};
    end
    
    [startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(value, '\$[{(]([A-Za-z]\w*)[})]'); % TODO: Disallow ${ASDF)

    if (startIndex)
        out = '';
        for i=1:length(startIndex)
            if (isfield(vars,tokenStr{i}))
                fldnm = tokenStr{i};
                replStr = vars.(fldnm{1});
            else
                replStr = '';
            end
            out = strcat(out, splitStr{i}, replStr);
        end
        out = strcat(out, splitStr{i+1});
    else
        out = value;
    end
end

function out = expand_auto_vars(cmds, ruleset, pattern)
    all_deps = strcat(ruleset.deps, {' '});
    all_deps = all_deps{:};
    if (isempty(ruleset.deps))
        first_dep = ruleset.deps;
    else
        first_dep = ruleset.deps{1};
    end
    
    unique_deps = str_unique(ruleset.deps);
    cmds = regexprep(cmds, '(\$\@|\$\{\@\}|\$\(\@\))', ruleset.target);
    cmds = regexprep(cmds, '(\$<|\$\{<\}|\$\(<\))', first_dep);
    cmds = regexprep(cmds, '(\$\^|\$\{\^\}|\$\(\^\))', unique_deps);
    cmds = regexprep(cmds, '(\$\+|\$\{\+\}|\$\(\+\))', all_deps);
    cmds = regexprep(cmds, '(\$\*|\$\{\*\}|\$\(\*\))', pattern);
    
    out = cmds;
end

function out = str_unique(cell_arry)
    out = char(cell_arry) + 0;
    out = cellstr(char(unique(out, 'rows')));
end

function out = find_matching_rules(target, ruleset)
    out = [];
    target = strtrim(target);
    for i=1:length(ruleset)
        regex = cell(size(ruleset(i).target));
        for j = 1:length(regex)
            regex{j} = regexptranslate('wildcard', ruleset(i).target{j});
        end
        regex = strcat('^', regex, '$');
        match_idx = 0;
        pattern = '';
        if (strfind(regex{1}, '%'))
            % Percent matching only supported on single targets.
            regex = strrep(regex{1}, '%', '(\S+)');
            result = regexp(target, regex, 'tokens', 'once');
            if (~isempty(result))
                match_idx = 1;
                pattern = result{1};
            end
        else
            result = regexp(target, regex, 'once');
            match_idx = find(~cellfun(@isempty, result),1,'first');
        end
        if (match_idx > 0)
            loc = length(out) + 1;
            out(loc).target = target;                                      %#ok<AGROW>
            out(loc).deps = strrep(ruleset(i).deps, '%', pattern);         %#ok<AGROW>
            out(loc).commands = expand_auto_vars(ruleset(i).commands, out(loc), pattern); %#ok<AGROW>
        end
    end
end

