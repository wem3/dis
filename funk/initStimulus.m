function [ stim ] = initStimulus( info, pos, coinFile, task, run )
% % INITSTIMULUS.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   usage: [ stim ] = initStimulus( info , pos , coinFile , task )
%
%   harvest info from .txt files, initialize stimuli PTB-3 task
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   author: wem3
%   written: 141031
%   modified: 141104 ~wem3
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% dependencies:
%    info (structure output from getSubInfo.m)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check for coinFile
if isempty(coinFile)
  coinFile = uigetfile('select image file for coin');
end

% check for taskFile (with stimulus/condition onset info)
taskFile = ( info.studyDir, filesep, 'paradigm', filesep, 'input', filesep [ info.subID, '_' , task , '.txt' ] );
if ~exist(taskFile,'file')
  taskFile = uigetfile('select .txt file with trial matrix');
else
  trialMatrix = dlmread(taskFile);
end

% check for statementFile (with list of 90 statements)
statementFile = ([demo.subID,'_',taskName,'_statements.txt']);
if ~exist(statementFile,'file')
  statementFile = uigetfile('select .txt file with list of statements');
else
  stim.statements(:,1) = textread(statementFile,'%s','delimiter','\n');
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

stim.color.self = stimColors(1);
stim.color.friend = stimColors(2);
stim.color.parent = stimColors(3);
stim.text = sText;
end
