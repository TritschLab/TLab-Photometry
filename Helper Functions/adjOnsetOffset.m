function [onSets,offSets] = adjOnsetOffset(onSetsInd,offSetsInd,timeThres,vel)
%Adjust Onset and Offset vectors to adhere to time and length constraints
%
%   [onSets,offSets] = adjOnsetOffset(onSetsInd,offSetsInd,timeThres,vel)
%
%   Description: This function was created by Jeffrey March, so the onset
%   and offset vectors adhere to time and length contraints as specified by
%   the user
%
%   Input:
%   - onSetsInd - Onset values in samples
%   - offSetsInd - Offset values in samples
%   - timeThres - Time threshold for bouts to adhere to
%   - vel - Velocity trace, but absolute value
%
%   Output:
%   - onSets - Adjusted onset indices
%   - offSets - Adjusted offset indices
%
%

    offSetsInd = offSetsInd(offSetsInd < length(vel) - timeThres); % Making sure last offSetsInd is at least timeThres from the end
    onSetsInd = onSetsInd(1:length(offSetsInd)); % Removing onSetsInd that correspond to removed offSetsInd
    offSets = offSetsInd((offSetsInd - onSetsInd) > timeThres); % Making sure onset to offset is at least timeThres in length
    onSets = onSetsInd((offSetsInd - onSetsInd) > timeThres); % Making sure onset to offset is at least timeThres in length
    offSets = offSets(onSets > timeThres); % Making sure first onset is at least timeThres from the beginning (corresponding offset)
    onSets = onSets(onSets > timeThres); % Making sure first onset is at least timeThres from the beginning
end
