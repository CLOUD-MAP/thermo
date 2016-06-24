%Used for analyzing attitude data from a PX4/Pixhawk autopilot system
%Also provides a method of wind speed estimation for a PX4/Pixhawk on a 3DR Iris+
%Wind data is retrieved from Oklahoma Mesonet

%Written by Dr. Phillip Chilson and Austin Dixon
clear all
clc

%Enter date of flight
procYear = 2016;
procMonth = 6;
procDay = 22;


procStation = 'nwc'; %four letter name of mesonet site being used
fetchFlag = 1;
%% User inputs

% *** You will need to change the baseDir for your computer
% This is where your 'thermo' folder lives
baseDir = '/users/ErinBurns/Desktop/CLOUDMAP/GITHUB/';

%% Read in the data
% Here, the subroutine 'getDataDir' needs to be in your current folder
% 'gps2jd' and 'jd2cal' are also needed for later time conversions

dataRead = true;
sensorType = 'Solo';
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
rollATT_deg = ATT(:, 4); % Deflection in degrees from x-axis (Rotation about y-axis)
pitchATT_deg = ATT(:, 6); % Deflection in degrees from y-axis (Rotation about x-axis)
yawATT_deg = ATT(:, 8); % Rotation about the z-axis (Azimuth)

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

%% Read in the data
% Create the directory of the matlab library and add it to the path
libDir = [ baseDir 'thermo' filesep 'matlab' filesep ]; 
addpath(libDir)

rmpath(libDir)

%% Process the data
% Desired start and stop time (UTC) for plotting using copter GPS epoch
% timestamp conversion
timeBeg = timeATT(1,1);
timeEnd = timeATT(end, 1);

% Find the indices corresponding to the chosen ranges of time
indIris = find(timeBeg <= timeATT & timeATT <= timeEnd);

figure(1)
clf
plot(timeGPS, altGPS_m)
xlabel('Time UTC')
ylabel('Height AGL (m)')
datetick('x', 13)
shg

fprintf('Click start and end time\n')
[x, ~] = ginput(2);
timeBeg = x(1);
timeEnd = x(2);
% Find the indices corresponding to the chosen ranges of time
indIris = find(timeBeg <= timeATT & timeATT <= timeEnd);
indGPS = find(timeBeg <= timeGPS & timeGPS <= timeEnd);

%% create the plots

% 2D altitude vs time from the GPS
figure(1)
clf
plot(timeGPS(indGPS), altGPS_m(indGPS))
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
plot(timeATT(indIris), rollATT_deg(indIris), '-*')
xlabel('Time UTC')
ylabel('Roll (Deg)')
datetick('x', 13)
shg

% Pitch angle vs time
figure(4)
clf
plot(timeATT(indIris), pitchATT_deg(indIris), '-*')
xlabel('Time UTC')
ylabel('Pitch (Deg)')
datetick('x', 13)
shg

% Yaw angle vs time
figure(5)
clf
plot(timeATT(indIris), yawATT_deg(indIris), '*')
xlabel('Time UTC')
ylabel('Yaw (Deg) (North=0)')
datetick('x', 13)
shg

% Calculated inclination angle vs time
figure(6)
clf
plot(timeATT(indIris), psi_deg(indIris), '-*')
xlabel('Time UTC')
ylabel('Inclination Angle (Deg)')
datetick('x', 13)
shg

% Calculated wind speed estimate w/ mesonet data vs time
figure(7)
clf
plot(timeATT(indIris), windSpeed_mps(indIris), '-r')
xlabel('Time UTC')
ylabel('Wind Speed (m/s)')
datetick('x', 13)
shg

figure(8)
clf
plot(timeATT(indIris), windDirection_deg(indIris), 'r')
xlabel('Time UTC')
ylabel('Wind Direction (deg)')
datetick('x', 13)
