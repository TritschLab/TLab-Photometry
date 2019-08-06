function [data] = processFP(data,params)
%Process Fiber Photometry
%
%   [data] = processFP(data,params)
%
%   Description: This function is designed to process fiber photometry data
%   for the lab. The function performs demodulation (if selected),
%   filtering, baselining, and downsampling for all photometry traces in
%   the recording. The parameters for the analysis are found in the params
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

nAcq = length(data.acq);
lpCut = params.FP.lpCut; filtOrder = params.FP.filtOrder;

dsRate = params.dsRate;

interpType = params.FP.interpType;
fitType = params.FP.fitType; winSize = params.FP.winSize;
winOv = params.FP.winOv;
basePrc = params.FP.basePrc;

for n = 1:nAcq
    rawFs = data.acq(n).Fs;
    Fs = rawFs;
    nFP = data.acq(n).nFPchan;
    data.final(n).FP = cell(nFP,1);
    data.final(n).FPbaseline = cell(nFP,1);
    for x = 1:nFP
        rawFP = data.acq(n).FP{x};
        FP = filterFP(rawFP,rawFs,lpCut,filtOrder,'lowpass');
        [FP,baseline] = baselineFP(FP,interpType,fitType,basePrc,winSize,winOv,Fs);
        L = length(FP);
        data.final(n).FP{x} = FP;
        data.final(n).FPbaseline{x} = baseline;
    end
    if dsRate ~= 0
        FP = downsample(FP,dsRate);
        Fs = rawFs/dsRate;
    end
    data.final(n).Fs = Fs;
    timeVec = [1:L]/Fs;
    data.final(n).time = timeVec';
end