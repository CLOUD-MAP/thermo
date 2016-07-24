function quickLookDir = getQuickLookDir(procYear, procMonth, procDay, sensorType)
% Function used to create the path to data files based on date and sensor
% type
% baseDir is the local directory  where the folder 'thermo' lives
 
rootDir = mfilename('fullpath');
rootDir = rootDir(1:end-22); % lop off the trailing 'matlab/getQuickLookDir'

% Find the appropriate image directory based on instrument type
quickLookDir = sprintf('%squickLooks%s%s%4.4d%s%2.2d%s%2.2d%s', ...
    rootDir, filesep, sensorType, filesep, ...
    procYear, filesep, procMonth, filesep, procDay, filesep);