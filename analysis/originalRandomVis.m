clear all;
close all;

addpath('../data/mat')
addpath('../data/pilot')

file{1} = load("10202023_123302_06_4_1.mat");
file{2} = load("10112023_130931_06_3_1.mat");
file{3} = load("11222023_151550_46_1_3.mat");

markerCol = {[0, 0, 0], [0, 0, 0], [0.5, 0.5, 0.5]};

figure(1)

for f=1:length(file)
    for i = 1:size(file{f}.trial,2)
        flicker(f,i)  = 1/file{f}.trial(i).flickerFrequency;
        dotSpeed(f,i) = file{f}.trial(i).dotSpeed;

        loglog(dotSpeed(f,i), flicker(f,i), '.', 'Color', markerCol{f});
        hold on;
    end
end

speed = unique(dotSpeed);
row = [];
col = [];
val = [];

meanVal = [];
speedVal = [];
stdError = [];

% For original
for b = 1:2
    for s = 1:length(speed)
        if b == 1
            [row, col] = find(dotSpeed(1:2,:) == speed(s));
        elseif b == 2
            [row, col] = find(dotSpeed(3,:) == speed(s));
        end

        for r = 1:length(row)
            val(:,r) = flicker(row(r), col(r));
        end
        meanVal(:,s)  = mean(val);
        speedVal(:,s) = speed(s);
        stdError(:,s) = std(val)/ sqrt(length(val));
    end

    legendMarker{b} = loglog(speedVal, meanVal, 'o', 'MarkerFaceColor', markerCol{b+1}, 'MarkerEdgeColor',markerCol{b+1});
    e = errorbar(speedVal, meanVal, stdError, 'LineStyle','none');
    e.Color = markerCol{b+1};
    e.LineWidth = 1;

end

xlim([0, 130])
xticks([10, 100])
ylim([0.1, 10])
yticks([0.1, 1, 10])
yline(1, '--')
xlabel('Speed deg/s')
ylabel('Silencing Factor')

legend([legendMarker{1}, legendMarker{2}], {'Rotation', 'Random'}, 'Location','best')
legend('boxoff');

fig = gcf;

exportgraphics(fig, 'RotationVsRandom.pdf', 'ContentType','vector')