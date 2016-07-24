%clear all
clc

%Enter date of flight
procYear = 2016;
procMonth = 6;
procDay = 30;

%% User inputs

% *** You will need to change the baseDir for your computer
% This is where your 'thermo' folder lives
baseDir = '/users/chilson/Matlab/CLOUDMAP/';

%% Read in the data
% Create the directory of the matlab library and add it to the path
libDir = [ baseDir 'thermo' filesep 'matlab' filesep ];
addpath(libDir)

sensorType = 'iMetSolo';
% Find the appropriate directory based on instrument type
dirName = getDataDir(procYear, procMonth, procDay, sensorType);

% Interactively choose the file namecl
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

nLarge = 5000;
obsTime = zeros(1, nLarge);
latitude_deg = zeros(1, nLarge);
longitude_deg = zeros(1, nLarge);
altitude_m = zeros(1, nLarge);
nSatellites = zeros(1, nLarge);
pressure_Pa = zeros(1, nLarge);
relativeHumidity_perCent = zeros(1, nLarge);
temperatureA_C = zeros(1, nLarge);
temperatureB_C = zeros(1, nLarge);
temperatureC_C = zeros(1, nLarge);
temperatureD_C = zeros(1, nLarge);

% Open the file
fp = fopen([ dirName fileName], 'rt');

% Read the header
%for j = 1: 29
%    str1 = fgetl(fp);
%end
iCnt = 1;
while ~feof(fp)
    str = fgetl(fp);
    ind = strfind(str, ',');
    if length(ind) == 22
        obsTime(iCnt) = datenum(str(ind(1)+1: ind(3)-1), 'yyyy/mm/dd,HH:MM:SS');
        latitude_deg(iCnt) = 1e-7*str2double(str(ind(7)+1: ind(8)-1));
        longitude_deg(iCnt) = 1e-7*str2double(str(ind(8)+1: ind(9)-1));
        altitude_m(iCnt) = 1e-3*str2double(str(ind(9)+1: ind(10)-1));
        nSatellites(iCnt) = str2double(str(ind(10)+1: ind(11)-1));
        pressure_Pa(iCnt) = str2double(str(ind(11)+1: ind(12)-1));
        relativeHumidity_perCent(iCnt) = 1e-2*str2double(str(ind(12)+1: ind(13)-1));
        temperatureA_C(iCnt) = 1e-2*str2double(str(ind(16)+1: ind(17)-1));
        temperatureB_C(iCnt) = 1e-2*str2double(str(ind(18)+1: ind(19)-1));
        temperatureC_C(iCnt) = 1e-2*str2double(str(ind(20)+1: ind(21)-1));
        temperatureD_C(iCnt) = 1e-2*str2double(str(ind(22)+1: end));
        iCnt = iCnt + 1;
    end
end
nVals = iCnt - 1;

iMetSolo.obsTime = obsTime(1: nVals);
iMetSolo.latitude_deg = latitude_deg(1: nVals);
iMetSolo.longitude_deg = longitude_deg(1: nVals);
iMetSolo.altitude_m = altitude_m(1: nVals);
iMetSolo.nSatellites = nSatellites(1: nVals);
iMetSolo.pressure_Pa = pressure_Pa(1: nVals);
iMetSolo.relativeHumidity_perCent= relativeHumidity_perCent(1: nVals);
iMetSolo.temperatureA_C = temperatureA_C(1: nVals);
iMetSolo.temperatureB_C = temperatureB_C(1: nVals);
iMetSolo.temperatureC_C = temperatureC_C(1: nVals);
iMetSolo.temperatureD_C = temperatureD_C(1: nVals);

% Close the file
fclose(fp);

% Remove the matlab library
rmpath(libDir)

figure(2)
clf
plot(iMetSolo.obsTime, iMetSolo.temperatureA_C,'-k')
hold on
plot(iMetSolo.obsTime, iMetSolo.temperatureB_C,'-b')
plot(iMetSolo.obsTime, iMetSolo.temperatureC_C,'-r')
plot(iMetSolo.obsTime, iMetSolo.temperatureD_C,'-g')
hold off
datetick('x', 15)
shg
