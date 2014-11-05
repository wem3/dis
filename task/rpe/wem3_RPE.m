% Reward Processing Task
% Modified for OSX by Jessica Cohen 12/05
% Modified for use with new BMC trigger-same device as button box by JRC 1/07
% Modified for use with LCNI stimulus presentation boxen by wem3 on 131001(MATLAB2012b on 32-bit Windows XP)

        % rec_task is variable saved in .mat output file
        % rec_task columns: 1=blocktype (always 1)
        %                   2=list order number
        %                   3-trial number
        %                   4=trial duration
        %                   5-absolute time from start of task until stim
        %                   6-response
        %                   7-RT
        %                   8-stimulus
        %                   9-outcome (0 if eastern, 1 if northern)
        %                   10-prob of stim being associated with northern
        %                   11-magnitude of reward
        %                   12-reward amount-what subject actually gets
        %                   13-absolute time from start of task until fb

%                 STIMULUS LIST:
%                     Number  Prob Northern   Reward Mag
%                         1       .17             10
%                         2       .17             50
%                         3       .5              10
%                         4       .5              50
%                         5       .83             10
%                         6       .83             50


clear all;

%% get per-run user input

% subject code (use LCNI numbers?)
subject_code = input('Enter subject code: ','s');

% run 2 requires .mat output file from run 1
run_number = input('Enter run number (1 or 2): ');
if run_number==2,
    infilename2 = input('Enter previous scan file to open: ','s');
    load (infilename2);
end;

% alternate every other subject for counterbalance? ~#WEM3#~
list_order = input('Enter list order number (1 or 2): ');

MRI = input('Are you scanning? 1 if yes, 0 if no: '); % automatically requires button box if MRI
if MRI==0,
    button_box=input('Are you using the button box? 1 if yes, 0 if no: ');
elseif MRI==1;
    button_box=1;
end;

if button_box==1,
    which_box=input('Left or Right hand? 1 if Left, 2 if Right: ');
end;


infilename = sprintf('reward_onsets%d_prob.mat',list_order);
infilename2 = sprintf('%s_rp_%s_run1.mat',subject_code,date);

%% initialize variables to set up timing of experiment

inblock = 1;
startblock=inblock;
endblock=inblock;
STIM=3;                 % stimulus duration
FB=1.25;                % min feedback duration
ISIP=0.5;               % ISI between trials (why is it ISiP instead of ISP?)
min_break_time=5;       % minimum time for taking a break
POS = 50;               % relates to x direction for showing stimuli
stim_duration=STIM;
max_stim_duration=STIM;
stim_fb_interval=0.0;
fb_pres_time=FB;
ISI = ISIP;
outcome_text={'ZUR ' 'NYX '}; % text feedback that is displayed

if MRI==1,
    %trigger = KbName('t');
    trigger = KbName(52);
    if which_box==1,
        nyx = KbName('3');
        zur = KbName('2');
        response_codes=['2' '3']; % index finger = NYX = 3, middle finger = ZUR = 2
    elseif which_box==2;
        nyx = KbName('6');
        zur = KbName('7');
        response_codes=['7' '6']; % index finger = NYX = 6, middle finger = ZUR = 7
    end;
elseif button_box==1,
    if which_box==1,
        response_codes=[2 3]; % index finger = NYX = 3, middle finger = ZUR = 2
    elseif which_box==0;
        response_codes=[7 6]; % index finger = NYX = 6, middle finger = ZUR = 7
    end;

else,
    response_codes=[2 1];       % button codes for ZUR or NYX respectively (match to 0 and 1 in outcome respectively)
end;
reward_level=[0.1 0.5];
punish_level=[0.05 0.25];

% outcome probabilities for each stimulus
stim_probs=[.17 .17 0.5 0.5 .83 .83];
stim_magnitude=[10 50 10 50 10 50];

pixelSize = 32;

%% write trial-by-trial data to a text logfile
c=clock;
logfile=sprintf('%s_reward.log',subject_code);
fprintf('A log of this session will be saved to %s\n',logfile);
fid=fopen(logfile,'a');
if fid<1,
    error('could not open logfile!');
end;

fprintf(fid,'Started: %s %2.0f:%02.0f\n',date,c(4),c(5));
WaitSecs(1);

% read in trial info
load(infilename);

clear rec_task; % to clear previous run's rec_task if run 2
rec_task=cell(length(d),13);

% set # of trials
 ntrials=length(d);

%% set up input devices
numDevices=PsychHID('NumDevices');
devices=PsychHID('Devices');

if MRI==1,
    for n=1:numDevices,
        if (strcmp(devices(n).usageName,'Keyboard') && strcmp(devices(n).product,'Xkeys')),
            inputDevice=n;
                fprintf('Using Device #%d (%s)\n',inputDevice,devices(inputDevice).product);
            break,
        end;
    end;
    fprintf('Using Device #%d (%s)\n',inputDevice,devices(inputDevice).product);

elseif button_box==1,
   for n=1:numDevices,
        if (strcmp(devices(n).usageName,'Keyboard') && strcmp(devices(n).product,'Xkeys')),
            inputDevice=n;
                fprintf('Using Device #%d (%s)\n',inputDevice,devices(inputDevice).product);
            break,
        end;
    end;
end


%% set up screens
screens=Screen('Screens');
screenNumber=max(screens);
w=Screen('OpenWindow', screenNumber,0,[],32,2);
[wWidth, wHeight]=Screen('WindowSize', w);
grayLevel=0;
Screen('FillRect', w, grayLevel);
Screen('Flip', w);
HideCursor;
theFont='Arial';
FontSize=48;
Screen('TextSize',w,FontSize);
Screen('TextFont',w,theFont);

black=BlackIndex(w); % Should equal 0.
white=WhiteIndex(w); % Should equal 255.

xcenter=wWidth/2;
ycenter=wHeight/2;


%% load in images for reward stims (scr cell for task, rew_scr for reward)
stim_images=cell(1,6);
for x=1:6,
    fname=sprintf('abs%d.jpg',x); blktype=1;
	stim_images(x)={imread(fname,'jpg')};
end;

% image for reward
reward_image=cell(1,1);
fname=sprintf('reward.jpg');
reward_image = {imread(fname, 'jpg')};

scr = cell(1,1);
rew_scr = cell(1,1);


% define keys for each category
%if MRI==1,
%    c1_key='b'; % blue = northern
%    c2_key='y'; % yellow = eastern
%else,
    c1_key='nyx'; % 1 = northern
    c2_key='zur'; % 2 = eastern
%end;

% Set up initial screen
if MRI==1,
    Screen('DrawText',w,'Waiting for trigger...',xcenter-250, ycenter);
    Screen('Flip',w);
else,
    Screen('TextColor',w,255);
    Screen('DrawText',w,'Press 1 if Northern U.',xcenter-250,ycenter-100);
    Screen ('DrawText',w,'Press 2 if Eastern U.',xcenter-250,ycenter);
    Screen('DrawText',w,'Press any key to begin',xcenter-265,ycenter+100);
    Screen('Flip',w);
end;

if MRI==1,
    trigger=([52]);
    experiment_start_time=KbTriggerWait(trigger,inputDevice);
    DisableKeysForKbCheck(trigger); % So trigger is no longer detected
else,
    KbWait(homeDevice);  % wait for keypress
    experiment_start_time=GetSecs;
    noresp=1;
    while noresp,
    [keyIsDown,secs,keyCode] = KbCheck(inputDevice);
        if keyIsDown & noresp,
            noresp=0;
        end;
    end;
    WaitSecs(0.001);
end;
WaitSecs(0.5);  % prevent key spillover

%DisableKeysForKbCheck(KbName([52])); % So trigger is no longer detected

% get absolute starting time anchor
anchor=GetSecs;

trial_counter=0; %refers to entire 100 + 60 baseline trial series
%total_reward=zeros(num_breaks+1);  % add 1 for end of experiment
if run_number==1,
    total_reward=0;
else,
    total_reward=total_reward;
end;


try,  %part of try...catch (line 302)

    noresp=0;  % set to zero initially


    for trial=1:ntrials, % start trial loop

        trial_counter=trial_counter+1;

        %to wait until onset time to display stimulus
        while GetSecs - anchor < d(trial_counter,1),
        end;

        % display the stimulus
        if(d(trial_counter,3)>0),
            Screen('PutImage',w,stim_images{d(trial,3)},[xcenter-100 ycenter-100 xcenter+100 ycenter+100]);
        end;

        %to wait until onset time to display stimulus
        while GetSecs - anchor < d(trial_counter,1),
        end;

        Screen('Flip',w);
        start_time=GetSecs;

        % variables saved to output file
        rec_task{trial_counter,1}=blktype; %stores event: 1 if prob, 2 if det
        rec_task{trial_counter,2}=list_order; %stores list order number
        rec_task{trial_counter,3}=trial_counter; % stores trial number
        rec_task{trial_counter,5}=start_time-anchor; %stores absolute time that stim is displayed

        % to collect responses and RTs
        noresp=1;
        while noresp,
            [keyIsDown,secs,keyCode] = KbCheck(inputDevice);
            if MRI==1,
                if keyIsDown & noresp,
                    tmp=KbName(keyCode);
                    rec_task(trial_counter,6)={tmp(1)};
                    rec_task(trial_counter,7)={GetSecs-start_time};
                    noresp=0;
                end;
            else,
                if keyIsDown & noresp,
                    tmp=KbName(keyCode);
                    rec_task(trial_counter,6)={tmp(1)};
                    rec_task(trial_counter,7)={GetSecs-start_time};
                    noresp=0;
                end;
            end;

            if GetSecs - anchor > d(trial_counter,2),
                noresp=0;
            end;
            WaitSecs(0.001);
        end;

        % more variables saved to output file
        rec_task{trial_counter,8}=d(trial_counter,3); % stimulus number
        rec_task{trial_counter,9}=d(trial_counter,4); % outcome
        rec_task{trial_counter,10}=stim_probs(rec_task{trial_counter,8}); % to determine prob northern
        rec_task{trial_counter,11}=stim_magnitude(rec_task{trial_counter,8}); % to determine reward mag of each stim


        % to display feedback
        fb_anchor=GetSecs;

        Screen('TextColor',w,255);
        show_trial_num=0;  %set to 1 for trouble-shooting so can see what trial you're on
        if show_trial_num,
            Screen('DrawText',w,[outcome_text{d(trial_counter,4)+1} ' - trial ' num2str(trial_counter)],xcenter-135,ycenter-150);
        else,
            Screen('DrawText',w,outcome_text{d(trial_counter,4)+1},xcenter-50,ycenter-170);
        end;

        % For displaying reward (fix MRI portion to match practice portion)
        if MRI==1,
            if iscell(rec_task{trial_counter,6}),
                rec_task{trial_counter,6}=cell2mat(rec_task{trial_counter,6});
                fprintf('trial %d was a cell\n',trial_counter);
            end;
            if ((rec_task{trial_counter,9}==0 & (rec_task{trial_counter,6})==response_codes(1)) | ...
                (rec_task{trial_counter,9}==1 & (rec_task{trial_counter,6})==response_codes(2))),
                    % first set the variable to the amount that they won
                    rec_task{trial_counter,12}=rec_task{trial_counter,11};
                if rec_task{trial_counter,11}==10,
                    Screen('PutImage',w,reward_image{1},[xcenter-30 ycenter+130 xcenter+30 ycenter+190]);
                else,
                    Screen('PutImage',w,reward_image{1},[xcenter-150 ycenter+130 xcenter-90 ycenter+190]);
                    Screen('PutImage',w,reward_image{1},[xcenter-90 ycenter+130 xcenter-30 ycenter+190]);
                    Screen('PutImage',w,reward_image{1},[xcenter-30 ycenter+130 xcenter+30 ycenter+190]);
                    Screen('PutImage',w,reward_image{1},[xcenter+30 ycenter+130 xcenter+90 ycenter+190]);
                    Screen('PutImage',w,reward_image{1},[xcenter+90 ycenter+130 xcenter+150 ycenter+190]);
               end;
            else,
                rec_task{trial_counter,12}=0;
            end;
        else,
            if iscell(rec_task{trial_counter,6}),
                rec_task{trial_counter,6}=cell2mat(rec_task{trial_counter,6});
                fprintf('trial %d was a cell\n',trial_counter);
            end;
            if ((rec_task{trial_counter,9}==0 & str2double(rec_task{trial_counter,6})==response_codes(1)) | ...
                (rec_task{trial_counter,9}==1 & str2double(rec_task{trial_counter,6})==response_codes(2))),
                % first set the variable to the amount that they won
                rec_task{trial_counter,12}=rec_task{trial_counter,11};
                if rec_task{trial_counter,11}==10,
                    if show_trial_num,
                        fprintf('trial %d: displayed 1 coin\n',trial_counter);
                    end;
                    Screen('PutImage',w,reward_image{1},[xcenter-30 ycenter+130 xcenter+30 ycenter+190]);
                else,
                    if show_trial_num,
                        fprintf('trial %d: displayed 5 coins\n',trial_counter);
                    end;
                    Screen('PutImage',w,reward_image{1},[xcenter-150 ycenter+130 xcenter-90 ycenter+190]);
                    Screen('PutImage',w,reward_image{1},[xcenter-90 ycenter+130 xcenter-30 ycenter+190]);
                    Screen('PutImage',w,reward_image{1},[xcenter-30 ycenter+130 xcenter+30 ycenter+190]);
                    Screen('PutImage',w,reward_image{1},[xcenter+30 ycenter+130 xcenter+90 ycenter+190]);
                    Screen('PutImage',w,reward_image{1},[xcenter+90 ycenter+130 xcenter+150 ycenter+190]);
                end
            else
                rec_task{trial_counter,12}=0;
            end
        end;
        %calculates cumulative reward won
        total_reward=total_reward + rec_task{trial_counter,12};
        if(d(trial_counter,3)>0),
            Screen('PutImage',w,stim_images{d(trial,3)},[xcenter-100 ycenter-100 xcenter+100 ycenter+100]);
        end;

        % to wait until appropriate time to display feedback
        while GetSecs - anchor < d(trial_counter,2),
        end;

        if GetSecs - anchor > d(trial_counter,2),
            noresp=0;
        end;
        WaitSecs(0.001);


        Screen('Flip',w);
        rec_task{trial_counter,13}=GetSecs-anchor; %stores absolute time that fb is displayed

        WaitSecs(fb_pres_time);
        rec_task{trial_counter,4}=GetSecs - start_time; %stores trial duration
        Screen('Flip',w);

        % print trial info to log file
        tmpTime=GetSecs;
        try,
            fprintf(fid,'%d\t%0.3f\t%0.3f\t%d\t%0.3f\t%d\t%d\t%0.1f\t%d\t%0.2f\n',...
               rec_task{trial_counter,3:12});
        catch,   % if sub responds weirdly, trying to print the resp crashes the log file...instead print "ERR"
            fprintf(fid,'%d\t%0.3f\t%0.3f\tERR\t',rec_task{trial_counter,3:5});
            fprintf(fid,'%0.3f\t%d\t%d\t%0.1f\t%d\t%0.2f\n',rec_task{trial_counter,7:12});
        end;

    end;  % end loop through trials

    % clears the screen
    Screen('Flip',w);


% display final screen

Screen('DrawText',w,'End of experiment.',xcenter-250,ycenter);
Screen('DrawText',w,sprintf('You won %d tokens!',total_reward/10),xcenter-250,ycenter+100);
Screen('FillRect',w,[0 100 0],[xcenter-400+POS (ycenter+300-total_reward/6) xcenter-350+POS ycenter+300],[]);
Screen('TextSize',w,24);
Screen('DrawText',w,'Total Winnings',xcenter-460+POS,ycenter+320);
Screen('Flip',w);


%try,   %dummy try when troubleshooting

catch,   %part of try (line 159)...catch command in case program crashes
    rethrow(lasterror);   %command returns to keyboard

    Screen('CloseAll');
    ShowCursor;
end;

if MRI==1,
    WaitSecs(10);
else,
    noresp=1;
    while noresp,
        [keyIsDown,secs,keyCode] = KbCheck(inputDevice);
		if keyIsDown & noresp,
            noresp=0;
		end;
        WaitSecs(0.001);
    end;
end;
Screen('CloseAll');
ShowCursor;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save data to a file, with date/time stamp
c=clock;
outfile=sprintf('%s_rp_run%d_%s_%02.0f-%02.0f.mat',subject_code,run_number,date,c(4),c(5));

% create a data structure with info about the run
run_info.initials=subject_code;
run_info.date=date;
run_info.run_number=run_number;
run_info.list_order=list_order;
run_info.outfile=outfile;
run_info.run_number=run_number;
run_info.list_order=list_order;
try,
    save(outfile, 'run_info','rec_task','total_reward');
catch,
    fprintf('couldn''t save %s\n saving to reward_proc.mat\n',outfile);
    save reward_proc;
end;



