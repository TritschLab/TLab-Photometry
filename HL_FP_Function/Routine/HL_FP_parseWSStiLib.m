% function [trial, StimLib, map_num_used] = HL_FP_parseWSStiLib(tmpStimLib)
% parse the stimulus library in wavesurfer (WS)
% it uses Pratik's functions to get paramters: sub_orgStimLib.m
% return variables to construct session trial structure 
% 
%   INPUT:
%       tmpStimLib: data structure from wavesurfer: DATA.StiLib
%                   [DATA] = HL_FP_loadWS_parseData(fn)
%                    DATA.StiLib = s.header.StimulusLibrary;%
%   OUTPUT: organize the stimulus into
%       trial: struct-, 
%               .label: number label from 1 - n (stimuls types) 
%               .type: cell array recording the stimulus map name
%       StimLib: record the result from sub_orgStimLib
%       map_num_used: map number (label) used in the data session
%
%
% Haixin Liu 2019-09
%
%%
function [trial, StimLib, map_num_used] = HL_FP_parseWSStiLib(tmpStimLib)
% intialize variables to return
trial.label = [];
trial.type = {''};
map_num_used = [];
% tmpStimLib = crawl_h5_tree('/header/StimulusLibrary/',filename); %Use the innate wavesurfer function
StimLib = sub_orgStimLib(tmpStimLib);
% generate the trial type sequence
fprintf('Stim. used: %s\n',tmpStimLib.SelectedOutputableClassName);
% display and parse
switch tmpStimLib.SelectedOutputableClassName
    case 'ws.StimulusSequence' % display the chosen sequence
        disp(tmpStimLib.Sequences.(['element',num2str(tmpStimLib.SelectedOutputableIndex)]));
        %         tmpStimLib.Sequences.(['element',num2str(tmpStimLib.SelectedOutputableIndex)]).IndexOfEachMapInLibrary;
        map_field_names = fieldnames(tmpStimLib.Sequences.(['element',num2str(tmpStimLib.SelectedOutputableIndex)]).IndexOfEachMapInLibrary);
        seq_map_num = arrayfun(@(x) ...
            tmpStimLib.Sequences.(['element',num2str(tmpStimLib.SelectedOutputableIndex)]).IndexOfEachMapInLibrary.(map_field_names{x}), 1:length(map_field_names));
        % map field names is not sorted
        element_num = cellfun(@(x) str2double( x(8:end)), map_field_names); % element1
        [~,B]=sort(element_num);
        seq_map_num = seq_map_num(B);
        
        for ii = 1:length(seq_map_num)
            disp( tmpStimLib.Maps.(['element', num2str(seq_map_num(ii))]).Name)
        end
        % get block size (map #)
        % names, make trial type label etc
%         block_length = length(map_field_names);
        [map_num_used,~, trial.label] = unique(seq_map_num);
        for ii = 1:length(map_num_used)
            trial.type{ii} = tmpStimLib.Maps.(['element', num2str(map_num_used(ii))]).Name;
        end
    case 'ws.StimulusMap' %? need to check files
        fprintf('Stim. Map used: %s\n', tmpStimLib.Maps.(['element',num2str(tmpStimLib.SelectedOutputableIndex)]).Name);
        trial.type{1} = tmpStimLib.Maps.(['element',num2str(tmpStimLib.SelectedOutputableIndex)]).Name;
        trial.label = 1; % only one type of trials used 
        map_num_used = tmpStimLib.SelectedOutputableIndex;
        
        
%     case 'ws.StimulusStimulus' %? HL likely no use of single stimulus now
%     
        
    otherwise
        warning('NOT INCLUDED YET, return empty matrix');
end
