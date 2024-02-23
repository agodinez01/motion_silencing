% subject 1 quick vis

clear all;
close all;

addpath('../data/mat')

% block1 = load("10302023_125733_01_1_1.mat");
% block2 = load("10302023_132509_01_1_2.mat");
block3{1} = load("10302023_123521_01_1_3.mat");
block3{2} = load("10302023_142306_01_2_3.mat");

random{1} = load("11082023_133928_06_1_3.mat");
random{2} = load("11082023_140913_06_2_3.mat");
        
figure(1) % Only speed 3.75 and 120

coherenceColors = {[0.8, 0.8784, 1], [0.6, 0.7608, 1], [0.3020, 0.5804, 1], [0, 0.4, 1], [0, 0.2784, 0.7020], [0, 0.1608, 0.4]};

flicker = [];
dotCoherence = [];
dotSpeed = [];
for f = 1:length(block3)
    for i = 1:size(block3{f}.trial, 2)
        flicker(f,i)  = 1/block3{f}.trial(i).flickerFrequency;
        
        if f == 1
            dotSpeed(f,i) = 3.75;
        elseif f == 2
            dotSpeed(f,i) = 120;
        end
        
        if block3{f}.trial(i).dotCoherence == 0
            dotCoherence(f,i) = 0;
        else
            dotCoherence(f,i) = block3{f}.trial(i).dotCoherence;
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


figure(2)



% figure(1)
% flicker = [];
% 
% flicker = [];
% dotSpeed = [];
% for i = 1:size(block1.trial, 2)
%     flicker(1,i)  = 1/block1.trial(i).flickerFrequency;
%     dotSpeed(1,i) = block1.trial(i).dotSpeed;
% 
%     loglog(dotSpeed(1,i), flicker(1,i), '.k');
%     hold on
% end
% 
% speed = unique(dotSpeed);
% row = [];
% col = [];
% val = [];
% 
% meanVal  = [];
% speedVal = [];
% stdError = [];
% 
% for s = 1:length(speed)
%     [row, col] = find(dotSpeed == speed(s));
%     for r = 1:length(row)
%         val(:,r) = flicker(row(r),col(r));
%     end
%     meanVal(:,s)    = mean(val);
%     speedVal(:,s)   = speed(s);
%     stdError(:,s)   = std(val)/ sqrt(length(val));
% end
% 
% loglog(speedVal, meanVal, 'ok', 'MarkerFaceColor','k', 'MarkerEdgeColor','k')
% e = errorbar(speedVal, meanVal, stdError, 'LineStyle', 'none');
% e.Color = [0 0 0];
% e.LineWidth = 1;
% 
% xlim([0, 130])
% xticks([10, 100])
% ylim([0.1, 10])
% yticks([0.1, 1, 10])
% yline(1, '--')
% xlabel('Speed deg/s')
