function drawChoice(win,tCount,stim,pos,choices)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% drawChoice.m: draw targets & coins for dsd
%
%               ~wem3 - 141030
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch choices
  case 2
    leftCoin = Screen('MakeTexture',win,(stim.leftCoin{tCount}));
    rightCoin = Screen('MakeTexture',win,(stim.rightCoin{tCount}));
    Screen('DrawTexture',win,leftCoin,[],pos.coinBoxL);
    Screen('DrawTexture',win,rightCoin,[],pos.coinBoxR);
    DrawFormattedText(win, (stim.leftText{tCount}), 'center',pos.yTarget, stim.leftColor{tCount},[],[],[],[],[],pos.choiceBoxL);
    DrawFormattedText(win, (stim.rightText{tCount}), 'center',pos.yTarget, stim.rightColor{tCount},[],[],[],[],[],pos.choiceBoxR);
  case 1
    rightCoin = Screen('MakeTexture',win,(stim.rightCoin{tCount}));
    Screen('DrawTexture',win,rightCoin,[],pos.coinBoxR);
    DrawFormattedText(win, (stim.rightText{tCount}), 'center',pos.yTarget, stim.rightColor{tCount},[],[],[],[],[],pos.choiceBoxR);
  case 0
    leftCoin = Screen('MakeTexture',win,(stim.leftCoin{tCount}));
    Screen('DrawTexture',win,leftCoin,[],pos.coinBoxL);
    DrawFormattedText(win, (stim.leftText{tCount}), 'center',pos.yTarget, stim.leftColor{tCount},[],[],[],[],[],pos.choiceBoxL);
end

return