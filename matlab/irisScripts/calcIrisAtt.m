%Used for analyzing attitude data from a PX4/Pixhawk autopilot system
%Also provides a method of wind speed estimation for a PX4/Pixhawk on a 3DR Iris+
%Wind data is retrieved from Oklahoma Mesonet

%Written by Dr. Phillip Chilson and Austin Dixon


%Enter date of flight
procYear = 2016;
procMonth = 2;
procDay = 4;


procStation = 'wash'; %four letter name of mesonet site being used
fetchFlag = 1;
%% User inputs

% *** You will need to change the baseDir for your computer
% This is where your 'thermo' folder lives
baseDir = '/users/austindixon/Documents/CLOUDMAP/';


%% Read in the data
% Here, the subroutine 'getDataDir' needs to be in your current folder
% 'gps2jd' and 'jd2cal' are also needed for later time conversions

dataRead = true;
sensorType = 'iris+';
if dataRead
    % Create the directory of the matlab library and add it to the path
    libDir = [ baseDir 'thermo' filesep 'matlab' filesep ];
    addpath(libDir)
    
    % Find the appropriate directory based on instrument type
    dirName = getDataDir(baseDir, procYear, procMonth, procDay, sensorType);
    
    
    % Interactively choose the file namecl
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
    
    % Remove the matlab library
    rmpath(libDir)
end

%% Setup plotting parameters

%define necessary GPS variables
TimeGPS = timeOffset + GPS(:, 2)/1e6/24/60/60;
Alt = GPS(:, 10);
Lat = GPS(:, 8);
Lon = GPS(:, 9);

% Define copter attitude (orientation) variables
% Here the front of the copter is defined as the positive y direction
% The right side of the copter is the positive x direction

TimeATT = timeOffset + ATT(:, 2)/1e6/24/60/60; % GPS epoch UTC conversion
Roll = ATT(:, 4); % Deflection in degrees from x-axis (Rotation about y-axis)
Pitch = ATT(:, 6); % Deflection in degrees from y-axis (Rotation about x-axis)
Yaw = ATT(:, 8); % Rotation about the z-axis (Azimuth)

%flag data errors
Alt(Alt < 0) = NaN;
Lon(Lon == 0) = NaN;
Lat(Lat == 0) = NaN;

%% Calculate the necessary angles using wind triangle theory/equations

nVals = length(Roll);
ind = 1: nVals;
e_phi = zeros(3, nVals);
e_theta = zeros(3, nVals);
phi = Roll(ind);
theta = Pitch(ind);
e_phi(2, :) = cosd(phi');
e_phi(3, :) = sind(phi');
e_theta(1, :) = cosd(theta');
e_theta(3, :) = -sind(theta');
n_xy = repmat([0 0 1], nVals, 1)';

psi = acosd(dot(n_xy, cross(e_theta, e_phi, 1), 1));
plot(psi),shg

%% parameters calculated in reference paper (not currently being used and may not be necessary)

%calculate the Aproj

% L = .43; %length of copter in meters
% W = .30; %width of copter in meters
% 
% Aproj = (L * W)*psi; %copter is approximated as a rectangle
% 
% %calculate drag force Fd
% g = 9.8; %acceleration due to gravity
% m = 1.3; %mass of copter in kg
% 
% Fd = g*m*tan(psi);

%% Read in the data
% Create the directory of the matlab library and add it to the path
libDir = [ baseDir 'thermo' filesep 'matlab' filesep ]; 
addpath(libDir)

sensorType = 'Mesonet';

% Find the appropriate data directory based on instrument type
dirName = getDataDir(baseDir, procYear, procMonth, procDay, sensorType);


% read in CSV mesonet data files
fileName = sprintf('%4.4d%2.2d%2.2d.WASH.1min.csv', procYear, procMonth, procDay);
[mts, status] = readCSVMesonetData(procYear, procMonth, procDay, fileName, dirName);

rmpath(libDir)

%% Process the data
% Desired start and stop time (UTC) for plotting using copter GPS epoch
% timestamp conversion
timeBeg = TimeATT(1,1);
timeEnd = TimeATT(end, 1);

% Find the indices corresponding to the chosen ranges of time
indIris = find(timeBeg <= TimeATT & TimeATT <= timeEnd);
indMeso = find(timeBeg <= mts.obsTime & mts.obsTime <= timeEnd);

% Check for missing data in mesonet files
mts.windSpeed10m_mps(mts.windSpeed10m_mps < -99) = NaN;

% average the copter data to be consisent with the 1-minute NWC mesonet
% data
nVals = length(indMeso);
TimeATTAvg = nan(nVals, 1);
psiAvg = nan(nVals, 1);

for iVal = 1: nVals
    TimeATTAvg(iVal) = mts.obsTime(indMeso(iVal));
    ind = find(TimeATTAvg(iVal) - 1/60/24 <= TimeATT & ...
        TimeATT <= TimeATTAvg(iVal));
    if isempty(ind)
        % we're good here
    else
        psiAvg(iVal) = nanmean(psi(ind));

    end
end

%% calculate error between copter and mesonet

windErr = abs(mts.windSpeed10m_mps(indMeso)-(13*sqrt(tand(psiAvg))));


%% create the plots

% 2D altitude vs time from the GPS
figure(1)
plot(TimeGPS, Alt)
xlabel('Time UTC')
ylabel('Height AGL (m)')
datetick('x', 13)
shg

% 3D altitude with Latitude & Longitude
figure(2)
plot3(Lat, Lon, Alt)
xlabel('Lat')
ylabel('Lon')
zlabel('Height AGL (m)')
datetick('x', 13)
shg

% Roll angle vs time
figure(3)
plot(TimeATT, Roll, '-*')
xlabel('Time UTC')
ylabel('Roll (Deg)')
datetick('x', 13)
shg

% Pitch angle vs time
figure(4)
plot(TimeATT, Pitch, '-*')
xlabel('Time UTC')
ylabel('Pitch (Deg)')
datetick('x', 13)
shg

% Yaw angle vs time
figure(5)
plot(TimeATT, Yaw, '*')
xlabel('Time UTC')
ylabel('Yaw (Deg) (North=0)')
datetick('x', 13)
shg

% Calculated inclination angle vs time
figure(6)
plot(TimeATT, psi, '-*')
xlabel('Time UTC')
ylabel('Inclination Angle (Deg)')
datetick('x', 13)
shg

% Calculated wind speed estimate w/ mesonet data vs time
figure(7)
plot(TimeATT, 13*sqrt(tand(psi)))
hold on
plot(mts.obsTime(indMeso), mts.windSpeed10m_mps(indMeso))
hold off
xlabel('Time UTC')
ylabel('Wind Speed (m/s)')
datetick('x', 13)
shg

% Calculated error between estimated wind & mesonet
figure(8)
plot(TimeATTAvg, windErr)
xlabel('Time UTC')
ylabel('Wind Estimation Error (m/s)')
datetick('x', 13)
shg
