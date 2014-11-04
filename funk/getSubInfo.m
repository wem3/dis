function demo = getSubInfo()
% GETDISSINFO.M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
'name: subName = ',...
'subID: subID = ',...
'friend: friendName = ',...
'parent: parentName = ',...
'gender: subGender = ',...
'birthday: DOB = '};
dTitle = 'define subject specific variables';
nLines = 1;
def = {'Subastian','999','Ricky','Mom','M','04-Jul-1994'};
manualInput = inputdlg(prompt,dTitle,nLines,def);
subName = manualInput{1};
subID = ['sub',manualInput{2}];
friendName = manualInput{3};
parentName = manualInput{4};
subGender = manualInput{5};
DOB = manualInput{6};

% also store to demo structure
demo.name = subName;
demo.subID = subID;
demo.friend = friendName;
demo.parent = parentName;
demo.gender = subGender;
demo.DOB = DOB;
demo.DOstudy = datestr(now);

subInfoMat = [subID,'_demoOut.mat'];

% crash out if subInfoMat exists, otherwise save
if exist(subInfoMat,'file')
  error([subID, ' already has an info.mat file'])
else
  save(subInfoMat,'demo');
end

return

