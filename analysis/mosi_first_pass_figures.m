clear all;
close all;

addpath('../analysis')

dataDir = 'C:\Users\angie\Box\motion_silencing\data\';
figDir = 'C:\Users\angie\Box\motion_silencing\figs\';

cd(strcat(dataDir));
data = readmatrix('moSiData.csv');

% Can we replicate motion silencing? What does the aggregate data look
% like? This includes block 1 and 4

markerCol = {[0, 0, 0], [0.5, 0.5, 0.5]};

figure()
for cond = 1:2
    dataIdx = [];
    dataChunck = [];

    if cond == 1
        dataIdx = find((data(:,2) == 1) | (data(:,2) == 4));
        dataChunck = data(dataIdx,:);
    elseif cond == 2
        dataIdx = find((data(:,2) == 3) | (data(:,2) == 5));
        dataChunck = data(dataIdx,:);
    end
    
    for t = 1:length(dataChunck)
        flicker(t,1) = 1/dataChunck(t,6);
        dotSpeed(t,1) = dataChunck(t,4);
    
        loglog(dotSpeed(t,1), flicker(t,1), '.', 'Color', markerCol{cond});
        hold on;
    end
    
    % Get mean and standard deviation
    speed = unique(dotSpeed);
    row = [];
    col = [];
    val = [];
    
    meanVal = [];
    speedVal = [];
    stdError = [];
    
    for s = 1:length(speed)
        [row, col] = find(dotSpeed == speed(s));
    
        for r =1:length(row)
            val(:,r) = flicker(row(r), col(r));
        end
    
        meanVal(:,s)  = mean(val);
        speedVal(:,s) = speed(s);
        stdError(:,s) = std(val)/ sqrt(length(val));
    
        legendMarker{cond} = loglog(speedVal, meanVal, 'o', 'MarkerFaceColor', markerCol{cond}, 'MarkerEdgeColor', markerCol{cond});
        e = errorbar(speedVal, meanVal, stdError, 'LineStyle','none');
        e.Color = markerCol{cond};
        e.LineWidth = 1;
    end
end

yline(1, '--')
xlabel('Speed deg/s')
ylabel('Silencing Factor')

set(gca, 'XTick', [1, 10, 100, 1000]);
set(gca, 'YTick', [-10, 1, 10]);

legend([legendMarker{1}, legendMarker{2}], {'Rotation', 'Random'}, 'Location','best')
legend('boxoff');

fig = gcf;
exportgraphics(fig, strcat(figDir,'Rotation_all.pdf'), 'ContentType', 'vector');

% Does the size of the dot matter?
dataIdx = find((data(:,2) == 2)); % Get all data from block 2
dataChunck = data(dataIdx,:);

markerSizeCol = {[1, 0, 0], [0, 0, 1]};

flicker  = [];
dotSpeed = [];
dotSize  = [];

figure()
for t = 1:length(dataChunck)
    flicker(t,1) = 1/dataChunck(t,6);
    dotSpeed(t,1) = dataChunck(t,4);
    dotSize(t, 1) = round(dataChunck(t,5));

    if (dotSize(t,1) == 6)
        loglog(dotSpeed(t,1), flicker(t,1), '.', 'Color', markerSizeCol{1});
        hold on;
    elseif (dotSize(t,1) == 14)
        loglog(dotSpeed(t,1), flicker(t,1), '.', 'Color', markerSizeCol{2});
        hold on;
    end
    
end

% Get mean and standard deviation
speed    = unique(dotSpeed);
sizeList = [6;14];

for si = 1:length(sizeList) % For each marker size
    idx      = find(dotSize == sizeList(si));
    flickerSize  = flicker(idx,:);
    dotSpeedSize = dotSpeed(idx,:);
    dotSizeSize  = dotSize(idx,:);

    row = [];
    col = [];
    val = [];
    
    meanVal = [];
    speedVal = [];
    stdError = [];
    
    for s = 1:length(speed)
        [row, col] = find(dotSpeedSize == speed(s));
    
        for r =1:length(row)
            val(:,r) = flickerSize(row(r), col(r));
        end
    
        meanVal(:,s)  = mean(val);
        speedVal(:,s) = speed(s);
        stdError(:,s) = std(val)/ sqrt(length(val));
    
        legendMarker{si} = loglog(speedVal, meanVal, 'o', 'MarkerFaceColor', markerSizeCol{si}, 'MarkerEdgeColor', markerSizeCol{si});
        e = errorbar(speedVal, meanVal, stdError, 'LineStyle','none');
        e.Color = markerSizeCol{si};
        e.LineWidth = 1;
    end
end

legend([legendMarker{1}, legendMarker{2}], {'Small 0.25 dva', 'Medium 0.55 dva'}, 'Location','best')
legend('boxoff');

% What happens when you break coherence?

