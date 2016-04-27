%Used for analyzing attitude data from a PX4/Pixhawk autopilot system
%Also provides a method of wind speed estimation for a PX4/Pixhawk on a 3DR Iris+
%Wind data is retrieved from Oklahoma Mesonet

%Written by Dr. Phillip Chilson and Austin Dixon
clear all
clc

%Enter date of flight
procYear = 2016;
procMonth = 4;
procDay = 22;


procStation = 'wash'; %four letter name of mesonet site being used
fetchFlag = 1;
%% User inputs

% *** You will need to change the baseDir for your computer
% This is where your 'thermo' folder lives
baseDir = '/users/chilson/Matlab/CLOUDMAP/';

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
timeGPS = timeOffset + GPS(:, 2)/1e6/24/60/60;
altGPS_m = GPS(:, 10);
latGPS_deg = GPS(:, 8);
lonGPS_deg = GPS(:, 9);

% Define copter attitude (orientation) variables
% Here the front of the copter is defined as the positive y direction
% The right side of the copter is the positive x direction

timeATT = timeOffset + ATT(:, 2)/1e6/24/60/60; % GPS epoch UTC conversion
% Calculation with measured angles
rollATT_deg = ATT(:, 4); % Deflection in degrees from x-axis (Rotation about y-axis)
pitchATT_deg = ATT(:, 6); % Deflection in degrees from y-axis (Rotation about x-axis)
yawATT_deg = ATT(:, 8); % Rotation about the z-axis (Azimuth)
% Calculation with desired angles
% rollATT_deg = ATT(:, 3); % Deflection in degrees from x-axis (Rotation about y-axis)
% pitchATT_deg = ATT(:, 5); % Deflection in degrees from y-axis (Rotation about x-axis)
% yawATT_deg = ATT(:, 7); % Rotation about the z-axis (Azimuth)

%flag data errors
altGPS_m(altGPS_m < 0) = NaN;
lonGPS_deg(lonGPS_deg == 0) = NaN;
latGPS_deg(latGPS_deg == 0) = NaN;

%% Calculate the necessary angles using wind triangle theory/equations

nVals = length(rollATT_deg);
ind = 1: nVals;
e_phi = zeros(3, nVals);
roll_deg = rollATT_deg(ind);
pitch_deg = pitchATT_deg(ind);
yaw_deg = yawATT_deg(ind);

psi_deg = zeros(nVals, 1);
az_deg = zeros(nVals, 1);
for j = 1: nVals
    crol = cosd(roll_deg(j));
    srol = sind(roll_deg(j));
    cpit = cosd(pitch_deg(j));
    spit = sind(pitch_deg(j));
    cyaw = cosd(yaw_deg(j));
    syaw = sind(yaw_deg(j));
    Rx = [[1 0 0]; ...
        [0 crol srol]; ...
        [0 -srol crol]];
    Ry = [[cpit 0 -spit]; ...
        [0 1 0]; ...
        [spit 0 cpit]];
    Rz = [[cyaw -syaw 0]; ...
        [syaw cyaw 0]; ...
        [0 0 1]];
        R = Rz*Ry*Rx;
        vectorRot = R*[0; 0; 1];
        % Inclination angle
        psi_deg(j) = acosd(dot([0; 0; 1], vectorRot));
        az_deg(j) = atan2d(vectorRot(2), vectorRot(1));
end
if az_deg < 0, az_deg = az_deg + 360; end


% Parameter obtained experimentally to calculate the wind speed
windSpeedCoeff_mps = 14;
windSpeed_mps = windSpeedCoeff_mps.*sqrt(tand(psi_deg));
windDirection_deg = az_deg;

ind1 = find(windDirection_deg < 0);
ind2 = find(windDirection_deg > 360);
windDirection_deg(ind1) = windDirection_deg(ind1) + 360;
windDirection_deg(ind2) = windDirection_deg(ind2) - 360;

% calculate u & v
u_mps = windSpeed_mps.*sind(windDirection_deg);
v_mps = windSpeed_mps.*cosd(windDirection_deg);

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
timeBeg = timeATT(1,1);
timeEnd = timeATT(end, 1);

% Find the indices corresponding to the chosen ranges of time
indIris = find(timeBeg <= timeATT & timeATT <= timeEnd);
indMeso = find(timeBeg <= mts.obsTime & mts.obsTime <= timeEnd);

% Check for missing data in mesonet files
mts.windSpeed10m_mps(mts.windSpeed10m_mps < -99) = NaN;

% average the copter data to be consisent with the 1-minute NWC mesonet
% data
nValsAvg = length(indMeso);
timeATTAvg = nan(nValsAvg, 1);
uAvg_mps = nan(nValsAvg, 1);
vAvg_mps = nan(nValsAvg, 1);

for iVal = 1: nValsAvg
    timeATTAvg(iVal) = mts.obsTime(indMeso(iVal));
    ind = find(timeATTAvg(iVal) - 1/60/24 <= timeATT & ...
        timeATT <= timeATTAvg(iVal));
    if isempty(ind)
        % we're good here
    else
        uAvg_mps(iVal) = nanmean(u_mps(ind));
        vAvg_mps(iVal) = nanmean(v_mps(ind));
    end
end

windSpeedAvg_mps = sqrt(uAvg_mps.^2 + vAvg_mps.^2);
windDirectionAvg_deg = atan2d(uAvg_mps, vAvg_mps);

ind1 = find(windDirectionAvg_deg < 0);
ind2 = find(windDirectionAvg_deg > 360);
windDirectionAvg_deg(ind1) = windDirectionAvg_deg(ind1) + 360;
windDirectionAvg_deg(ind2) = windDirectionAvg_deg(ind2) - 360;

%% calculate error between copter and mesonet

windErr = abs(mts.windSpeed10m_mps(indMeso)-windSpeedAvg_mps);

%% create the plots

% 2D altitude vs time from the GPS
figure(1)
clf
plot(timeGPS, altGPS_m)
xlabel('Time UTC')
ylabel('Height AGL (m)')
datetick('x', 13)
shg

% 3D altitude with Latitude & Longitude
figure(2)
clf
plot3(latGPS_deg, lonGPS_deg, altGPS_m)
xlabel('Lat')
ylabel('Lon')
zlabel('Height AGL (m)')
datetick('x', 13)
shg

% Roll angle vs time
figure(3)
clf
plot(timeATT, rollATT_deg, '-*')
xlabel('Time UTC')
ylabel('Roll (Deg)')
datetick('x', 13)
shg

% Pitch angle vs time
figure(4)
clf
plot(timeATT, pitchATT_deg, '-*')
xlabel('Time UTC')
ylabel('Pitch (Deg)')
datetick('x', 13)
shg

% Yaw angle vs time
figure(5)
clf
plot(timeATT, yawATT_deg, '*')
xlabel('Time UTC')
ylabel('Yaw (Deg) (North=0)')
datetick('x', 13)
shg

% Calculated inclination angle vs time
figure(6)
clf
plot(timeATT, psi_deg, '-*')
xlabel('Time UTC')
ylabel('Inclination Angle (Deg)')
datetick('x', 13)
shg

% Calculated wind speed estimate w/ mesonet data vs time
figure(7)
clf
plot(timeATTAvg, windSpeedAvg_mps, '-r')
hold on
plot(mts.obsTime(indMeso), mts.windSpeed10m_mps(indMeso), '-b')
hold off
xlabel('Time UTC')
ylabel('Wind Speed (m/s)')
datetick('x', 13)
shg

% Calculated error between estimated wind & mesonet
figure(8)
clf
plot(timeATTAvg, windErr)
xlabel('Time UTC')
ylabel('Wind Estimation Error (m/s)')
datetick('x', 13)
shg

figure(9)
clf
plot(timeATTAvg, windDirectionAvg_deg, 'r')
hold on
plot(mts.obsTime(indMeso), mts.windDirection10m_deg(indMeso), '-b')
hold off
set(gca, 'ylim', [0 360]);
xlabel('Time UTC')
ylabel('Wind Direction (deg)')
datetick('x', 13)
