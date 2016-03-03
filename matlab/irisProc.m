% Description of the code
clc

%% User inputs

% *** You will need to change the baseDir for your computer
% This is where your 'thermo' folder lives
baseDir = '/users/austindixon/Documents/CLOUDMAP/';

procYear = 2016;
procMonth = 2;
procDay = 12;
sensorType = 'iris+';
dataRead = true;

%% Read in the data
if dataRead
    % Create the directory of the matlab library and add it to the path
    libDir = [ baseDir 'thermo' filesep 'matlab' filesep ];
    addpath(libDir)
    
    % Find the appropriate directory based on instrument type
    dirName = getDataDir(baseDir, procYear, procMonth, procDay, sensorType);
    
    % Interactively choose the file name
    % First see if files exist
    d = dir([ dirName '*.mat' ]);
    if isempty(d)
        fprintf('*** File not available ... exiting!\n')
        return
    end
    [fileName, dirName] = uigetfile([ dirName '*.mat' ], 'Pick a data file or click Cancel to exit');
    if isequal(fileName, 0) || isequal(dirName, 0)
        fprintf('*** Operation cancelled ... exiting!\n')
        return
    end
    
    % Find the appropriate directory based on instrument type
    dirName = getDataDir(baseDir, procYear, procMonth, procDay, sensorType);
    
    % Remove the matlab library
    rmpath(libDir)
    
    load([ dirName fileName])
end

%% Plot

%define necessary GPS variables
plotTimeGPS = GPS(:, 2);
plotAlt = GPS(:, 10);
plotLat = GPS(:, 8);
plotLon = GPS(:, 9);

%define attitude variables
plotTimeATT = ATT(:, 2);
plotRoll = ATT(:, 4);
plotPitch = ATT(:, 6);
plotYaw = ATT(:, 8);

%flag data errors
plotAlt(plotAlt < 0) = NaN;
plotLon(plotLon == 0) = NaN;
plotLat(plotLat == 0) = NaN;

%create the plots
figure(1)
plot(plotTimeGPS, plotAlt)
xlabel('TimeUS')
ylabel('Height AGL (m)')
shg

figure(2)
plot3(plotLat, plotLon, plotAlt)
xlabel('Lat')
ylabel('Lon')
zlabel('Height AGL (m)')
shg

figure(3)
plot(plotTimeATT, plotRoll)
xlabel('TimeUS')
ylabel('Roll (Deg)')

figure(4)
plot(plotTimeATT, plotPitch)
xlabel('TimeUS')
ylabel('Pitch (Deg)')