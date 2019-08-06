function data = processRestOnsetOffset(data,params)
%Process Rest Onset and Offset Data
%
%   data = processRestOnsetOffset(data,params)
%
%   Description: This function takes a data structure with velocity traces,
%   onset and offset indicies, and fiber photometry data and aligns
%   photometry to rest onset and offset. This code was organized using
%   functions and lines of code already created by Jeffrey March
%
%   Input:
%   - data - A data structure specific to the Tritsch Lab. Created using
%   the convertH5_FP script that is included in the analysis package
%   - params - A structure created from a variant of the processParams
%   script
%
%   Output:
%   - data - Updated data structure containing final data
%
%   Author: Pratik Mistry, 2019
%
    velThres = params.beh.velThres_rest; 
    minRunTime = params.beh.minRunTime_rest;
    timeShift = params.beh.timeShift_rest;
    
    nAcq = length(data.acq);
    
    for n = 1:nAcq
        vel = data.final(n).vel; vel = abs(vel);
        Fs = data.final(n).Fs;
        minRestTime = params.beh.minRestTime_rest*Fs;
        timeThres = params.beh.timeThres_rest *Fs; timeShift = timeShift*Fs;
        [onsetInd,offsetInd] = getOnsetOffset(-vel,-velThres,minRunTime,minRestTime,1);
        [onsetInd,offsetInd] = adjOnsetOffset(onsetInd,offsetInd,timeThres,vel);
        data.final(n).beh.onsetsRest = onsetInd;
        data.final(n).beh.offsetsRest = offsetInd;
    end
end

