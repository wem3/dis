function [ stim ] = initStimulus( demo, pos, coinFile, taskName )
% % initStimulus.m ***********************************************
%
%   set up the button box, dump
%
%******************************************************************
%
% Written by wem3
%
% last modified 2014/10/31
%
%******************************************************************
%
% Dependencies:
%    demo (structure output from getDissInfo.m)
%    makeCoinTextures.m
%
% Used By:s
%
%******************************************************************

% check for coinFile
if isempty(coinFile)
  coinFile = uigetfile('select image file for coin');
end

% check for stimFile
stimFile = ([demo.subID,'_',taskName,'.txt']);
if ~exist(stimFile,'file')
  stimFile = uigetfile('select .txt file with stimulus matrix');
else
  trialMatrix = dlmread(stimFile);
end

stim.task = taskName;
stim.numTrials = length(trialMatrix);
stim.input = trialMatrix;
coinImg = imread(coinFile);

% make 400 x 400 images for one, two, three, or four pennies, convert to
coin1 = [zeros(100,400,3); [zeros(200,100,3), coinImg, zeros(200,100,3)]; zeros(100,400,3)];
coin2 = [zeros(100,400,3); [coinImg, coinImg]; zeros(100,400,3)];
coin3 = [zeros(200,100,3), coinImg, zeros(200,100,3); coinImg,coinImg];
coin4 = [coinImg,coinImg;coinImg,coinImg];
coin0 = zeros(400,400,3);
targetCoin = {coin1, coin2, coin3, coin4, coin0};
% randomly assign to targets
stimColors = Shuffle( { pos.cyan, pos.pink, pos.yellow });
% store in targetColors
targetColor = {stimColors{1}, stimColors{2}, stimColors{3}};

% initialize text variables, store in textTargets
sText.self = 'keep it private';
sText.friend = ['share with ', demo.friend];
sText.parent = ['share with ', demo.parent];
targetText = {sText.self, sText.parent, sText.friend};

% initialize some empty variables
stim.leftText = cell(stim.numTrials,1);
stim.rightText = cell(stim.numTrials,1);
stim.leftCoin = cell(stim.numTrials,1);
stim.rightCoin = cell(stim.numTrials,1);
stim.leftColor = cell(stim.numTrials,1);
stim.rightColor = cell(stim.numTrials,1);
stim.choiceJitter = cell(stim.numTrials,1);
stim.discoJitter = cell(stim.numTrials,1);

for tCount = 1:(stim.numTrials)
  stim.leftText{tCount}     = targetText{trialMatrix(tCount,2)};
  stim.rightText{tCount}    = targetText{trialMatrix(tCount,3)};
  stim.leftCoin{tCount}     = targetCoin{trialMatrix(tCount,4)};
  stim.rightCoin{tCount}    = targetCoin{trialMatrix(tCount,5)};
  stim.leftColor{tCount}    = targetColor{trialMatrix(tCount,2)};
  stim.rightColor{tCount}   = targetColor{trialMatrix(tCount,3)};
  stim.choiceJitter{tCount} = trialMatrix(tCount,6);
  stim.discoJitter{tCount}  = trialMatrix(tCount,7);
end


stim.statement = {'I shower in the morning'
'I hate rainy days'
'I make my own lunch'
'I want to learn to surf'
'I hate pulling weeds'
'I keep a tidy bedroom'
'I hate spicy mustard'};
stim.color.self = stimColors(1);
stim.color.friend = stimColors(2);
stim.color.parent = stimColors(3);
stim.text = sText;
end
% read in coin image, store for [1 2 3 4 0] coins in stim structure
% (note, will need to make texture later)
% stim.data.subID = demo.subID;
% stim.data.name = taskName;
% stim.data.numTrials = length(trialMatrix);
% stim.data.multiBandStartTime = NaN;
% stim.data.triggerPulseTime = NaN;
% stim.data.trialNum = trialMatrix(:,1);
% stim.data.trialOnset = NaN(stim.task.numTrials,1);
% stim.data.choiceOnset = NaN(stim.task.numTrials,1);
% stim.data.choiceResponse = NaN(stim.task.numTrials,1);
% stim.data.choiceRT = NaN(stim.task.numTrials,1);
% stim.data.discoOnset = NaN(stim.task.numTrials,1);
% stim.data.discoResponse = NaN(stim.task.numTrials,1);
% stim.data.discoRT = NaN(stim.task.numTrials,1);