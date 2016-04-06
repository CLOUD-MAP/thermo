%function calcIrisAtt(procYear, procMonth, procDay) 
procYear = 2016;
procMonth = 3;
procDay = 31;

% clc
% switch nargin
%     case 0
%         DialogTitle = ('Enter Date of Flight');
%         Prompt = {'Year:', ...
%             'Month:', ...
%             'Day:'};
%         LineNo = 1;
%         
%         reply = inputdlg(Prompt, DialogTitle, LineNo);
%         
%         procYear = str2double(reply{1});
%         procMonth = str2double(reply{2});
%         procDay = str2double(reply{3});
        
%end

procStation = 'wash';
fetchFlag = 1;
%% User inputs

% *** You will need to change the baseDir for your computer
% This is where your 'thermo' folder lives
baseDir = '/users/austindixon/Documents/CLOUDMAP/';


%% Read in the data
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
plotTimeGPS = timeOffset + GPS(:, 2)/1e6/24/60/60;
plotAlt = GPS(:, 10);
plotLat = GPS(:, 8);
plotLon = GPS(:, 9);

%define attitude variables
plotTimeATT = timeOffset + ATT(:, 2)/1e6/24/60/60;
plotRoll = ATT(:, 4);
plotPitch = ATT(:, 6);
plotYaw = ATT(:, 8);

%flag data errors
plotAlt(plotAlt < 0) = NaN;
plotLon(plotLon == 0) = NaN;
plotLat(plotLat == 0) = NaN;

%% Calculate the angles
nVals = length(plotRoll);
ind = 1: nVals;
e_phi = zeros(3, nVals);
e_theta = zeros(3, nVals);
phi = plotRoll(ind);
theta = plotPitch(ind);
e_phi(2, :) = cosd(phi');
e_phi(3, :) = sind(phi');
e_theta(1, :) = cosd(theta');
e_theta(3, :) = -sind(theta');
n_xy = repmat([0 0 1], nVals, 1)';

psi = acosd(dot(n_xy, cross(e_theta, e_phi, 1), 1));
plot(psi),shg

%calculate the Aproj

% L = .43; %length of copter in meters
% W = .30; %width of copter in meters
% 
% Aproj = (L * W)*psi;
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


%read in CSV files
fileName = sprintf('%4.4d%2.2d%2.2d.WASH.1min.csv', procYear, procMonth, procDay);
%fileName = '20160303.WASH.1min.csv';
[mts, status] = readCSVMesonetData(procYear, procMonth, procDay, fileName, dirName);

% if status
%     sensorType = 'Mesonet';
%     if strcmp(procStation, 'nwcm');
%         NWCFlag = true;
%     else
%         NWCFlag = false;
%     end
%     % Find the appropriate directory based on instrument type
%     mesoDirName = getDataDir(baseDir, procYear, procMonth, procDay, sensorType);
%     [mts, status] = readMTSData(mesoFileName, mesoDirName, NWCFlag);
% end

% Remove the matlab library
rmpath(libDir)

%% Process the data
% Desired start and stop time (UTC) for plotting 
timeBeg = plotTimeATT(1,1);
timeEnd = plotTimeATT(end, 1);

% Find the indices corresponding to the chosen ranges of time
indIris = find(timeBeg <= plotTimeATT & plotTimeATT <= timeEnd);
indMeso = find(timeBeg <= mts.obsTime & mts.obsTime <= timeEnd);

% Check for missing data in mesonet files
mts.windSpeed10m_mps(mts.windSpeed10m_mps < -99) = NaN;
%mts.pressure_Pa(mts.pressure_Pa < -99) = NaN;
%mts.temperature1p5m_C(mts.temperature1p5m_C < -99) = NaN;
%mts.humidity_perCent(mts.humidity_perCent < -99) = NaN;

% average the sensor data to be consisent with the 1-minute NWC mesonet
% data
nVals = length(indMeso);
plotTimeATTAvg = nan(nVals, 1);
psiAvg = nan(nVals, 1);

for iVal = 1: nVals
    plotTimeATTAvg(iVal) = mts.obsTime(indMeso(iVal));
    ind = find(plotTimeATTAvg(iVal) - 1/60/24 <= plotTimeATT & ...
        plotTimeATT <= plotTimeATTAvg(iVal));
    if isempty(ind)
        % we're good here
    else
        psiAvg(iVal) = nanmean(psi(ind));

    end
end

%% create the plots

figure(1)
plot(plotTimeGPS, plotAlt)
xlabel('Time UTC')
ylabel('Height AGL (m)')
datetick('x', 13)
shg

figure(2)
plot3(plotLat, plotLon, plotAlt)
xlabel('Lat')
ylabel('Lon')
zlabel('Height AGL (m)')
datetick('x', 13)
shg

figure(3)
plot(plotTimeATT, plotRoll, '-*')
xlabel('Time UTC')
ylabel('Roll (Deg)')
datetick('x', 13)
shg

figure(4)
plot(plotTimeATT, plotPitch, '-*')
xlabel('Time UTC')
ylabel('Pitch (Deg)')
datetick('x', 13)
shg

figure(5)
plot(plotTimeATT, plotYaw, '*')
xlabel('Time UTC')
ylabel('Yaw (Deg) (North=0)')
datetick('x', 13)
shg

figure(6)
plot(plotTimeATT, psi, '-*')
xlabel('Time UTC')
ylabel('Inclination Angle (Deg)')
datetick('x', 13)
shg

figure(7)
plot(plotTimeATTAvg, 15*sqrt(tand(psiAvg)))
hold on
plot(mts.obsTime(indMeso), mts.windSpeed10m_mps(indMeso))
hold off
datetick('x', 13)
shg