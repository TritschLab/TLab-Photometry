% function [trial_label, trial_type, idx] = HL_FP_GenerateTrialTypeIndex(n_trial, trial)
% generate the trail type numbers
% INPUT: 
%  n_trial: total trial number of this session;
%  trial: -struct, output from HL_WS_parseStiLib.m
%             trial.type: cell arrays of used stimulus map
%             tiral.label: idx number in .type of a full stimulus sequence
%
% Haixin Liu 2019-09

function [trial_label, trial_type, idx] = HL_FP_GenerateTrialTypeIndex(n_trial, trial)

% fix names to put into a structure 
for ii = 1:length(trial.type)
    if any(strfind(trial.type{ii}, '-'))
        trial.type{ii}(strfind(trial.type{ii}, '-')) = '_';
    end
end
%%%%%%%%%%%%%
trail_label = trial.label;
trial_type = trial.type;
n_block = ceil(n_trial/length(trail_label));
trial_label = repmat(trail_label,1,n_block);
trial_label = trial_label(1:n_trial);

% clean trial types, as some cannot be structure name
for ii = 1:length(trial_type)
    if any(strfind(trial_type{ii}, '.'))
        trial_type{ii}(strfind(trial_type{ii}, '.')) = '_';
    end
    idx.(trial_type{ii}) = find(trial_label==ii);
end
    