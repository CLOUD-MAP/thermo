% This is just an example showing the use of getMesoFileCURL and
% readMTSData

% Clear the screen for kicks
clc
% Clear the memory
clear all

% Set up the inputs
procYear = 2015;
procMonth = 12;
procDay = 04;
procStation = 'wash';
sensorType = 'Mesonet';
% set batchFlag to 1 if mesonet data retrieved automatically (mac)
% set batchFlag to 0 if you will download the file by hand (PC)
batchFlag = 1;

% *** You will need to change the baseDir for your computer
% This is where your 'thermo' folder lives
baseDir = '/users/chilson/Matlab/CLOUDMAP/';

% Create the directory of the matlab library and add it to the path
libDir = [ baseDir filesep 'thermo' filesep 'matlab' filesep ]; 
addpath(libDir)

[matFileName, matDataDir, status] = mts2mat(procYear, procMonth, procDay, ...
    procStation, batchFlag, baseDir);

% Remove the matlab library
rmpath(libDir)

load([ matDataDir matFileName ])

% Write the data to a mat file
% Here we plot some data just because
% ------------------------------------------------
subplot(2, 1, 1)
% ------------------------------------------------
plot(mts.timeUTC, mts.solRad_Wpm2)
datetick('x', 15)
title(datestr(mts.timeUTC(1), 29))
ylabel('Solar Radiation (W m^{-2})')

% ------------------------------------------------
subplot(2,1,2)
% ------------------------------------------------
plot(mts.timeUTC, mts.temp1p5m_C)
datetick('x', 15)
xlabel('Time (UTC)')
ylabel('Temperature at 1.5 m (C)')

shg