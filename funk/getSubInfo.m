function info = getSubInfo()
% GETSUBINFO.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   usage: demo = getSubInfo()
%   takes no input, saves harvested subject info dialog to a structure, demo
%
%   author: wem3
%   written: 141031
%   modified: 141104 ~wem3
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prompt for study directory (highest level)
studyDir = uigetdir('top study directory');
% set subject specific parameters
prompt = {...
'subID: subID = ',...
'study directory: studyDir = ',...
'name: subName = ',...
'friend: friendName = ',...
'parent: parentName = ',...
'gender: subGender = ',...
'birthday: DOB = ',...
'handedness: hand = ',...
'experimentor: exptID = '};
dTitle = 'define subject specific variables';
nLines = 1;
def = { '999', '~/Desktop/dis' , 'Subastian' , 'Ricky' , 'Mom' , 'M' , '04-Jul-1994' , 'R' , 'wem3' };
manualInput = inputdlg(prompt,dTitle,nLines,def);
info.subID = ['sub',manualInput{1}];
info.studyDir = manualInput{2};
info.subName = manualInput{3};
info.friendName = manualInput{4};
info.parentName = manualInput{5};
info.subGender = manualInput{6};
info.DOB = manualInput{7};
info.hand = manualInput{8};
info.exptID = manualInput{9};
info.exptDate = datestr(now);
info.inputDir = [studyDir,filesep,'paradigm',filesep,'input'];
info.outputDir = [studyDir,filesep,'paradigm',filesep,'output'];
info.throughputDir = info.inputDir = [studyDir,filesep,'paradigm',filesep,'throughput'];

subInfoMat = [info.throughputDir, filesep ([subID,'_disInfo.mat'])];

% crash out if subInfoMat exists, otherwise save
if exist(subInfoMat,'file')
  error([subID, ' already has an info.mat file'])
else
  save(subInfoMat,'info');
end

return

