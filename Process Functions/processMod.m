function [data] = processMod(data,params)
%Process Modulated Signals
%
%   data = processMod(data,params)
%
%   Description: This function is designed to process photometry signals
%   acquired using the modulation technique, which involves using a sine
%   wave at high frequency (prime number and not a harmonic of sources of
%   electrical interference -- 60Hz). The bulk of this function handles
%   adjusting the signal and storing it into the appropriate data
%   structures
%
%   NOTE: This code will change to add a visualization component for
%   control signals. If red channel flucuates dramatically, then it will
%   allow you to correct for movement artifact
%
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
%

nAcq = length(data.acq);
lpCut = params.FP.lpCut; filtOrder = params.FP.filtOrder;

dsRate = params.dsRate;

interpType = params.FP.interpType;
fitType = params.FP.fitType; winSize = params.FP.winSize;
winOv = params.FP.winOv;
basePrc = params.FP.basePrc;
sigEdge = params.FP.sigEdge;

for n = 1:nAcq
    rawFs = data.acq(n).Fs;
    Fs = rawFs;
    nFP = data.acq(n).nFPchan;
    FPnames = data.acq(n).FPnames;
    refSig = data.acq(n).refSig;
    data.final(n).FP = cell(nFP,1);
    data.final(n).demod = cell(nFP,1);
    data.final(n).FPbaseline = cell(nFP,1);
    for x = 1:nFP
        rawFP = data.acq(n).FP{x};
        modFreq = inputdlg(['Enter Modulation Frequency for: ',FPnames{x}]);
        modFreq = str2double(modFreq);
        ref = findRef(modFreq,refSig,Fs);
        demod = digitalLIA(rawFP,ref,Fs,lpCut,filtOrder);
        if sigEdge ~= 0
            demod = demod((sigEdge*Fs)+1:end-(sigEdge*Fs));
        end
        [FP,baseline] = baselineFP(demod,interpType,fitType,basePrc,winSize,winOv,Fs);
        if dsRate ~= 0
            FP = downsample(FP,dsRate);
            demod = downsample(demod,dsRate);
            baseline = downsample(baseline,dsRate);
        end
        data.final(n).demod{x} = demod;
        data.final(n).FP{x} = FP;
        data.final(n).FPbaseline{x} = baseline;
        if ~isexist(data.final(n),'time')
            L = size(FP,1);
            if dsRate ~= 0
                L = L/dsRate;
                Fs = Fs/dsRate;
            end
            timeVec = [1:L]/Fs;
            data.final(n).time = timeVec';
        end
            
    end
    if isfield(data.acq(n),'control')
        nControl = length(data.acq(n).control);
        controlNames = data.acq(n).controlNames;
        data.final(n).control = cell(nControl,1);
        for x = 1:nControl
            rawCont = data.acq(n).control{x};
            modFreq = inputdlg(['Enter Modulation Frequency for: ',controlNames{x}]);
            modFreq = str2double(modFreq);
            ref = findRef(modFreq,refSig,Fs);
            demodCont = digitalLIA(rawCont,ref,Fs,lpCut,filtOrder);
            if sigEdge ~= 0
                demodCont = demodCont((sigEdge*Fs)+1:end-(sigEdge*Fs));
            end
            if dsRate ~= 0
                demodCont = downsample(demodCont,dsRate);
            end
            data.final(n).control{x} = demodCont;
        end
    end
    if (params.wheelStatus == 1) && (sigEdge ~= 0)
        wheel = data.acq(n).wheel;
        wheel = wheel((sigEdge*Fs)+1:end-(sigEdge*Fs));
        data.acq(n).wheel = wheel;
    end
    
end

end

function [ref] = findRef(modFreq,refSig,Fs)

for n = 1:length(refSig)
    tmpRef = refSig{n};
    [refMag,refFreq] = calcFFT(tmpRef-mean(tmpRef),Fs);
    maxRefFreq = refFreq(find(refMag == max(refMag)));
    if modFreq >= (maxRefFreq-5) && modFreq <= (maxRefFreq+5)
        ref = tmpRef;
    end
end

end