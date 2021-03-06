% plotCUvsCU2vsNT1065 plots the same time range of data from CU and CU2 and 
% NT1065 on the same plot.

%% Housekeeping
clearvars
close all
clc

%% Parameters for Time Range
start_time = unixtime([2017 1 10 1 39 0]);
end_time = start_time + 2*60;

%% CU
directory = '/home/dma/Documents/CUvsSUcompare/data/CU_SiGe_1';
x_tick_location = 1; % Daily
logname = 'CU';
file_name = ['/*' logname '_AGC*AGC.bin'];
thresh = 0.9;
pts_under_thrsh = 5;
[CU_plot_fid, CU_plotted_time, CU_plotted_agc] = AGC_Plotting(start_time...
    , end_time,  directory, file_name, x_tick_location,thresh,pts_under_thrsh);
close(CU_plot_fid);

%% CU 2
directory = '/home/dma/Documents/CUvsSUcompare/data/CU_SiGe_2';
x_tick_location = 1; % Daily
logname = 'CU';
file_name = ['/*' logname '_AGC*AGC.bin'];
thresh = 0.7;
pts_under_thrsh = 5;
[CU2_plot_fid, CU2_plotted_time, CU2_plotted_agc] = AGC_Plotting(start_time...
    , end_time, directory, file_name, x_tick_location,thresh,pts_under_thrsh);
close(CU2_plot_fid);

%% NT1065

filename = '/home/dma/Documents/CUvsSUcompare/data/CU_NT1065/regdump09-01-2017_04:44:43.bin';
Channels = 1;
timerange = [1.88325 1.88325+1/30];
TimeStart = 0;
Day = 0;

[time_k2, ApproxGain3,RF_GainSt3] = parseFileAGC2(filename,Channels,timerange,...
    TimeStart,Day);

%% Plot
figure;
hold on
subplot(3,1,1)
plot(CU_plotted_time,CU_plotted_agc,'go','MarkerSize',8,'MarkerFaceColor','g');
ylim([0.1 1.35])
xlim([start_time end_time])
ylabel({'AGC Value [V]' '(CU 1B81)'})
title('CU 1B81 vs CU DLC vs NT1065')
set(gca,'FontSize',16)

subplot(3,1,2)
plot(CU2_plotted_time,CU2_plotted_agc,'bo','MarkerSize',8,'MarkerFaceColor','b');
ylim([0.1 1.35])
xlim([start_time end_time])
ylabel({'AGC Value [V]' '(CU DLC)'})
set(gca,'FontSize',16)

subplot(3,1,3)
hold on
plot(time_k2(:,1)*3600 + start_time - timerange(1)*3600,ApproxGain3(:,1));
plot(time_k2(:,1)*3600 + start_time- timerange(1)*3600,RF_GainSt3(:,1));
%ylim([0 50])
xlim([start_time end_time])
ylabel({'Gain [dB]' '(CU NT1065)'})
legend('IF Gain','RF Gain')
set(gca,'FontSize',16)

%% Scale the X-Axis
% Check if the x ticks are supposed to be every hour

if ~isempty(CU2_plotted_time)
    tot_time = CU2_plotted_time(end) - CU2_plotted_time(1);
end

x_tick_location = 0;

if x_tick_location == 0
    % Find the first hour in the data
    offset = mod(start_time, 24*60*60); % Find hours after day start
    tick_loc = start_time-offset; % Find start of day by subtracting offset
     % Create tick_label for first hour
    tick_label = datestr(unixtime(tick_loc), 'HH:MM');
    temp_tick_loc = tick_loc;
    % Create vector of tick_loc and tick_label using temp value and
    % appending it to current vector. tick_loc spread out every two hours
    % if the tot_time is greater than two hours
    if (tot_time <= 86400)
        while tick_loc(end) < CU2_plotted_time(end)
            % If greater than 2 hours, location is spread out every 2 hours
            if( tot_time > 4*3600 ) 
                temp_tick_loc = temp_tick_loc + (4*60*60);
            elseif tot_time > 2*3600 % Otherwise location is every hour
                temp_tick_loc = temp_tick_loc + (60*60);
            elseif tot_time >= 1*3600 % Otherwise location is every hour
                temp_tick_loc = temp_tick_loc + (15*60);
            else
                temp_tick_loc = temp_tick_loc + (1*60);
            end
            % Append to existing vectors
            tick_loc = [tick_loc, temp_tick_loc];
            tick_label = [tick_label; datestr(unixtime(tick_loc(end)),...
                'HH:MM')];
        end
    else % If time is greater than a day, same concept as above
        tick_label = datestr(unixtime(tick_loc), 'mmm-dd HH:MM');
        while tick_loc(end) < CU2_plotted_time(end)
            if( (CU2_plotted_time(end)-CU2_plotted_time(1)) > 4*3600 )
                temp_tick_loc = temp_tick_loc + (4*60*60);
            else
                temp_tick_loc = temp_tick_loc + (60*60);
            end
            % Append to existing vectors
            tick_loc = [tick_loc, temp_tick_loc];
            tick_label = [tick_label; datestr(unixtime(tick_loc(end)),...
                'mmm-dd HH:MM')]; % Label includes month and day
        end
    end
else % x-tick location is not every hour
    % Find when days begin
    offset = mod(start_time, 24*60*60);
    tick_loc = start_time - offset;
    % If x ticks are weekly or monthly spaced, change the start date
    if (x_tick_location == 2) % Begin tick_loc on first day of week
        while weekday(datestr(unixtime(tick_loc))) ~= 1 %~= %+(24*60*60)
            tick_loc = tick_loc + (24*60*60); 
        end
    elseif (x_tick_location == 3) % Begin tick_loc on first day of month
        while day(datestr(unixtime(tick_loc))) ~= 1
            tick_loc = tick_loc + (24*60*60);
        end
    end
    if(x_tick_location == 3) % Label in format of months
        tick_label = datestr(unixtime(tick_loc), 'mm-yyyy');
    else % Label in format of days of month
        tick_label = datestr(unixtime(tick_loc), 'dd-mmm-yyyy');
    end
    temp_tick_loc = tick_loc;
    % Create vector of tick_loc and tick_label
    if (tot_time <= 86400) % tot_time is less than a day
        while temp_tick_loc(end) < time(end)
            temp_tick_loc = temp_tick_loc + (24*60*60);
            if (x_tick_location == 2) % Week format
                if weekday(datestr(unixtime(temp_tick_loc))) == 1
                    tick_loc = [tick_loc temp_tick_loc];
                    tick_label = [tick_label; ...
                        datestr(unixtime(tick_loc(end)),'dd-mmm-yyyy')];
                end
            elseif (x_tick_location == 3) % Month format
                if day(datestr(unixtime(temp_tick_loc))) == 1
                    tick_loc = [tick_loc temp_tick_loc];
                    tick_label = [tick_label; ...
                        datestr(unixtime(tick_loc(end)),'mm-yyyy')];
                end
            else % Day format
                tick_loc = [tick_loc; (tick_loc(end)+(24*60*60))];
                tick_label = [tick_label; ...
                    datestr(unixtime(tick_loc(end)),'dd-mmm-yyyy')];
            end
        end
    else % tot_time is greater than a day
        offset = mod(CU2_plotted_time(1), 24*60*60);
        tick_loc = CU2_plotted_time(1) - offset;
        while temp_tick_loc(end) < CU2_plotted_time(end)
            temp_tick_loc = temp_tick_loc + (24*60*60);
            if (x_tick_location == 2)
                if weekday(datestr(unixtime(temp_tick_loc))) == 1
                    tick_loc = [tick_loc temp_tick_loc];
                    tick_label = [tick_label; ...
                        datestr(unixtime(tick_loc(end)),'dd-mmm-yyyy')];
                end
            elseif (x_tick_location == 3)
                if day(datestr(unixtime(temp_tick_loc))) == 1
                    tick_loc = [tick_loc temp_tick_loc];
                    tick_label = [tick_label; ...
                        datestr(unixtime(tick_loc(end)),'mm-yyyy')];
                end
            else % Day format
                tick_loc = [tick_loc; (tick_loc(end)+(24*60*60))];
                tick_label = [tick_label; ...
                    datestr(unixtime(tick_loc(end)),'dd-mmm-yyyy')];
            end
        end
    end
end

%% Set Plot Parameters
% Set x axis limits
if (tot_time <= 86400)
    xlim([min(CU2_plotted_time), max(CU2_plotted_time)]);
else
    xlim([min(CU2_plotted_time)-2, max(CU2_plotted_time)+2]);
end
set(gca, 'XTick', tick_loc); % Set x ticks to the tick locations
set(gca, 'xTickLabel', tick_label); % Set x tick labels to tick_label

xlabel('UTC Time')
samexaxis('join','yld',0.75);
