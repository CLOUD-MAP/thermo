% QuickLook

%% Initialization
% Clear the screen for kicks
clc
% Clear the memory
clear all

% Set up the inputs
procYear = 2015;
procMonth = 12;
procDay = 04;
procStation = 'wash';

%% Local adjustments
% *** You will need to change the baseDir for your computer
% This is where your 'thermo' folder lives
baseDir = '/users/chilson/Matlab/CLOUDMAP/';

% Create the directory of the matlab library and add it to the path
libDir = [ baseDir filesep 'thermo' filesep 'matlab' filesep ];
addpath(libDir)

iMetFlag = true;
windsondFlag = true;

plotColor{1} = 'b';
plotColor{2} = 'r';
plotColor{3} = 'k';
plotColor{4} = 'g';
plotColor{5} = 'g';
plotColor{6} = 'k';
plotColor{7} = 'r';
plotColor{8} = 'b';

begTime = datenum(procYear, procMonth, procDay, 13, 50, 0);
endTime = datenum(procYear, procMonth, procDay, 15, 20, 0);
timeRange = [begTime endTime];
temperatureRange_C = [0 12];
humidityRange_perCent = [0 100];
lineWidth = 1.5;
fontSize = 15;
axisWidth = 2;


%% Mesonet data

sensorType = 'Mesonet';
dataDir = getDataDir(baseDir, procYear, procMonth, procDay, sensorType);

fileName = sprintf('%4.4d%2.2d%2.2d%s.mat', procYear, procMonth, procDay, procStation);
load([ dataDir fileName ])

%% iMet data

if iMetFlag
    sensorType = 'iMet';

    dataDir = getDataDir(baseDir, procYear, procMonth, procDay, sensorType);

    diMet = dir([ dataDir '*.mat' ]);
    nFilesiMet = length(diMet);
    for iFile = 1: nFilesiMet
        load([ dataDir diMet(iFile).name ])
        iMetXQArr(iFile) = iMetXQ;
    end

    figure(1)
    clf
    % --------------
    subplot(3, 1, 1)
    % --------------
    plot(mts.obsTime, mts.pressure_Pa/100, '-o', 'linewidth', lineWidth)
    hold on
    for iFile = 1: nFilesiMet
        plot(iMetXQArr(iFile).obsTime, iMetXQArr(iFile).pressure_Pa/100, ...
            'color', plotColor{iFile}, 'linewidth', lineWidth)
    end
    hold off
    set(gca, 'xlim', timeRange)
    set(gca, 'fontsize', fontSize)
    set(gca, 'linewidth', axisWidth)
    datetick('x', 15, 'keeplimits')
    ylabel('Pressure (hPa)')
    title('iMet')
    % --------------
    subplot(3, 1, 2)
    % --------------
    hold on
    plot(mts.obsTime, mts.temperature1p5m_C, '-o', 'linewidth', lineWidth)
    for iFile = 1: nFilesiMet
        plot(iMetXQArr(iFile).obsTime, iMetXQArr(iFile).temperature_C, ...
            'color', plotColor{iFile}, 'linewidth', lineWidth)
    end
    hold off
    set(gca, 'xlim', timeRange)
    set(gca, 'ylim', temperatureRange_C)
    set(gca, 'fontsize', fontSize)
    set(gca, 'linewidth', axisWidth)
    datetick('x', 15, 'keeplimits')
    ylabel('Temperature (C)')
    % --------------
    subplot(3, 1, 3)
    % --------------
    plot(mts.obsTime, mts.humidity_perCent, '-o', 'linewidth', lineWidth)
    hold on
    for iFile = 1: nFilesiMet
        plot(iMetXQArr(iFile).obsTime, iMetXQArr(iFile).humidity_perCent, ...
            'color', plotColor{iFile}, 'linewidth', lineWidth)
    end
    hold off
    set(gca, 'xlim', timeRange)
    set(gca, 'ylim', humidityRange_perCent)
    set(gca, 'fontsize', fontSize)
    set(gca, 'linewidth', axisWidth)
    datetick('x', 15, 'keeplimits')
    ylabel('Humidity (%)')
    xlabel('Time UTC)')

    set(gcf,'PaperPositionMode','auto')
    print('iMetSensors.png', '-dpng')

end

%% Windsond data

timeOffset = 6;

if windsondFlag
    sensorType = 'Windsond';

    dataDir = getDataDir(baseDir, procYear, procMonth, procDay, sensorType);

    dWindsond = dir([ dataDir '*.mat' ]);
    nFilesWindsond = length(dWindsond);
    for iFile = 1: nFilesWindsond
        load([ dataDir dWindsond(iFile).name ])
        windsond.obsTime = windsond.obsTime + timeOffset/24;
        windsondArr(iFile) = windsond;
    end

    figure(2)
    clf
    % --------------
    subplot(3, 1, 1)
    % --------------
    plot(mts.obsTime, mts.pressure_Pa/100, '-o', 'linewidth', lineWidth)
    hold on
    for iFile = 1: nFilesWindsond
        plot(windsondArr(iFile).obsTime, windsondArr(iFile).pressure_Pa/100, ...
            'color', plotColor{iFile}, 'linewidth', lineWidth)
    end
    hold off
    set(gca, 'xlim', timeRange)
    set(gca, 'fontsize', fontSize)
    set(gca, 'linewidth', axisWidth)
    datetick('x', 15, 'keeplimits')
    ylabel('Pressure (hPa)')
    title('windsond')
    % --------------
    subplot(3, 1, 2)
    % --------------
    plot(mts.obsTime, mts.temperature1p5m_C, '-o', 'linewidth', lineWidth)
    hold on
    for iFile = 1: nFilesWindsond
        plot(windsondArr(iFile).obsTime, windsondArr(iFile).temperature_C, ...
            'color', plotColor{iFile}, 'linewidth', lineWidth)
    end
    hold off
    set(gca, 'xlim', timeRange)
    set(gca, 'ylim', temperatureRange_C)
    set(gca, 'fontsize', fontSize)
    set(gca, 'linewidth', axisWidth)
    ylabel('Temperature (C)')
    datetick('x', 15, 'keeplimits')
    % --------------
    subplot(3, 1, 3)
    % --------------
    plot(mts.obsTime, mts.humidity_perCent, '-o', 'linewidth', lineWidth)
    hold on
    for iFile = 1: nFilesWindsond
        plot(windsondArr(iFile).obsTime, windsondArr(iFile).humidity_perCent, ...
            'color', plotColor{iFile}, 'linewidth', lineWidth)
    end
    hold off
    set(gca, 'xlim', timeRange)
    set(gca, 'ylim', humidityRange_perCent)
    set(gca, 'fontsize', fontSize)
    set(gca, 'linewidth', axisWidth)
    datetick('x', 15, 'keeplimits')
    ylabel('Humidity (%)')
    xlabel('Time UTC)')

    set(gcf,'PaperPositionMode','auto')
    print('windsondSensors.png', '-dpng')

end

%% Clean up
% Remove the matlab library
rmpath(libDir)
