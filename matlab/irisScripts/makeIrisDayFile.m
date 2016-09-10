%Used for analyzing attitude data from a PX4/Pixhawk autopilot system
%Also provides a method of wind speed estimation for a PX4/Pixhawk on a 3DR Iris+
%Wind data is retrieved from Oklahoma Mesonet

%Written by Dr. Phillip Chilson and Austin Dixon
clear all
clc

%Enter date of flight
procYear = 2016;
procMonth = 9;
procDay = 9;

%% User inputs

% *** You will need to change the baseDir for your computer
% This is where your 'thermo' folder lives
baseDir = '/users/chilson/Matlab/CLOUDMAP/';

%% Read in the data
% Here, the subroutine 'getDataDir' needs to be in your current folder
% 'gps2jd' and 'jd2cal' are also needed for later time conversions

dataRead = true;
sensorType = 'iris+';
dateString = sprintf('%4.4d%2.2d%2.2d', procYear, procMonth, procDay);

% Create the directory of the matlab library and add it to the path
libDir = [ baseDir 'thermo' filesep 'matlab' filesep ];
addpath(libDir)

% Find the appropriate directory based on instrument type
dirName = getDataDir(baseDir, procYear, procMonth, procDay, sensorType);

% Get file names and check if directory is empty
d = dir([ dirName dateString '_*.mat' ]);
if isempty(d)
    fprintf('*** File not available ... exiting!\n')
    return
end

nFiles = length(d);

indOffsetGPS = 0;
indOffsetATT = 0;
indOffsetBARO = 0;
indOffsetCURR = 0;

for iFile = 1: nFiles
    fileName = d(iFile).name;
    fprintf('Loading file: %s\n', fileName)
    load([ dirName fileName])
    
    % Setup the time information    
    % Find the year, month, and day of the first data point in the GPS array
    % This is what we will call the reference time
    % Note that the time is captured in obsDay as a fraction
    [obsYear, obsMonth, obsDay] = jd2cal(gps2jd(GPS(1, 5), GPS(1, 4)/1e3, 0));
    % Find the reference time in Matlab format
    refTime = datenum(obsYear, obsMonth, obsDay);
    % Find the time offset to be used when converting time in us to actual time
    timeOffset = refTime - GPS(1, 2)/1e6/24/60/60;

    % Extract GPS variables
    nGPS = length(GPS);
    indGPS = indOffsetGPS + (1: nGPS);
    iris.obsTimeGPS(indGPS) = timeOffset + GPS(:, 2)/1e6/24/60/60;
    iris.altitudeGPS_m(indGPS) = GPS(:, 10);
    iris.latitudeGPS_deg(indGPS) = GPS(:, 8);
    iris.longitudeGPS_deg(indGPS) = GPS(:, 9);
    indOffsetGPS = indOffsetGPS + nGPS;
    
    % Extract the ATT variable
    % Here the front of the copter (battery hatch is back) is defined as north
    % Positive pitch means nose up
    % Positive roll means right side down
    % Positive yaw means rotating towards east from north
    nATT = length(ATT);
    indATT = indOffsetATT + (1: nATT);
    iris.obsTimeATT(indATT) = timeOffset + ATT(:, 2)/1e6/24/60/60;
    iris.desiredRollATT_deg(indATT) = ATT(:, 3);
    iris.rollATT_deg(indATT) = ATT(:, 4);
    iris.desiredPitchATT_deg(indATT) = ATT(:, 5);
    iris.pitchATT_deg(indATT) = ATT(:, 6);
    iris.desiredYawATT_deg(indATT) = ATT(:, 7);
    iris.yawATT_deg(indATT) = ATT(:, 8);
    indOffsetATT = indOffsetATT + nATT;
    
    % Extract the barometer data
    nBARO = length(BARO);
    indBARO = indOffsetBARO + (1: nBARO);
    iris.obsTimeBARO(indBARO) = timeOffset + BARO(:, 2)/1e6/24/60/60;
    iris.altitudeBARO_m(indBARO) = BARO(:, 3);
    iris.pressureBARO_Pa(indBARO) = BARO(:, 4);
    iris.tempeatureBARO_C(indBARO) = BARO(:, 5);
    indOffsetBARO = indOffsetBARO + nBARO;
    
    % Extract the current data
    nCURR = length(CURR);
    indCURR = indOffsetCURR + (1: nCURR);
    iris.obsTimeCURR(indCURR) = timeOffset + CURR(:, 2)/1e6/24/60/60;
    iris.throttleCURR(indCURR) = CURR(:, 3)/1e3;
    iris.voltageCURR_V(indCURR) = CURR(:, 4)/1e2;
    iris.currentCURR_A(indCURR) = CURR(:, 5)/1e2;
    indOffsetCURR = indOffsetCURR + nCURR;
end
% Remove the matlab library
rmpath(libDir)

%flag data errors
iris.altitudeGPS_m(iris.altitudeGPS_m < 0) = NaN;
iris.longitudeGPS_deg(iris.longitudeGPS_deg == 0) = NaN;
iris.latitudeGPS_deg(iris.latitudeGPS_deg == 0) = NaN;

outFileName = sprintf('%4.4d%2.2d%2.2d.mat', procYear, procMonth, procDay);
fprintf('Saving file: %s\n', outFileName)
save([ dirName outFileName ], 'iris');
