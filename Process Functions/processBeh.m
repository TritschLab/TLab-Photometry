function data = processBeh(data,params)
%Process Behavior
%
%   [data] = processBeh(data,params)
%
%   Description: This function is designed to convert rotary encoder information into velocity
%   traces and quickly find onsets. The parameters for the analysis are found in the params
%   structure, which is created from a user-created scripted based on the
%   processParam.m file.
%
%   Input:
%   - data - A data structure specific to the Tritsch Lab. Created using
%   the convertH5_FP script
%   - params - A structure created from a variant of the processParams
%   script
%
%   Output:
%   - data - Updated data structure containing processed data
%
%   Author: Pratik Mistry 2019
radius = params.beh.radius; velThres = params.beh.velThres;
winSize = params.beh.winSize;
finalOnset = params.beh.finalOnset;
nAcq = length(data.acq);
dsRate = params.dsRate;
for n = 1:nAcq
    wheel = data.acq(n).wheel;
    rawFs = data.acq(n).Fs;
    Fs = rawFs/dsRate;
    wheel = downsample(wheel,params.dsRate);
    data.final(n).wheel = wheel;
    data.final(n).Fs = Fs;
    vel = getVel(wheel,radius,Fs,winSize);
    minRest = params.beh.minRestTime * Fs; minRun = params.beh.minRunTime * Fs;
    [onsets,offsets] = getOnsetOffset(abs(vel),velThres,minRest,minRun,finalOnset);
    data.final(n).vel = vel';
    data.final(n).beh.onsets = onsets;
    data.final(n).beh.offsets = offsets;
end
