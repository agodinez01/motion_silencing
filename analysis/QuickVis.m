clear all;
close all;

addpath('../data/mat')

file{1} = load("10112023_111350_06_1_1.mat");
file{2} = load("10112023_130931_06_3_1.mat");

% Second round of plots
round1 = load("10202023_123302_06_4_1.mat");
round2 = load("10202023_141241_06_4_2.mat");
round3 = load("10202023_133431_06_4_3.mat");

% Third round of plots
filesV2{1} = load("10252023_132550_06_6_3.mat");
filesV2{2} = load("10252023_133922_06_7_3.mat");
filesV2{3} = load("10252023_104110_06_5_3.mat");
filesV2{4} = load("10252023_135949_06_8_3.mat");
filesV2{5} = load("10252023_141925_06_9_3.mat");
filesV2{6} = load("10252023_143419_06_10_3.mat");

filesV3{1} = load("10252023_132550_06_6_3.mat");
filesV3{2} = load("10252023_143419_06_10_3.mat");

figure(1)

for f = 1:length(file)
    for i = 1:size(file{f}.trial, 2)
        flicker(f,i)  = 1/file{f}.trial(i).flickerFrequency;
        dotSpeed(f,i) = file{f}.trial(i).dotSpeed;

        loglog(dotSpeed(f,i), flicker(f,i), '.k');
        hold on
    end
end

speed = unique(dotSpeed);
for s = 1:length(speed)
    [row, col] = find(dotSpeed == speed(s));
    for r = 1:length(row)
        val(:,r) = flicker(row(r),col(r));
    end
    meanVal(:,s)    = mean(val);
    speedVal(:,s)   = speed(s);
    stdError(:,s)   = std(val)/ sqrt(length(val));
end

loglog(speedVal, meanVal, 'ok', 'MarkerFaceColor','k')
e = errorbar(speedVal, meanVal, stdError, 'LineStyle', 'none');
e.Color = [0 0 0];
e.LineWidth = 1;

xlim([0, 130])
xticks([10, 100])
ylim([0.1, 10])
yticks([0.1, 1, 10])
yline(1, '--')
xlabel('Speed deg/s')

flicker = [];
dotSpeed = [];
for i = 1:size(round3.trial, 2)
    flicker(1,i)  = 1/round3.trial(i).flickerFrequency;
    dotSpeed(1,i) = round3.trial(i).dotSpeed;

    loglog(dotSpeed(1,i), flicker(1,i), '.', 'Color', [0.5 0.5 0.5]);
    hold on
end

speed = unique(dotSpeed);
row = [];
col = [];
val = [];

meanVal  = [];
speedVal = [];
stdError = [];

for s = 1:length(speed)
    [row, col] = find(dotSpeed == speed(s));
    for r = 1:length(row)
        val(:,r) = flicker(row(r),col(r));
    end
    meanVal(:,s)    = mean(val);
    speedVal(:,s)   = speed(s);
    stdError(:,s)   = std(val)/ sqrt(length(val));
end

loglog(speedVal, meanVal, 'o', 'MarkerFaceColor',[0.5, 0.5, 0.5], 'MarkerEdgeColor',[0.5, 0.5, 0.5])
e = errorbar(speedVal, meanVal, stdError, 'LineStyle', 'none');
e.Color = [0.5 0.5 0.5];
e.LineWidth = 1;

xlim([0, 130])
xticks([10, 100])
ylim([0.1, 10])
yticks([0.1, 1, 10])
yline(1, '--')
xlabel('Speed deg/s')

figure(2)
flicker = [];
dotSpeed = [];
for i = 1:size(round1.trial, 2)
    flicker(1,i)  = 1/round1.trial(i).flickerFrequency;
    dotSpeed(1,i) = round1.trial(i).dotSpeed;

    loglog(dotSpeed(1,i), flicker(1,i), '.k');
    hold on
end

speed = unique(dotSpeed);
row = [];
col = [];
val = [];

meanVal  = [];
speedVal = [];
stdError = [];

for s = 1:length(speed)
    [row, col] = find(dotSpeed == speed(s));
    for r = 1:length(row)
        val(:,r) = flicker(row(r),col(r));
    end
    meanVal(:,s)    = mean(val);
    speedVal(:,s)   = speed(s);
    stdError(:,s)   = std(val)/ sqrt(length(val));
end

loglog(speedVal, meanVal, 'ok', 'MarkerFaceColor','k', 'MarkerEdgeColor','k')
e = errorbar(speedVal, meanVal, stdError, 'LineStyle', 'none');
e.Color = [0 0 0];
e.LineWidth = 1;

xlim([0, 130])
xticks([10, 100])
ylim([0.1, 10])
yticks([0.1, 1, 10])
yline(1, '--')
xlabel('Speed deg/s')

figure(3)
flicker = [];
dotSpeed = [];
for i = 1:size(round2.trial, 2)
    flicker(1,i)  = 1/round2.trial(i).flickerFrequency;
    dotSpeed(1,i) = round2.trial(i).dotSpeed;
    dotSize(1,i)  = round2.trial(i).dotSize;
end

markerInfo = ['b', 'g', 'r', 'c'];
dSize = unique(dotSize);
for si = 1:length(dSize)
    [rowSize, colSize] = find(dotSize == dSize(si));
    loglog(dotSpeed(rowSize,colSize), flicker(rowSize,colSize), strcat(markerInfo(si), '.'))
    hold on;
end

row = [];
col = [];
val = [];

meanVal  = [];
speedVal = [];
stdError = [];

for s = 1:length(speed)
    for si= 1:length(dSize)
        [rowSpeed, colSpeed] = find(dotSpeed == speed(s));
        [rowSize, colSize]   = find(dotSize == dSize(si));

        [~,y] = ismember(colSpeed, colSize); % colSize
        y = nonzeros(y);

        for r=1:length(y)
            val(:,r) = flicker(rowSize(y(r)), colSize(y(r)));
        end

        meanVal(si,s)    = mean(val);
        speedVal(si,s)   = speed(s);
        sizeVal(si, s)   = dSize(si);
        stdError(si,s)   = std(val)/ sqrt(length(val));
    end
end

for si = 1:length(dSize)
    a{si} = loglog(speedVal(si,:), meanVal(si,:), strcat(markerInfo(si), 'o'), 'MarkerFaceColor', markerInfo(si), 'MarkerEdgeColor',markerInfo(si));
    e = errorbar(speedVal(si,:), meanVal(si,:), stdError(si,:), 'LineStyle', 'none');
    e.Color = markerInfo(si);
    e.LineWidth = 1;
    alpha(a{si},0.5)
end

xlim([0, 130])
xticks([10, 100])
ylim([0.1, 10])
yticks([0.1, 1, 10])
yline(1, '--')
xlabel('Speed deg/s')

legend([a{1}, a{2}, a{3}, a{4}], {'0.5 dva', '0.33 dva', '0.25 dva', '0.2 dva'}, 'Location','best')
legend('boxoff')

figure(5)
coherenceColors = {[0.8, 0.8784, 1], [0.6, 0.7608, 1], [0.3020, 0.5804, 1], [0, 0.4, 1], [0, 0.2784, 0.7020], [0, 0.1608, 0.4]};

flicker = [];
dotCoherence = [];
dotSpeed = [];
for f = 1:length(filesV2)
    for i = 1:size(filesV2{f}.trial, 2)
        flicker(f,i)  = 1/filesV2{f}.trial(i).flickerFrequency;
        
        if f == 1
            dotSpeed(f,i) = 3.75;
        elseif f == 2
            dotSpeed(f,i) = 7.5;
        elseif f == 3
            dotSpeed(f,i) = 15;
        elseif f == 4
            dotSpeed(f,i) = 30;
        elseif f == 5
            dotSpeed(f,i) = 60;
        elseif f == 6
            dotSpeed(f,i) = 120;
        end
        
        if filesV2{f}.trial(i).dotCoherence == 0
            dotCoherence(f,i) = 0;
        else
            dotCoherence(f,i) = filesV2{f}.trial(i).dotCoherence;
        end
    end
end

coherence = unique(dotCoherence);
speed     = unique(dotSpeed);

meanVal  = [];
cohVal   = [];
stdError = [];

for c = 1:length(coherence)
    for s = 1:length(speed)
        rowCoh    = [];
        rowSpeed  = [];
        colCoh    = [];
        colSpeed  = [];
        val       = [];

        [rowCoh, colCoh]     = find(dotCoherence(s,:) == coherence(c));

        for r = 1:length(colCoh)
            val(:,r) = flicker(s, colCoh(r));
            plot(dotSpeed(s),val(:,r), '.', 'Color', coherenceColors{c})
            hold on;
        end

        meanVal(s,c)  = mean(val);
        cohVal(s,c)   = coherence(c);
        speedVal(s,c) = speed(s);
        stdError(s,c) = std(val)/ sqrt(length(val));

        legendInfo{c} = plot(speedVal(s,c), meanVal(s,c), 'o', 'MarkerFaceColor',coherenceColors{c}, 'MarkerEdgeColor', coherenceColors{c});
        e = errorbar(speedVal(s,c), meanVal(s,c), stdError(s,c), 'LineStyle', 'none');
        e.Color = coherenceColors{c};
        e.LineWidth = 1;

    end
end

xlim([0, 130])
xticks([10, 100])
ylim([0.1, 10])
yticks([0.1, 1, 10])
yline(1, '--')
xlabel('dot Speed (dg/s)')
set(gca, 'YScale', 'log')

legend([legendInfo{1}, legendInfo{2}, legendInfo{3}, legendInfo{4}, legendInfo{5}], num2str(coherence(1)), num2str(coherence(2)), num2str(coherence(3)), num2str(coherence(4)), num2str(coherence(5)), 'Location','southeast')
legend('boxoff')
        
figure(6) % Only speed 3.75 and 120
flicker = [];
dotCoherence = [];
dotSpeed = [];
for f = 1:length(filesV3)
    for i = 1:size(filesV3{f}.trial, 2)
        flicker(f,i)  = 1/filesV3{f}.trial(i).flickerFrequency;
        
        if f == 1
            dotSpeed(f,i) = 3.75;
        elseif f == 2
            dotSpeed(f,i) = 120;
        end
        
        if filesV3{f}.trial(i).dotCoherence == 0
            dotCoherence(f,i) = 0;
        else
            dotCoherence(f,i) = filesV3{f}.trial(i).dotCoherence;
        end
    end
end

coherence = unique(dotCoherence);
speed     = unique(dotSpeed);

meanVal  = [];
speedVal = [];
cohVal   = [];
stdError = [];

for c = 1:length(coherence)
    for s = 1:length(speed)
        rowCoh    = [];
        rowSpeed  = [];
        colCoh    = [];
        colSpeed  = [];
        val       = [];

        [rowCoh, colCoh]     = find(dotCoherence(s,:) == coherence(c));

        for r = 1:length(colCoh)
            val(:,r) = flicker(s, colCoh(r));
            plot(dotSpeed(s),val(:,r), '.', 'Color', coherenceColors{c})
            hold on;
        end

        meanVal(s,c)  = mean(val);
        cohVal(s,c)   = coherence(c);
        speedVal(s,c) = speed(s);
        stdError(s,c) = std(val)/ sqrt(length(val));

        legendInfo{c} = plot(speedVal(s,c), meanVal(s,c), 'o', 'MarkerFaceColor',coherenceColors{c}, 'MarkerEdgeColor', coherenceColors{c});
        e = errorbar(speedVal(s,c), meanVal(s,c), stdError(s,c), 'LineStyle', 'none');
        e.Color = coherenceColors{c};
        e.LineWidth = 1;

    end
    plot(speedVal(:, c), meanVal(:, c),'Color', coherenceColors{c}, 'LineStyle','-', 'LineWidth',1)
end

xlim([0, 130])
xticks([10, 100])
ylim([0.1, 10])
yticks([0.1, 1, 10])
yline(1, '--')
xlabel('dot Speed (dg/s)')
set(gca, 'YScale', 'log')

legend([legendInfo{1}, legendInfo{2}, legendInfo{3}, legendInfo{4}, legendInfo{5}], num2str(coherence(1)), num2str(coherence(2)), num2str(coherence(3)), num2str(coherence(4)), num2str(coherence(5)), 'Location','southeast')
legend('boxoff')

