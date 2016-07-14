clear all
clc

%Enter date of flight
procYear = 2016;
procMonth = 6;
procDay = 29;

imgFlag = true;

sampleHeights_m = 10: 10: 300;
deltaHeight_m = 10;

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

windSpeedCoeff_mps = 14*ones(size(yaw_deg));
% Parameter obtained experimentally to calculate the wind speed
ind = find(yaw_deg <= 50 | yaw_deg >= 300);
windSpeedCoeff_mps(ind) = 14;

windSpeed_mps = windSpeedCoeff_mps.*sqrt(tand(psi_deg));
windDirection_deg = az_deg;

ind1 = find(windDirection_deg < 0);
ind2 = find(windDirection_deg > 360);
windDirection_deg(ind1) = windDirection_deg(ind1) + 360;
windDirection_deg(ind2) = windDirection_deg(ind2) - 360;

% calculate u & v
u_mps = windSpeed_mps.*sind(windDirection_deg);
v_mps = windSpeed_mps.*cosd(windDirection_deg);


%% Process the data
% Desired start and stop time (UTC) for plotting using copter GPS epoch
% timestamp conversion
timeBeg = timeATT(1,1);
timeEnd = timeATT(end, 1);

% Find the indices corresponding to the chosen ranges of time
indGPS = find(timeBeg <= timeGPS & timeGPS <= timeEnd);

figure(1)
clf
plot(timeGPS(indGPS), altGPS_m(indGPS))
xlabel('Time UTC')
ylabel('Height AGL (m)')
datetick('x', 13)
title(sprintf('%s', datestr(timeBeg, 1)))
shg

fprintf('Click start, max, and end time\n')
[x, ~] = ginput(3);
timeTakeoff = x(1);
timeMax = x(2);
timeLand = x(3);
if (timeMax < timeBeg || timeMax > timeEnd), timeMax = nan; end

indATTAsc = find(timeTakeoff <= timeATT & timeATT <= timeMax);
procTimeAsc = timeATT(indATTAsc);
heightAsc_m = interp1(timeGPS(indGPS), altGPS_m(indGPS), procTimeAsc);

indATTDes = find(timeMax <= timeATT & timeATT <= timeLand);
procTimeDes = timeATT(indATTDes);
heightDes_m = interp1(timeGPS(indGPS), altGPS_m(indGPS), procTimeDes);

nHeights = length(sampleHeights_m);
uAvgAsc_mps = nan(1, nHeights);
vAvgAsc_mps = nan(1, nHeights);
uAvgDes_mps = nan(1, nHeights);
vAvgDes_mps = nan(1, nHeights);

fprintf('Takeoff Time (UTC): %s\n', datestr(timeTakeoff))
fprintf('Land Time (UTC): %s\n', datestr(timeLand))
%fprintf('Ht (m)     u  Asc (C) v  Asc (C) u  Des (C) v  Des (C)\n')
for iHeight = 1: nHeights
    ind = find(sampleHeights_m(iHeight) - deltaHeight_m/2 <= heightAsc_m & ...
        heightAsc_m <= sampleHeights_m(iHeight) + deltaHeight_m/2);
    uAvgAsc_mps(iHeight) = nanmean(u_mps(indATTAsc(ind)));
    vAvgAsc_mps(iHeight) = nanmean(v_mps(indATTAsc(ind)));
    ind = find(sampleHeights_m(iHeight) - deltaHeight_m/2 <= heightDes_m & ...
        heightDes_m <= sampleHeights_m(iHeight) + deltaHeight_m/2);
    uAvgDes_mps(iHeight) = nanmean(u_mps(indATTDes(ind)));
    vAvgDes_mps(iHeight) = nanmean(v_mps(indATTDes(ind)));
    
%     fprintf('%9d  %9.1f  %9.1f  %9.1f  %9.1f\n', ...
%         sampleHeights_m(iHeight), temperatureAvgAsc1_C(iHeight), temperatureAvgAsc2_C(iHeight), ...
%         temperatureAvgDes1_C(iHeight), temperatureAvgDes2_C(iHeight))
end

windSpeedAvgAsc_mps = sqrt(uAvgAsc_mps.^2 + vAvgAsc_mps.^2);
windDirectionAvgAsc_deg = atan2d(uAvgAsc_mps, vAvgAsc_mps);
windSpeedAvgDes_mps = sqrt(uAvgDes_mps.^2 + vAvgDes_mps.^2);
windDirectionAvgDes_deg = atan2d(uAvgDes_mps, vAvgDes_mps);

ind1 = find(windDirectionAvgAsc_deg < 0);
ind2 = find(windDirectionAvgAsc_deg > 360);
windDirectionAvgAsc_deg(ind1) = windDirectionAvgAsc_deg(ind1) + 360;
windDirectionAvgAsc_deg(ind2) = windDirectionAvgAsc_deg(ind2) - 360;

ind1 = find(windDirectionAvgDes_deg < 0);
ind2 = find(windDirectionAvgDes_deg > 360);
windDirectionAvgDes_deg(ind1) = windDirectionAvgDes_deg(ind1) + 360;
windDirectionAvgDes_deg(ind2) = windDirectionAvgDes_deg(ind2) - 360;

figure(2)
clf
plot(uAvgAsc_mps, sampleHeights_m, '-^r')
hold on
plot(vAvgAsc_mps, sampleHeights_m, '-^b')
plot(uAvgDes_mps, sampleHeights_m, '-vr')
plot(vAvgDes_mps, sampleHeights_m, '-vb')
hold on
%set(gca, 'xlim', [20 30])
%set(gca, 'ylim', [0 620])
set(gca, 'fontsize', 15)
xlabel('Wind Direction (deg)')
xlabel('Velocity (mps)')
ylabel('Height AGL (m)')
title(sprintf('%s: %s - %s', datestr(timeTakeoff, 1), datestr(timeTakeoff, 13), datestr(timeLand, 13)))
shg

lineWidth = 1;
markerSize = 10;
heightRange_m = [0 sampleHeights_m(end)];
windSpeedRange_mps = [0 10];
windDirectionRange_deg = [0 360];
fontSize = 15;
plotLineWidth = 1.5;

figure(3)
clf
subplot(1, 2, 1)
plot(windSpeedAvgAsc_mps, sampleHeights_m, '-^r', ...
    'linewidth', lineWidth)
hold on
plot(windSpeedAvgDes_mps, sampleHeights_m, '-vb', ...)
    'linewidth', lineWidth)
hold off
set(gca, 'xlim', windSpeedRange_mps)
set(gca, 'ylim', heightRange_m)
set(gca, 'linewidth', plotLineWidth)
set(gca, 'fontsize', fontSize)
xlabel('Wind Speed (m/s)')
ylabel('Height AGL (m)')
subplot(1, 2, 2)
plot(windDirectionAvgAsc_deg, sampleHeights_m, '-^r', ...)
    'linewidth', lineWidth)
hold on
plot(windDirectionAvgDes_deg, sampleHeights_m, '-vb', ...
    'linewidth', lineWidth)
hold off
set(gca, 'xlim', windDirectionRange_deg)
set(gca, 'ylim', heightRange_m)
set(gca, 'linewidth', plotLineWidth)
set(gca, 'fontsize', fontSize)
xlabel('Wind Direction (deg)')
suptitle(sprintf('%s: %s - %s', datestr(timeTakeoff, 1), datestr(timeTakeoff, 13), datestr(timeLand, 13)))
shg

if imgFlag
    imgFileName = strrep(fileName, '.mat', '_wind.png');
    fprintf('Creating image file: %s\n', imgFileName)
    print([ './imgs/' imgFileName ], '-dpng');
end
