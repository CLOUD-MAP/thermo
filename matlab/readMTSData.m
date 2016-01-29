function [mts, status] = readMTSData(fileName, dirName, NWCFlag)
% =====================================================================
% readMTSData
% [mts, status] = readMTSData(fileName, dirName)
% =====================================================================
% Function used to read in a mesonet MTS data file and create a structured
% array called mts of the form given below.
% Input parameters are
% fileName = name of the file yyyymmddstid.mts
%   stid = station ID, such as 'wash' for Washington
% dirName  = directory where data file should be placed
%   note that the end delimeter should be included, e.g., './data/'
%   if the directory is not provided, then the working directory is used
% NWCFlag = flag indicating if NWC site (1) or other site (0)
%   if the value is not present, then default to 0
% Format of the structured array has two formats
% *** Operational Mesonet Sites ***
% mts = 
% 
%           stationNumber: [1x288 double]
%                 timeUTC: [1x288 double]
%                 rain_mm: [1x288 double]
%        relHumid_perCent: [1x288 double]
%              temp1p5m_C: [1x288 double]
%        windSpeed10m_mps: [1x288 double]
%     windSpeedVec10m_mps: [1x288 double]
%          windDir10m_deg: [1x288 double]
%        windDirSD10m_deg: [1x288 double]
%      windSpeedSD10m_mps: [1x288 double]
%     windSpeedMax10m_mps: [1x288 double]
%            pressure_hPa: [1x288 double]
%             solRad_Wpm2: [1x288 double]
%                temp9m_C: [1x288 double]
%         windSpeed2m_mps: [1x288 double]
% where the dimenstion of the array is time.
% *** NWC Mesonet Site ***
% mts = 

% Created 2015-12-09 Phil Chilson
% Revision history
% 2016-01-27
% Added the ability to read the NWC Mesonet station

% Quantities contained in the MTS file
% *** Operational Mesonet Sites ***
% Tag   Quantity
% ---------------------------------------------------------------
% STID  Station ID
% STNM  Station name
% TIME  Time UTC [min]
% RELH  Relative humidity [%]
% TAIR  Air temperature at 1.5m [C]
% WSPD  Wind speed at 10m [m s^-1]
% WVEC  Vector average wind speed [m s^-1]
% WDIR  Wind direction at 10m (degr)
% WDSD  Standard deviation of wind direction [degr]
% WSSD  Stadnard deviation of wind speed [m s^-1]
% WMAX  Maximum wind speed [m s^-1]
% RAIN  Rainfall since midnight UTC [mm]
% PRES  Pressure [hPa]
% SRAD  Solar radiation [W m^2]
% TA9M  Air temperature at 9m [C]
% WS2M  Wind speed at at 2m [m s^-1]
% TS10  Sod temperature at 10cm [C]
% TB10  Soil temperature at 10cm [C]
% TS05  Sod temperature at 5cm [C]
% TS25  Sod temperature at 25cm [C]
% TS60  Sod temperature at 60cm [C]
% TR05  Soil moisture reference temperature at 5cm under sod [C]
% TR25  Soil moisture reference temperature at 25cm under sod [C]
% TR60  Soil moisture reference temperature at 60cm under sod [C]
% *** Operational Mesonet Sites ***
% Tag   Quantity
% ---------------------------------------------------------------
% STID  Station ID
% STNM  Station name
% TIME  Time UTC [min]
% RELH  Relative humidity [%]
% TAIR  Air temperature at 1.5m [C]
% WSPD  Wind speed at 10m [m s^-1]
% WDIR  Wind direction at 10m (degr)
% WMAX  Maximum wind speed [m s^-1]
% RAIN  Rainfall since midnight UTC [mm]
% PRES  Pressure [hPa]
% SRAD  Solar radiation [W m^2]
% TA9M  Air temperature at 9m [C]
% WS2M  Wind speed at at 2m [m s^-1]
% SKIN  ??
% =====================================================================
% Check number of input arguments and take appropriate actions
% =====================================================================
switch nargin
    case 1
        % outDir not specified, use pwd
        outDir = pwd;
    case 2
        % NWCFlag not specified, set to 0
        NWCFlag = 0;
    case 3
        % we're good here
    otherwise
        fprintf('*** readMTSData: error calling function ... exiting!\n')
        status = 0;
        return
end

% =====================================================================
% Check if the file exists and if so open it
% =====================================================================
if exist([ dirName fileName ], 'file')
  fp = fopen([ dirName fileName ], 'r');
  fprintf('Reading file: %s\n', [ dirName fileName ])
else
  fprintf('*** readMTSData: file not found!\n')
  mts = [];
  status = 0;
  return
end

if NWCFlag
    % =====================================================================
    % Read the header data
    % =====================================================================
    fgetl(fp);
    str = fgetl(fp);
    [~, procYear, procMonth, procDay, procHour, procMinute, procSecond] = ...
        strread(str, '%d%d%d%d%d%d%d');
    st_base = datenum(procYear, procMonth, procDay, ...
        procHour, procMinute, procSecond);
    fgetl(fp);

    % =====================================================================
    % Read the data and assign them to the structured array
    % =====================================================================
    icnt = 1;
    while 1
        str = fgetl(fp);
        [STID, STNM, TIME, RELH, TAIR, WSPD, WDIR, WMAX, ...
            RAIN, PRES, SRAD, TA9M, WS2M, SKIN] = ...
            strread(str, '%s%d%d%d%f%f%d%f%f%f%d%f%f%f');
        mts.stationNumber(icnt) = STNM;
        mts.obsTime(icnt) = st_base + TIME/(24*60);
        mts.humidity_perCent(icnt) = RELH;
        mts.temperature1p5m_C(icnt) = TAIR;
        mts.windSpeed10m_mps(icnt) = WSPD;
        mts.windDirection10m_deg(icnt) = WDIR;
        mts.windSpeedMax10m_mps(icnt) = WMAX;
        mts.rain_mm(icnt) = RAIN;
        mts.pressure_Pa(icnt) = 100*PRES;
        mts.solarRadiation_Wpm2(icnt) = SRAD;
        mts.temperature9m_C(icnt) = TA9M;
        mts.windSpeed2m_mps(icnt) = WS2M;
        mts.skin(icnt) = SKIN;
        if feof(fp), break, end
        icnt = icnt + 1;
    end
else
    % =====================================================================
    % Read the header data
    % =====================================================================
    fgetl(fp);
    str = fgetl(fp);
    [~, procYear, procMonth, procDay, procHour, procMinute, procSecond] = ...
        strread(str, '%d%d%d%d%d%d%d');
    st_base = datenum(procYear, procMonth, procDay, ...
        procHour, procMinute, procSecond);
    fgetl(fp);
    
    % =====================================================================
    % Read the data and assign them to the structured array
    % =====================================================================
    icnt = 1;
    while 1
        str = fgetl(fp);
        [STID, STNM, TIME, RELH, TAIR, WSPD, WVEC, WDIR, WDSD, WSSD, WMAX, ...
            RAIN, PRES, SRAD, TA9M, WS2M, TS10, TB10, TS05, TS25, TS60, TR05, ...
            TR25, TR60] = ...
            strread(str, '%s%d%d%d%f%f%f%d%f%f%f%f%f%d%f%f%f%f%f%f%f%f%f%f');
        mts.stationNumber(icnt) = STNM;
        mts.obsTime(icnt) = st_base + TIME/(24*60);
        mts.humidity_perCent(icnt) = RELH;
        mts.temperature1p5m_C(icnt) = TAIR;
        mts.windSpeed10m_mps(icnt) = WSPD;
        mts.windSpeedVec10m_mps(icnt) = WVEC;
        mts.windDirection10m_deg(icnt) = WDIR;
        mts.windDirectionSD10m_deg(icnt) = WDSD;
        mts.windSpeedSD10m_mps(icnt) = WSSD;
        mts.windSpeedMax10m_mps(icnt) = WMAX;
        mts.rain_mm(icnt) = RAIN;
        mts.pressure_Pa(icnt) = 100*PRES;
        mts.solarRadiation_Wpm2(icnt) = SRAD;
        mts.temperature9m_C(icnt) = TA9M;
        mts.windSpeed2m_mps(icnt) = WS2M;
        mts.sodTemperature5cm_C(icnt) = TS05;
        if feof(fp), break, end
        icnt = icnt + 1;
    end
end

% =====================================================================
% Close the file
% =====================================================================
fclose(fp);

status = 1;