function fadeNonChoice(win,tCount,stim,pos,choiceResponse)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% drawChoiceFeedback.m: draw a frame around the subject's choice
%
%               ~wem3 - 141030
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch choiceResponse
case 0
  fadeBox = pos.choiceBoxL;
case 1
  fadeBox = pos.choiceBoxR;
otherwise
  fadeBox = [pos.choiceBoxL(1),pos.choiceBoxL(2),pos.choiceBoxR(3),pos.choiceBoxR(4)];
end

% fadeVector is a vector we'll use to construct a gradient of transparencies
fadeVector = flip(1:0.1:0);
fader = [zeros(length(fadeVector),3),fadeVector];

for fadeCount = 1:length(fader)
  drawChoice(win,tCount,stim,pos,2);
  Screen('FillRect',win,fader(fadeCount), fadeBox);
  Screen('Flip',win);
  WaitSecs(pos.ifi)
end
% % drawChoice for frameless stimulus
% drawChoice(win,tCount,stim,pos,2);
% Screen('Flip',win)

% % make a rectangle and draw around the appropriate box
% drawChoice(win,tCount,stim,pos,2);
% Screen('FrameRect',win,responseColor,responseBox,3);
% Screen('Flip',win);
% WaitSecs(0.1);

% % now without a frame again
% drawChoice(win,tCount,stim,pos,2);
% Screen('Flip',win);
% WaitSecs(0.1);

end