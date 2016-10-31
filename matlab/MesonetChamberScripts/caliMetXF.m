% Used to begin evaluating iMetXF sensors placed in the Oklahoma Mesonet
% Chamber

clc
clear all

%% User inputs

%Enter begin date of the calibration
procYear = 2016;
procMonth = 8;
procDay = 30;

% *** You will need to change the baseDir for your computer
% This is where your 'thermo' folder lives
baseDir = '/users/chilson/Matlab/CLOUDMAP/';

%% Read in the data
% Create the directory of the matlab library and add it to the path
libDir = [ baseDir 'thermo' filesep 'matlab' filesep ];
addpath(libDir)

% ============================================================
% iMet sensors
% ============================================================
sensorType = 'iMetSolo';
% Find the appropriate directory based on instrument type
dirName = getDataDir(baseDir, procYear, procMonth, procDay, sensorType);

% Interactively choose the file name
% First see if files exist
d = dir([ dirName '*.csv' ]);
if isempty(d)
    fprintf('*** File not available ... exiting!\n')
    return
end
[fileName, dirName] = uigetfile([ dirName '*.csv' ], 'Pick a data file or click Cancel to exit');
if isequal(fileName, 0) || isequal(dirName, 0)
    fprintf('*** Operation cancelled ... exiting!\n')
    return
end

fprintf('Calling readiMetXF with %s\n', [dirName fileName])
[iMetXF, status] = readiMetXF(dirName, fileName);

% ============================================================
% Calibration chamber sensors
% ============================================================
sensorType = 'MesonetChamber';
% Find the appropriate directory based on instrument type
dirName = getDataDir(baseDir, procYear, procMonth, procDay, sensorType);

% Interactively choose the file name
% First see if files exist
d = dir([ dirName '*.dat' ]);
if isempty(d)
    fprintf('*** File not available ... exiting!\n')
    return
end
[fileName, dirName] = uigetfile([ dirName '*.dat' ], 'Pick a data file or click Cancel to exit');
if isequal(fileName, 0) || isequal(dirName, 0)
    fprintf('*** Operation cancelled ... exiting!\n')
    return
end

fprintf('Calling readMesonetChamber with %s\n', [dirName fileName])
[mesonetChamber, status] = readMesonetChamber(dirName, fileName);

% Remove the matlab library
rmpath(libDir)

%% Generate quick look plot

% Assign some "by eye" offsets
offsetA_C = -0.3; % black
offsetB_C = -0.1; % blue
offsetC_C = -0.1; % red
offsetD_C = -0.1; % green

figure(1)
clf
plot(iMetXF.obsTime, iMetXF.temperatureA_C + offsetA_C,'-k')
hold on
plot(iMetXF.obsTime, iMetXF.temperatureB_C + offsetB_C,'-b')
plot(iMetXF.obsTime, iMetXF.temperatureC_C + offsetC_C,'-r')
plot(iMetXF.obsTime, iMetXF.temperatureD_C + offsetD_C,'-g')
plot(mesonetChamber.obsTime, mesonetChamber.temperatureFluke5610_C, '-k', 'linewidth', 1.5)
plot(mesonetChamber.obsTime, mesonetChamber.temperatureFastTherm_C, '-b', 'linewidth', 1.5)
hold off
datetick('x', 15)
xlabel('Time (UTC)')
ylabel('Temperature (C)')
shg
%print('readiMetXF.png', '-dpng')
