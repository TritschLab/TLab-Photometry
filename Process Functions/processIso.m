function [data] = processIso(data,params)
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
        modFreq = inputdlg({['Enter Isosbestic Mod Freq for: ',FPnames{y}],['Enter Excitation Mod Freq for: ',FPnames{y}]});
        isoFreq = str2double(modFreq{1}); excFreq = str2double(modFreq{2});
        isoRef = findRef(isoFreq,refSig,rawFs); excRef = findRef(excFreq,refSig,rawFs);
        isoDemod = digitalLIA(rawFP,isoRef,rawFs,lpCut,filtOrder);
        excDemod = digitalLIA(rawFP,excRef,rawFs,lpCut,filtOrder);
        if sigEdge ~= 0
            isoDemod = isoDemod((sigEdge*rawFs)+1:end-(sigEdge*rawFs));
            excDemod = excDemod((sigEdge*rawFs)+1:end-(sigEdge*rawFs));
        end
        excDemod = downsample(excDemod,dsRate); isoDemod = downsample(isoDemod,dsRate);
        data.final(x).nbFP{y} = excDemod;
        data.final(x).iso{y} = isoDemod;
        baseOption = menu('Do you want to use the Isosbestic for Baselining?','Yes','No');
        if baseOption == 1 || baseOption == 0
            [FP,baseline] = linregFP(isoDemod,excDemod,basePrc);
        elseif baseOption == 2
            [FP,baseline] = baselineFP(excDemod,interpType,fitType,basePrc,winSize,winOv,Fs);
        end
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