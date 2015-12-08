function [windsond, status] = readWindsond(dirName, fileName)
% Comments coming

if ~exist([ dirName fileName ], 'file')
    fprintf('*** File does not exist ... exiting!\n')
    windsond = [];
    status = 0;
    return
end

% =====================================================================
% Open the file for reading
% =====================================================================
fileID = fopen([dirName fileName], 'r');

% =====================================================================
% Read the header data
% =====================================================================
str = fgetl(fileID);
begTime = datenum(str(17:35), 'yyyy-mm-dd HH:MM:SS');
for j = 1: 6
    str = fgetl(fileID);
end

% =====================================================================
% Read the data
% =====================================================================
iCount = 1;
while ~feof(fileID)
    str = fgetl(fileID);
    ind = strfind(str, 'DAT');
    if ~isempty(ind)
        str = strrep(str, ']', ','); % needed to help extract data
        % Time
        obsMinute = str2double(str(1:2));
        obsSecond = str2double(str(4:5)) + str2double(str(7:8))/1000;
        obsTime(iCount) = begTime + (obsMinute + obsSecond/60)/60/24;
        % Battery charge
        valID = 'su';
        nChars = length(valID) + 1;
        ind1 = strfind(str, valID);
        if isempty(ind1)
            val = NaN;
        else
            ind2 = strfind(str(ind1:end), ',');
            val = str2double(str(ind1 + nChars: ind1 + ind2(1) - 2));
        end
        battery_V(iCount) = val;
        % Pressure
        valID = 'pa';
        nChars = length(valID) + 1;
        ind1 = strfind(str, valID);
        if isempty(ind1)
            val = NaN;
        else
            ind2 = strfind(str(ind1:end), ',');
            val = str2double(str(ind1 + nChars: ind1 + ind2(1) - 2));
        end
        pressure_Pa(iCount) = val;
        % Temperature
        valID = 'te';
        ind1 = strfind(str, valID);
        if isempty(ind1)
            val = NaN;
        else
            ind2 = strfind(str(ind1:end), ',');
            val = str2double(str(ind1 + nChars: ind1 + ind2(1) - 2));
        end
        temperature_C(iCount) = val;
        % Humidity
        valID = 'hu';
        ind1 = strfind(str, valID);
        if isempty(ind1)
            val = NaN;
        else
            ind2 = strfind(str(ind1:end), ',');
            val = str2double(str(ind1 + nChars: ind1 + ind2(1) - 2));
        end
        humidity_perCent(iCount) = val;
        % Internal temperature
        valID = 'te';
        ind1 = strfind(str, valID);
        if isempty(ind1)
            val = NaN;
        else
            ind2 = strfind(str(ind1:end), ',');
            val = str2double(str(ind1 + nChars: ind1 + ind2(1) - 2));
        end
        temperatureSensor_C(iCount) = val;
        % Latitude
        valID = 'lat';
        nChars = length(valID) + 1;
        ind1 = strfind(str, valID);
        if isempty(ind1)
            val = NaN;
        else
            ind2 = strfind(str(ind1:end), ',');
            val = str2double(str(ind1 + nChars: ind1 + ind2(1) - 2));
        end
        latitude_deg(iCount) = floor(val/1e6)+100*(val/1e6-floor(val/1e6))/60;
        % Longitude
        valID = 'lon';
        nChars = length(valID) + 1;
        ind1 = strfind(str, valID);
        if isempty(ind1)
            val = NaN;
        else
            ind2 = strfind(str(ind1:end), ',');
            val = str2double(str(ind1 + nChars: ind1 + ind2(1) - 2));
        end
        longitude_deg(iCount) = floor(val/1e6)+100*(val/1e6-floor(val/1e6))/60;
        % Altitude
        valID = 'alt';
        nChars = length(valID) + 1;
        ind1 = strfind(str, valID);
        if isempty(ind1)
            val = NaN;
        else
            ind2 = strfind(str(ind1:end), ',');
            val = str2double(str(ind1 + nChars: ind1 + ind2(1) - 2));
        end
        altitude_m(iCount) = val;
        % Speed
        valID = 'spd';
        nChars = length(valID) + 1;
        ind1 = strfind(str, valID);
        if isempty(ind1)
            val = NaN;
        else
            ind2 = strfind(str(ind1:end), ',');
            val = str2double(str(ind1 + nChars: ind1 + ind2(1) - 2));
        end
        speed_mps(iCount) = val;
        % Heading
        valID = 'ang';
        nChars = length(valID) + 1;
        ind1 = strfind(str, valID);
        if isempty(ind1)
            val = NaN;
        else
            ind2 = strfind(str(ind1:end), ',');
            val = str2double(str(ind1 + nChars: ind1 + ind2(1) - 2));
        end
        heading_deg(iCount) = val;
        % --
        iCount = iCount + 1;
    end
end

% =====================================================================
% Close the file
% =====================================================================
fclose(fileID);

% =====================================================================
% Create the structured array
% =====================================================================
windsond.obsTime = obsTime;
windsond.battery_V = battery_V;
windsond.pressure_Pa = pressure_Pa;
windsond.temperature_C = temperature_C;
windsond.humidity_perCent = humidity_perCent;
windsond.temperatureSensor_C = temperatureSensor_C;
windsond.latitude_deg = latitude_deg;
windsond.longitude_deg = longitude_deg;
windsond.altitude_m = altitude_m;
windsond.speed_mps = speed_mps;
windsond.heading_deg = heading_deg;

status = 1;