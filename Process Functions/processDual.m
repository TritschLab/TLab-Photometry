function [data] = processDual(data,params)
nAcq = length(data.acq);
lpCut = params.FP.lpCut; filtOrder = params.FP.filtOrder;

dsRate = params.dsRate;

interpType = params.FP.interpType;
fitType = params.FP.fitType; winSize = params.FP.winSize;
winOv = params.FP.winOv;
basePrc = params.FP.basePrc;
sigEdge = params.FP.sigEdge;

for x = 1:nAcq
    L = length(data.acq(x).time);
    nFP = length(data.acq(x).FP);
    FPnames = data.acq(x).FPnames;
    rawFs = data.acq(x).Fs;
    Fs = rawFs/dsRate;
    refSig = data.acq(x).refSig;
    data.final(x).FP = cell(nFP,1); data.final(x).nbFP = cell(nFP,1); data.final(x).FPbaseline = cell(nFP,1);
    for y = 1:nFP
        rawFP = data.acq(x).FP{y,1};
        modFreq = inputdlg(['Enter Modulation Frequency for: ',FPnames{y}]);
        modFreq = str2double(modFreq{1});
        ref = findRef(modFreq,refSig,rawFs);
        demod = digitalLIA(rawFP,ref,rawFs,lpCut,filtOrder);
        if sigEdge ~= 0
            demod = demod((sigEdge*rawFs)+1:end-(sigEdge*rawFs));
        end
        demod = downsample(demod,dsRate);
        data.final(x).nbFP{y} = demod;
        [FP,baseline] = baselineFP(demod,interpType,fitType,basePrc,winSize,winOv,Fs);
        data.final(x).FP{y} = FP;
        data.final(x).FPbaseline{y} = baseline;
    end
    L = L/dsRate; timeVec = [1:L]/Fs;
    data.final(x).time = timeVec';
    data.final(x).Fs = Fs;
    if sigEdge ~= 0
        wheel = data.acq(x).wheel;
        wheel = wheel((sigEdge*rawFs)+1:end-(sigEdge*rawFs));
        data.acq(x).wheel = wheel;
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