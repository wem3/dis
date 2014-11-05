function dsdTask()
% %DSDTASK.m: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% dsdTask.m: differential self disclosure task
%
%               ~wem3 - 141028 (no foolzies)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% try
% switch nargin
%   case 0
%     subID = input('Enter subID (>> "sub999" ): ', 's');
%     studyDir = input('Enter studyDir (>> "~/Desktop/dis" ): ', 's');
%     runNum = input('Which run? (>> 1 ):';
%   case 1
%     subID = varargin{1};
%     studyDir = input('Enter studyDir (>> "~/Desktop/dis" ): ', 's');
%     runNum = input('Which run? (>> 1 ):';
%   case 2
%     subID = varargin{1};
%     studyDir = varargin{2};
%     runNum = varargin{3};
%   otherwise
%     error('dsdTask only takes 0-2 inputs, try (>> dsdTask() ): ')
% end

% make sure it's a directory, make sure subInfoMat exists
[subInfoMat, subInfoPath] = uigetfile('*.mat','Select .mat with subject info:')
if ~exist([subInfoPath,subInfoMat],'file')
  info = getSubInfo();
else
  load([subInfoPath,subInfoMat]);
end

studyDir = info.studyDir

% initialize the screen
[win, winBox, pos, experimentStart] = initScreen();
% initialize task, stimulus, keys, position, etc.

% taskName for appropriate .txt
task = ['svc_run',num2str(runNum)];
% fire up the stimulus, assign trial specific properties
stim = initStimulus(info, pos, coinFile, task );
outputFile = ([info.subID,'_',stim.task,'_','output','.txt']);
rawOutput = NaN(stim.numTrials,7);
% probe button box, set keys
[devices, inputDevice, keys] = initKeys();

%% present during multiband calibration (time shortened for debug)
% remind em' not to squirm!
DrawFormattedText(win, 'Calibrating scanner\n\n Please hold VERY still',...
  'center', 'center', pos.white);
Screen('Flip', win);
DrawFormattedText(win, 'Sharing Experiment:\n\n Get Ready!',...
  'center', 'center', pos.white);
WaitSecs(3);
Screen('Flip', win);

%% trigger pulse code
KbTriggerWait(keys.trigger);
disabledTrigger = DisableKeysForKbCheck(keys.trigger);
triggerPulseTime = GetSecs;
disp('trigger pulse received, starting experiment');
Screen('Flip', win);

%% define keys to listen for, create KbQueue (coins & text drawn while it warms up)
keyList = zeros(1,256);
keyList([keys.buttons keys.kill])=1;
leftKeys = ([keys.b0 keys.b1 keys.b2 keys.b3 keys.b4 keys.left]);
rightKeys = ([keys.b5 keys.b6 keys.b7 keys.b8 keys.b9 keys.right]);
KbQueueCreate(inputDevice, keyList);
% shut off input to command window
ListenChar(2);
%% trial loop
for tCount = 1:stim.numTrials
  %% try with KbPressWait...
  drawChoice(win,tCount,stim,pos,2);
  [~, choiceOnset] = Screen('Flip',win);
  % collect responses
  stopChoiceTime = GetSecs+3;
  [choiceSecs, choicePress] = KbPressWait(inputDevice,stopChoiceTime);
  if find(choicePress)
      choiceKey = find(choicePress);
      choiceRT = choiceSecs - choiceOnset;
  else
      choiceKey = 0;
  end

  % this looks clunky, but it's more consistent and faster than any other
  % way I could figure out to correctly check the choiceKey against a
  % vector. Order is based on likelihood of having selected that key,
  % based on which finger is assigned on the button box (less relevant
  % for keyboard)

  switch choiceKey
      case 0
          DrawFormattedText(win, 'too slow!', 'center', pos.yStatement, pos.white);
          choiceResponse = NaN;
          choiceRT = NaN;
      case keys.b3
          choiceResponse = 0;
      case keys.b6
          choiceResponse = 1;
      case keys.b2
          choiceResponse = 0;
      case keys.b7
          choiceResponse = 1;
      case keys.b4
          choiceResponse = 0;
      case keys.b5
          choiceResponse = 1;
      case keys.b1
          choiceResponse = 0;
      case keys.b8
          choiceResponse = 1;
      case keys.b0
          choiceResponse = 0;
      case keys.b9
          choiceResponse = 1;
  end

  % blink a box around the chosen answer
  drawChoiceFeedback(2,win,tCount,stim,pos,choiceResponse);
  % Screen('Flip',win);

  % draw the option they chose
  drawChoice(win,tCount,stim,pos,choiceResponse);
  % draw the statement
  DrawFormattedText(win, (stim.statement{tCount}), 'center',pos.yStatement, pos.white);
  waitTime = (stopChoiceTime - GetSecs  + stim.choiceJitter{tCount});
  WaitSecs(waitTime);
  %% aaaaaand, go!
  KbQueueFlush(inputDevice);
  %% try with KbPressWait...
  drawChoice(win,tCount,stim,pos,choiceResponse);
  [~, discoOnset] = Screen('Flip',win);
  % collect responses
  stopDiscoTime = GetSecs+3;
  [discoSecs, discoPress] = KbPressWait(inputDevice,stopDiscoTime);
  if find(discoPress)
      discoKey = find(discoPress);
      discoRT = discoSecs - discoOnset;
  else
      discoKey = NaN;
      discoRT = NaN;
  end
  switch discoKey
      case 0
          DrawFormattedText(win, 'too slow!', 'center', pos.yStatement, pos.white);
          discoResponse = NaN;
          discoRT = NaN;
      case keys.b3
          discoResponse = 0;
      case keys.b6
          discoResponse = 1;
      case keys.b2
          discoResponse = 0;
      case keys.b7
          discoResponse = 1;
      case keys.b4
          discoResponse = 0;
      case keys.b5
          discoResponse = 1;
      case keys.b1
          discoResponse = 0;
      case keys.b8
          discoResponse = 1;
      case keys.b0
          discoResponse = 0;
      case keys.b9
          discoResponse = 1;
  end


  KbQueueFlush(inputDevice);
  Screen('Flip',win);
  waitTime = (stopDiscoTime - GetSecs + stim.discoJitter{tCount});
  WaitSecs(waitTime);
% assign output for each trial to rawOutput matrix
rawOutput(tCount,1) = tCount;
rawOutput(tCount,2) = choiceOnset;
rawOutput(tCount,3) = choiceResponse;
rawOutput(tCount,4) = choiceRT;
rawOutput(tCount,5) = discoOnset;
rawOutput(tCount,6) = discoResponse;
rawOutput(tCount,7) = discoRT;
dlmwrite(outputFile,rawOutput(tCount,:),'-append');
end
% End of experiment screen. We clear the screen once they have made their
% response
DrawFormattedText(win, 'Experiment Finished \n\n Press Any Key To Exit',...
    'center', 'center', pos.white);
Screen('Flip', win);
ListenChar(0)
KbStrokeWait;
Screen('Close',win)
catch
  Screen('CloseAll')
  ListenChar(0)
  rethrow(lasterror)
end