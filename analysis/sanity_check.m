% Check if speed in the rotation condition (1) is the same as the linear
% condition (3)

clear all;
close all;

addpath('../data/mat')

data{1} = load("b1.mat");
data{2} = load("b3.mat");


% data{1} = load("block1.mat");
% data{2} = load("block3.mat");

dotSpeed = [3.75, 7.5, 15, 30, 60, 120];

% Get list of trials 
trialList = {};

% Calculate delta angle
for b=1:2
    for speed=1:length(dotSpeed)
        for trial=1:size(data{1}.trial,2)
            if find(data{b}.trial(trial).dotSpeed == dotSpeed(speed))
                trialList{b}.speed(:,speed) = dotSpeed(speed);
                trialList{b}.trial(:,speed) = trial;
            else
                continue
            end
        end
    end
end

dataRotation = {};
dataLinear   = {};
for speed=1:length(dotSpeed)
    dataRotation{speed} = data{1}.trial(trialList{1}.trial(speed));
    dataLinear{speed}   = data{2}.trial(trialList{2}.trial(speed)); 
end

% for speed=1:length(dotSpeed)
%      
% 
% end

data