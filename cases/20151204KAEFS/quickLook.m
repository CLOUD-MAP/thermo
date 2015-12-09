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
    iMetXQArr(iFile) = iMetXQ;
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

%% Set parameters

if 0
    ind1 = 1;
    ind2 = ind1 + 4;
    t1 = windsondArr(ind1).obsTime;
    t2 = windsondArr(ind2).obsTime;
    z1 = windsondArr(ind1).altitude_m;
    z2 = windsondArr(ind2).altitude_m;
    T1 = windsondArr(ind1).temperature_C;
    T2 = windsondArr(ind2).temperature_C;
    p1 = windsondArr(ind1).pressure_Pa;
    p2 = windsondArr(ind2).pressure_Pa;
end

if 1
    ind1 = 1;
    ind2 = 2;
    t1 = iMetXQArr(ind1).obsTime;
    t2 = iMetXQArr(ind2).obsTime;
    z1 = iMetXQArr(ind1).altitude_m;
    z2 = iMetXQArr(ind2).altitude_m;
    T1 = iMetXQArr(ind1).temperature_C;
    T2 = iMetXQArr(ind2).temperature_C;
    p1 = iMetXQArr(ind1).pressure_Pa;
    p2 = iMetXQArr(ind2).pressure_Pa;
end

%% Plot
figure(1)
clf
semilogy(T1, p1, 'b')
hold on
semilogy(T2, p2, 'r')
hold off
set(gca, 'ydir', 'reverse')

figure(2)
clf
plot(t1, p1, 'b')
hold on
plot(t2, p2, 'r')
hold off
datetick('x', 15)

figure(3)
clf
plot(t1, z1, 'b')
hold on
plot(t2, z2, 'r')
hold off
datetick('x', 15)
