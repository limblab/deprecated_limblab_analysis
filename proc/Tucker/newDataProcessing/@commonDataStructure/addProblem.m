function addProblem(cds,problem)
    %this is a method function for the common_data_structure (cds) class, and
    %should be located in a folder '@common_data_structure' with the class
    %definition file and other method files
    %
    %this function accepts a string and adds that string to the
    %cds.meta.knownProbelems property
    meta=cds.meta;
    meta.knownProblems(end+1)={problem};
    set(cds,'meta',meta)
end