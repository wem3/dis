function [ stim ] = initStimulus( info, pos, task, runNum )
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


% check for taskFile (with stimulus/condition onset info)
taskFile = ( info.studyDir, filesep, 'paradigm', filesep, 'input', filesep [ info.subID, '_' , task , '.txt' ] );
if ~exist(taskFile,'file')
  taskFile = uigetfile('select .txt file with trial matrix');
else
  trialMatrix = dlmread(taskFile);
end

% there are only forty, hardcode em (with list of 40 traits)
socialTraits = {...
'popular'
'uncool'
'outgoing'
'shy'
'likeable'
'creepy'
'attractive'
'ugly'
'interesting'
'boring'
'rebellious'
'conformist'
'well-behaved'
'mischevious'
'friendly'
'rude'
'earnest'
'disingenuous'
'courteous'
'inconsiderate'
};

nonSocialTraits = {...
'blonde'
'brunette'
'blue-eyed'
'brown-eyed'
'intelligent'
'facile'
'tall'
'short'
'fat'
'thin'
'strong'
'weak'
'flexible'
'rigid'
'voracious'
'illiterate'
'mathematical'
'innumerate'
'epic'
'banal'
};

stim.task = taskName;
stim.numTrials = length(trialMatrix);
stim.input = trialMatrix;

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













