function plotAndSave(file1, file2, timeBeg, timeEnd) 
dirName = '../data/';

fileNameParts1 = strsplit(file1, {'-','.'});
fileNameParts2 = strsplit(file2, {'-','.'});

[dataXQ1, status1] = readiMetXQ(dirName, file1);
[dataXQ2, status2] = readiMetXQ(dirName, file2);
[dataNWCMeso, status3] = readNWCMesonet({dirName fileNameParts1{1} 'nwcm.mts'});

timeBeg = max([min(dataXQ1.time) min(dataXQ2.time)]);
timeEnd = min([max(dataXQ1.time) max(dataXQ2.time)]);

indXQ1 = find(timeBeg <= dataXQ1.time & dataXQ1.time <= timeEnd);
indXQ2 = find(timeBeg <= dataXQ2.time & dataXQ2.time <= timeEnd);
indMeso = find(timeBeg <= dataNWCMeso.time & dataNWCMeso.time <= timeEnd);

timeXQAvg = dataNWCMeso.time(indMeso);
nPts = length(timeXQAvg);
pressAvg1_hPa = zeros(1, nPts);
pressAvg2_hPa = zeros(1, nPts);
tempAvg1_C = zeros(1, nPts);
tempAvg2_C = zeros(1, nPts);
relHumidAvg1_perCent = zeros(1, nPts);
relHumidAvg2_perCent = zeros(1, nPts);

for j = 1: nPts
    ind1 = find(timeXQAvg(j) - 1/60/24 <= dataXQ1.time & dataXQ1.time <= timeXQAvg(j));
    ind2 = find(timeXQAvg(j) - 1/60/24 <= dataXQ2.time & dataXQ2.time <= timeXQAvg(j));
    if isempty(ind1)
        pressAvg1_hPa(j) = NaN;
        pressAvg2_hPa(j) = NaN;
        tempAvg1_C(j) = NaN;
        tempAvg2_C(j) = NaN;
        relHumidAvg1_perCent(j) = NaN;
        relHumidAvg2_perCent(j) = NaN;
    else
        pressAvg1_hPa(j) = nanmean(dataXQ1.press_hPa(ind1));
        pressAvg2_hPa(j) = nanmean(dataXQ2.press_hPa(ind2));
        tempAvg1_C(j) = nanmean(dataXQ1.temp_C(ind1));
        tempAvg2_C(j) = nanmean(dataXQ2.temp_C(ind2));
        relHumidAvg1_perCent(j) = nanmean(dataXQ1.relHumid_perCent(ind1));
        relHumidAvg2_perCent(j) = nanmean(dataXQ2.relHumid_perCent(ind2));
    end
end

dateAsStr = datestr(timeBeg, 1);

offsetFlag = true;
switch offsetFlag
    case false
        tempOffset1_C = 0;
        tempOffset2_C = 0;
        relHumidOffset1_perCent = 0;
        relHumidOffset2_perCent = 0;
        pressOffset1_hPa = 0;
        pressOffset2_hPa = 0;
    case true
        tempOffset1_C = 0.3;
        tempOffset2_C = 0.3;
        relHumidOffset1_perCent = -3.5;
        relHumidOffset2_perCent = -7.5;
        pressOffset1_hPa = 1.8;
        pressOffset2_hPa = -0.2;
end

nwsP = dataNWCMeso.pres_hPa(indMeso)';
allP = [dataXQ2.press_hPa(indXQ2); dataXQ1.press_hPa(indXQ1); nwsP(nwsP~=-999)];

figPressure = figure(1);
clf
subplot(2, 1, 1)
plot(dataXQ1.time(indXQ1), dataXQ1.press_hPa(indXQ1) + pressOffset1_hPa, 'r')
hold on
plot(dataXQ2.time(indXQ2), dataXQ2.press_hPa(indXQ2) + pressOffset2_hPa, 'b')
plot(dataNWCMeso.time(indMeso), dataNWCMeso.pres_hPa(indMeso), 'k', 'linewidth', 2)
hold off
set(gca, 'xlim', [timeBeg timeEnd])
datetick('x', 13, 'keeplimits')
set(gca, 'ylim', [min(allP) max(allP)])
title(dateAsStr)
xlabel('Time UTC')
ylabel('Pressure (hPa)')
legend('iMet XQ1', 'iMet XQ2', 'Mesonet')
subplot(2, 1, 2)
plot(timeXQAvg, pressAvg1_hPa + pressOffset1_hPa, 'r', 'linewidth', 2)
hold on
plot(timeXQAvg, pressAvg2_hPa + pressOffset2_hPa, 'b', 'linewidth', 2)
plot(dataNWCMeso.time(indMeso), dataNWCMeso.pres_hPa(indMeso), 'k', 'linewidth', 2)
hold off
set(gca, 'xlim', [timeBeg timeEnd])
datetick('x', 13, 'keeplimits')
set(gca, 'ylim', [min(allP) max(allP)])
xlabel('Time UTC')
ylabel('Pressure (hPa)')
legend('Avg iMet XQ1', 'Avg iMet XQ2', 'Mesonet')
print(figPressure, ['../images/' fileNameParts1{1} '-' fileNameParts1{2} '-' fileNameParts2{2} '-pressure.png'], '-dpng')
shg

nwsT = dataNWCMeso.tair_C(indMeso)';
allT = [dataXQ2.temp_C(indXQ2); dataXQ1.temp_C(indXQ1); nwsT(nwsT~=-999)];

figTemp = figure(2);
clf
subplot(2, 1, 1)
plot(dataXQ1.time(indXQ1), dataXQ1.temp_C(indXQ1) + tempOffset1_C, 'r')
hold on
plot(dataXQ2.time(indXQ2), dataXQ2.temp_C(indXQ2) + tempOffset2_C, 'b')
plot(dataNWCMeso.time(indMeso), dataNWCMeso.tair_C(indMeso), 'k', 'linewidth', 2)
hold off
set(gca, 'xlim', [timeBeg timeEnd])
datetick('x', 13, 'keeplimits')
set(gca, 'ylim', [min(allT) max(allT)])
title(dateAsStr)
xlabel('Time UTC')
ylabel('Temperature (C)')
legend('iMet XQ1', 'iMet XQ2', 'Mesonet')
subplot(2, 1, 2)
plot(timeXQAvg, tempAvg1_C + tempOffset1_C, 'r', 'linewidth', 2)
hold on
plot(timeXQAvg, tempAvg2_C + tempOffset2_C, 'b', 'linewidth', 2)
plot(dataNWCMeso.time(indMeso), dataNWCMeso.tair_C(indMeso), 'k', 'linewidth', 2)
hold off
set(gca, 'xlim', [timeBeg timeEnd])
datetick('x', 13, 'keeplimits')
set(gca, 'ylim', [min(allT) max(allT)])
xlabel('Time UTC')
ylabel('Temperature (C)')
legend('Avg iMet XQ1', 'Avg iMet XQ2', 'Mesonet')
print(figTemp, ['../images/' fileNameParts1{1} '-' fileNameParts1{2} '-' fileNameParts2{2} '-temperature.png'], '-dpng')
shg

nwsRh = dataNWCMeso.relh_perCent(indMeso)';
allRH = [dataXQ2.relHumid_perCent(indXQ2); dataXQ1.relHumid_perCent(indXQ1); nwsRh(nwsRh~=-999)];

figRH = figure(3);
clf
subplot(2, 1, 1)
plot(dataXQ1.time(indXQ1), dataXQ1.relHumid_perCent(indXQ1) + relHumidOffset1_perCent, 'r')
hold on
plot(dataXQ2.time(indXQ2), dataXQ2.relHumid_perCent(indXQ2) + relHumidOffset2_perCent, 'b')
plot(dataNWCMeso.time(indMeso), dataNWCMeso.relh_perCent(indMeso), 'k', 'linewidth', 2)
hold off
set(gca, 'xlim', [timeBeg timeEnd])
datetick('x', 13, 'keeplimits')
set(gca, 'ylim', [min(allRH) max(allRH)])
title(dateAsStr)
xlabel('Time UTC')
ylabel('Relative Humidity (%)')
legend('iMet XQ1', 'iMet XQ2', 'Mesonet')
subplot(2, 1, 2)
plot(timeXQAvg, relHumidAvg1_perCent + relHumidOffset1_perCent, 'r', 'linewidth', 2)
hold on
plot(timeXQAvg, relHumidAvg2_perCent + relHumidOffset2_perCent, 'b', 'linewidth', 2)
plot(dataNWCMeso.time(indMeso), dataNWCMeso.relh_perCent(indMeso), 'k', 'linewidth', 2)
hold off
set(gca, 'xlim', [timeBeg timeEnd])
datetick('x', 13, 'keeplimits')
set(gca, 'ylim', [min(allRH) max(allRH)])
xlabel('Time UTC')
ylabel('Relative Humidity (%)')
legend('Avg iMet XQ1', 'Avg iMet XQ2', 'Mesonet')
print(figRH, ['../images/' fileNameParts1{1} '-' fileNameParts1{2} '-' fileNameParts2{2} '-relativeHumidity.png'], '-dpng')
shg
end

