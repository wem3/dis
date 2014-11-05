function [win, winBox, pos, experimentStart] = initScreen()
% % INITSCREEN.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   usage: [win, winBox, pos, experimentStart] = initScreen()
%
%   initializes screen & set params for tasks in PTB-3
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   author: wem3
%   written: 141031
%   modified: 141104 ~wem3
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% screen
Screen('Preference', 'VisualDebugLevel', 1);
Screen('Preference', 'SkipSyncTests', 1); % super dangerous, man
PsychDefaultSetup(2);
rng('shuffle'); % if incompatible with older machines, use >> rand('seed', sum(100 * clock));
screenNumber = max(Screen('Screens'));

% define colors
pos.white = WhiteIndex(screenNumber);
pos.grey = white / 2;
pos.black = BlackIndex(screenNumber);
pos.cyan = [0 255 242]; % cyan: #00FFF2
pos.pink = [242 0 255]; % pink: #F200FF
pos.yellow = [255 242 0]; % yellow: #FFF200

%% open a window
[win, winBox] = PsychImaging('OpenWindow', screenNumber, pos.black);

% flip to get ifi
Screen('Flip', win);
pos.ifi = Screen('GetFlipInterval', win);
% Screen('TextSize', win, 60);
Screen('TextSize', win, 60);

Screen('TextFont', win, 'Arial');
topPriorityLevel = MaxPriority(win);
Screen('BlendFunction', win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% find centre coordinate
[pos.xCenter, pos.yCenter] = RectCenter(winBox);
% make boxes on left & right for disclosure targets & coins
% choiceBox = [0 0 500 500];
% pos.choiceBoxL = CenterRectOnPointd(choiceBox,(pos.xCenter-330),(pos.yCenter-100));
% pos.choiceBoxR = CenterRectOnPointd(choiceBox,(pos.xCenter+330),(pos.yCenter-100));
% coinBox = [0 0 200 200];
% pos.coinBoxL = CenterRectOnPointd( coinBox , (pos.xCenter-330), (pos.yCenter-70) );
% pos.coinBoxR = CenterRectOnPointd( coinBox , (pos.xCenter+330), (pos.yCenter-70) );
% pos.yTarget = pos.yCenter - 360;

choiceBox = [0 0 500 350];
pos.choiceBoxL = CenterRectOnPointd(choiceBox,(pos.xCenter-330),(pos.yCenter-200));
pos.choiceBoxR = CenterRectOnPointd(choiceBox,(pos.xCenter+330),(pos.yCenter-200));
coinBox = [0 0 150 150];
pos.coinBoxL = CenterRectOnPointd(coinBox,(pos.xCenter-330),(pos.yCenter-150));
pos.coinBoxR = CenterRectOnPointd(coinBox,(pos.xCenter+330),(pos.yCenter-150));
pos.yTarget = pos.yCenter - 360;
pos.yStatement = pos.yCenter;
[~,experimentStart] = Screen('Flip',win);

end
