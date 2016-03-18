% load_paths.m
%
% Loads all of the necessary paths to run s1_analysis.  Should only be
% used once per session.

% Please do not add your proc directory to this file.  Create a load paths
% script in your proc directory if you need to.  This is to avoid filename
% conflicts between proc directories.

% $Id$

dirpath = pwd;

addpath(dirpath);

addpath([dirpath '/lib']);
addpath([dirpath '/lib/ml']);
addpath([dirpath '/lib/stats']);
addpath([dirpath '/lib/bootstrapping']);
addpath([dirpath '/lib/CircStat2012a']);
addpath([dirpath '/lib/glm']);
addpath(genpath([dirpath '/lib/NPMK 2.5.2.0']));
addpath([dirpath '/mimo']);
addpath([dirpath '/spike']);
addpath([dirpath '/bdf']);
addpath([dirpath '/bdf/event_decoders']);
addpath([dirpath '/bdf/lib_cb']);
addpath([dirpath '/bdf/lib_plx']);
addpath([dirpath '/bdf/lib_plx/core_files/']);
addpath([dirpath '/bdf/NEVNSx/']);
addpath([dirpath '/BMI_analysis']);


%the following loads the correct JDBC driver for accessing postgreSQL
%databases based on the JRE version in use. This allows the common data
%structure code to talk to the limblab database

if strfind(version('-java'),'Java 1.7')
    javaclasspath([dirpath,filesep,'database',filesep,'postgresql-9.4.1208.jre7.jar']);
elseif strfind(version('-java'),'Java 1.8')
    javaclasspath([dirpath,filesep,'database',filesep,'postgresql-9.4.1208.jar']);
else
    warning('loadPostgresqlPath:JDBCNotAvailable',['JDBC drivers not specced for JRE version: ',version('-java'), ' please find the correct driver at https://jdbc.postgresql.org/download.html dowload it to the limblab_analysis',filesep,'database',filesep,' folder and update this script to point to it'])
end

