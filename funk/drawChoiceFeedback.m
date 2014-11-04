function drawChoiceFeedback(blinks,win,tCount,stim,pos,choiceResponse)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% drawChoiceFeedback.m: draw a frame around the subject's choice
%
%               ~wem3 - 141030
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch choiceResponse
case 0
  responseBox = pos.choiceBoxL;
  responseColor = stim.leftColor{tCount};
  fadeBox = pos.choiceBoxR;
case 1
  responseBox = pos.choiceBoxR;
  responseColor = stim.rightColor{tCount};
  fadeBox = pos.choiceBoxL;
otherwise
  fadeBox = [pos.choiceBoxL(1),pos.choiceBoxL(2),pos.choiceBoxR(3),pos.choiceBoxR(4)];
  responseBox = fadeBox;
  responseColor = pos.black;
end

% fadeVector is a vector we'll use to construct a gradient of transparencies
fadeVector = (0.1:0.1:1);
% glowVector is fadeVector flipped, for the opposite purpose
glowVector = flip(fadeVector);
% %% first, blink around the chosen box
% for blinkCount = 1:blinks;
%   % drawChoice for frameless stimulus
%   drawChoice(win,tCount,stim,pos,2);
%   Screen('Flip',win)
%   % make a rectangle and draw around the appropriate box
%   drawChoice(win,tCount,stim,pos,2);
%   Screen('FrameRect',win,responseColor,responseBox,3);
%   Screen('Flip',win)
%   WaitSecs(0.1)
%   % now without a frame again
%   drawChoice(win,tCount,stim,pos,2);
%   Screen('Flip',win)
%   WaitSecs(0.1)
% end

%% now fade the non-chosen box
for fadeCount = 1:length(fadeVector)
  drawChoice(win,tCount,stim,pos,2);
  % chosen box
  Screen('FrameRect',win,[responseColor fadeVector(fadeCount)],responseBox,3);
  % fade box
  Screen('FillRect',win,[0 0 0 fadeVector(fadeCount)], fadeBox);
  Screen('Flip',win);
  % adjust to acheive desired fade
  WaitSecs(0.03)
end

end