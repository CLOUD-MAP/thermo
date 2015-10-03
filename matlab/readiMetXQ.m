function [dataXQ, status] = readiMetXQ(dirName, fileName)

delimiter = ',';
formatSpec = '%s%f%f%f%s%s%f%f%f%f%[^\n\r]';

if ~exist([dirName fileName], 'file')
    fprintf('*** File not found ... exiting!\n')
    dataXQ = [];
    status = 0;
    return
end

fileID = fopen([dirName fileName], 'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);
fclose(fileID);

dataXQ.time = datenum(dataArray{:, 5}) + ...
    datenum(dataArray{:, 6}) - ...
    datenum(2015, 1, 1);
dataXQ.press_hPa = dataArray{:, 2}/1e2;
dataXQ.temp_C = dataArray{:, 3}/1e2;
dataXQ.relHumid_perCent = dataArray{:, 4}/1e1;
dataXQ.lat_deg = dataArray{:, 7}/1e7;
dataXQ.lon_deg = dataArray{:, 8}/1e7;
dataXQ.altAGL_m = dataArray{:, 9}/1e3;
dataXQ.nSat = dataArray{:, 10};
status = 1;