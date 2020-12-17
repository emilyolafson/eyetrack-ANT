%extract behavioural data from ANT files
    % Will organize the info into a common structure called 'metrics' from the 
    % eprime files that are named CONDITION_###_S#_ANT.txt, where CONDITION will
    % be used for the top level of data segregation, ### to assign subject number,
    % and S#, to assign the session. ANT.txt is used to only look at these files and
    % not anything else in the directory. Will ignore dashes (erase them); to fix
    % any other errors due to invalid fieldnames, look at lines 16-21. Also overwrites
    % RT on omitted trials to 1700 and creates congruency vector based on CN.

% file path to the .txt files with eprime output
curr_dir=pwd;
behav_dir=strcat(curr_dir, '/AttentionNetwork_Behavioural/')
fid = fopen(strcat(behav_dir, 'files.txt'));

line1 = fgetl(fid)

while ischar(line1)
    filepath=strcat(behav_dir, line1);
    listfiles=dir(filepath)
    
    for file = 1:size(listfiles,1)
        filename = listfiles(file).name;

        % parse fieldnames and indices (subject number)
        underscoreind = strfind(filename, '_')
        groupname = filename(1:underscoreind - 3)
        % check that the groupname can be evaluated to a valid fieldname and
        % fix if it can't. So far the dash is the only problem, so fix that.

        subjnum = str2double(filename(underscoreind -3:underscoreind - 1))
        sessionnum = strcat('S',filename(underscoreind + 2));

        warning off MATLAB:iofun:UnsupportedEncoding;

        %read in UTF-16 textfile
        fid2 = fopen(filepath, 'r', 'n', 'UTF16LE');
        content=fread(fid2,[1 inf],'*char');
        fclose(fid2);

        %split lines (including possible windows \r\n)
        content=strsplit(content,{'\r','\n'});

        %only keep lines with ":" 
        content=content(~cellfun(@isempty,strfind(content,':')));

        %extract numerical value from lines containing "SlideTarget.ACC:"
        index=~cellfun(@isempty,regexp(content,'^\s*SlideTarget.ACC:'));
        metrics.(groupname)(subjnum).(sessionnum).acc=str2double(regexprep(content(index),'^\s*SlideTarget.ACC:',''))

        %extract numerical value from lines containing "SlideTarget.RT:"
        index=~cellfun(@isempty,regexp(content,'^\s*SlideTarget.RT:'));
        metrics.(groupname)(subjnum).(sessionnum).rtime=str2double(regexprep(content(index),'^\s*SlideTarget.RT:',''))

        % overwrite RT for omission errors
        metrics.(groupname)(subjnum).(sessionnum).rtime(metrics.(groupname)(subjnum).(sessionnum).rtime == 0) = 1700;

        %extract numerical value from lines containing "ConditionNumber:"
        index=~cellfun(@isempty,regexp(content,'^\s*ConditionNumber:'));
        metrics.(groupname)(subjnum).(sessionnum).CN=str2double(regexprep(content(index),'^\s*ConditionNumber:',''));

        % add congruency vector

        % CNs for congruent cues: 1 4 7 10 19 22

        congruentCNs = [1 4 7 10 19 22];
        metrics.(groupname)(subjnum).(sessionnum).congruent = zeros(1, 288);

        for trial = 1:288
            if sum(congruentCNs == metrics.(groupname)(subjnum).(sessionnum).CN(1,trial)) == 1
                metrics.(groupname)(subjnum).(sessionnum).congruent(1,trial) = 1;
            end

        end

        %find lines containing "SessionDate:" and extract the date string
        index=~cellfun(@isempty,regexp(content,'^\s*SessionDate:'));
        sessiondate=regexprep(content(index),'^\s*SessionDate:\s*','');
        metrics.(groupname)(subjnum).(sessionnum).sessiondate=sessiondate{1};

        % assemble a trialstart vector from "SlideFixationStart.OnsetTime"
        % timestamps
        index=~cellfun(@isempty,regexp(content,'^\s*SlideFixationStart.OnsetTime:'));
        timestamps = str2double(regexprep(content(index),'^\s*SlideFixationStart.OnsetTime:',''));
        metrics.(groupname)(subjnum).(sessionnum).trialstart = timestamps - timestamps(1,1);

    end
    
    line1 = fgetl(fid);
end
fclose(fid);

save(strcat(behav_dir, 'master_data.mat'), 'metrics')
