%% Initialization
% Clear the screen for kicks
clc
% Clear the memory
clear all

% Set up the inputs
procYear = 2015;
procMonth = 12;
procDay = 04;

%% Local adjustments
% *** You will need to change the baseDir for your computer
% This is where your 'thermo' folder lives
baseDir = '/users/chilson/Matlab/CLOUDMAP/';

% Create the directory of the matlab library and add it to the path
libDir = [ baseDir filesep 'thermo' filesep 'matlab' filesep ]; 
addpath(libDir)

%% iMet data

sensorType = 'iMet';

dataDir = getDataDir(baseDir, procYear, procMonth, procDay, sensorType);

diMet = dir([ dataDir '*.mat' ]);
nFilesiMet = length(diMet);
for iFile = 1: nFilesiMet
    load([ dataDir diMet(iFile).name ])
    dataXQArr(iFile) = dataXQ;
end

%% Windsond data

sensorType = 'Windsond';

dataDir = getDataDir(baseDir, procYear, procMonth, procDay, sensorType);

d = dir([ dataDir '*.mat' ]);
nFiles = length(d);
for iFile = 1: nFiles
    load([ dataDir d(iFile).name ])
    windsondArr(iFile) = windsond;
end

%% Clean up
% Remove the matlab library
rmpath(libDir)

ind1 = 1;
ind2 = 5;

figure(1)
clf
semilogy(windsondArr(ind1).temperature_C, windsondArr(ind1).pressure_Pa, 'b')
hold on
semilogy(windsondArr(ind2).temperature_C, windsondArr(ind2).pressure_Pa, 'r')
hold off
set(gca, 'ydir', 'reverse')

figure(2)
clf
plot(windsondArr(ind1).obsTime, windsondArr(ind1).altitude_m, 'b')
hold on
plot(windsondArr(ind2).obsTime, windsondArr(ind2).altitude_m, 'r')
hold off

