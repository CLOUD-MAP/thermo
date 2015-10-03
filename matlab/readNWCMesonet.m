function [dataNWCMeso, status] = readNWCMesonet(fileName)
% Data Format
%  101 ! (c) 2015 Oklahoma Climatological Survey and the Oklahoma Mesonet - all rights reserved
%  11 2015 08 12 00 00 00
% STID  STNM  TIME   RELH   TAIR   WSPD  WDIR   WMAX    RAIN     PRES  SRAD   TA9M   WS2M   SKIN
% STID  Station ID
% STNM  Station number
% TIME  Time in minutes since start of file
% RELH  Relative humidity (%)
% TAIR  Air temperature (C)
% WSPD  Wind speed (m/s)
% WDIR  Wind direction - meteorological convention (deg)
% WMAX  Max wind speed (m/s)
% RAIN  Rain (mm)
% PRES  Pressure (hPa)
% SRAD  Solar radiation (W/m^2)
% TA9M  Air temperature at 9m (C)
% WS2M  Wind speed at 2 m (m/s)
% SKIN  ??
fullFilePath = strjoin(fileName, '');

if exist(fullFilePath, 'file')
  fp = fopen(fullFilePath, 'r');
else
  fprintf('*** File not found! Downloading...\n')
  websave(fullFilePath, strcat('http://www.mesonet.org/index.php/dataMdfMts/dataController/getFile/', fileName(2), 'nwcm/mts/DOWNLOAD/'))
  fp = fopen(fullFilePath, 'r');
end

fgetl(fp);
str = fgetl(fp);
[~, procYear, procMonth, procDay, procHour, procMinute, procSecond] = ...
    strread(str, '%d%d%d%d%d%d%d');
st_base = datenum(procYear, procMonth, procDay, ...
    procHour, procMinute, procSecond);
fgetl(fp);
icnt = 1;
while 1
  str = fgetl(fp);
  [~, STNM, TIME, RELH, TAIR, WSPD, WDIR, WMAX, ...
      RAIN, PRES, SRAD, TA9M, WS2M, SKIN] = ...
      strread(str, '%s%d%d%d%f%f%d%f%f%f%d%f%f%f');
  dataNWCMeso.time(icnt) = st_base + TIME/(24*60);
  dataNWCMeso.stnm(icnt) = STNM;
  dataNWCMeso.relh_perCent(icnt) = RELH;
  dataNWCMeso.tair_C(icnt) = TAIR;
  dataNWCMeso.wspd_mps(icnt) = WSPD;
  dataNWCMeso.wdir_deg(icnt) = WDIR;
  dataNWCMeso.wmax_mps(icnt) = WMAX;
  dataNWCMeso.rain_mm(icnt) = RAIN;
  dataNWCMeso.pres_hPa(icnt) = PRES;
  dataNWCMeso.srad_Wpm2(icnt) = SRAD;
  dataNWCMeso.ta9m_C(icnt) = TA9M;
  dataNWCMeso.ws2m_mps(icnt) = WS2M;
  dataNWCMeso.skin(icnt) = SKIN;
  if feof(fp), break, end
  icnt = icnt + 1;
end
fclose(fp);
status = 1;
