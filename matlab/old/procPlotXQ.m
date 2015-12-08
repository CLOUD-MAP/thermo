reply = input('Read in the data? (n/y): ', 's');
if upper(reply) == 'Y'
    clear all

    measDay = input('Select day (1 = 11th, 2 = 12th, 3 = 22nd): ');
    switch measDay
        case 1
            % blue
            fileNameiMet1 = '20150811-iMet1.csv';
            % other
            fileNameiMet2 = '20150811-iMet2.csv';
            fileNameMeso = '20150811nwcm.mts';
            
            timeBeg = datenum(2015, 8, 11, 18, 0, 0);
            timeEnd = datenum(2015, 8, 11, 20, 0, 0);
            
            prng = [975 980];
            Trng = [30 38];
            RHrng = [40 70];
            
            plotNamep = 'comparePressure1.png';
            plotNameT = 'compareTemperature1.png';
            plotNameRH = 'compareRelativeHumidity1.png';
            
            plotAndSave(fileNameiMet1, fileNameiMet2);

        case 2
            % blue
            fileNameiMet1 = '20150812-150919-iMet-XQ Export.csv';
            % other
            fileNameiMet2 = '20150812-151820-iMet-XQ Export.csv';
            fileNameMeso = '20150812nwcm.mts';
            
            timeBeg = datenum(2015, 8, 12, 18, 0, 0);
            timeEnd = datenum(2015, 8, 12, 20, 0, 0);
            
            prng = [978 983];
            Trng = [27 35];
            RHrng = [30 60];

            plotNamep = 'comparePressure2.png';
            plotNameT = 'compareTemperature2.png';
            plotNameRH = 'compareRelativeHumidity2.png';
            
            plotAndSave(fileNameiMet1, fileNameiMet2);

        case 3
            fileNameiMet1 = '20150822-171236-iMet-XQ Export.csv';
            fileNameiMet2 = '20150822-171806-iMet-XQ Export.csv';
            fileNameMeso = '20150822nwcm.mts';
            
            timeBeg = datenum(2015, 8, 22, 20, 30, 0);
            timeEnd = datenum(2015, 8, 22, 22, 0, 0);
            
            prng = [969 971];
            Trng = [30 34];
            RHrng = [52 64];

            plotNamep = 'comparePressure3.png';
            plotNameT = 'compareTemperature3.png';
            plotNameRH = 'compareRelativeHumidity3.png';

            plotAndSave(fileNameiMet1, fileNameiMet2);
    end
    
    
end