function data = processBeh(data,params)

radius = params.beh.radius; velThres = params.beh.velThres;
winSize = params.beh.winSize;
finalOnset = params.beh.finalOnset;
nAcq = length(data.acq);
for n = 1:nAcq
    if (isfield(data.final(n),'wheel'))
        if (~isempty(data.final(n).wheel))
            wheel = data.final(n).wheel;
        else
            wheel = data.acq(n).wheel;
        end
    else
        wheel = data.acq(n).wheel;
    end
    Fs = data.acq(n).Fs;
    if params.dsRate ~= 0
       wheel = downsample(wheel,params.dsRate);
       Fs = Fs/params.dsRate;
    end
    data.final(n).wheel = wheel;
    data.final(n).Fs = Fs;
    vel = getVel(wheel,radius,Fs,winSize);
    minRest = params.beh.minRestTime * Fs; minRun = params.beh.minRunTime * Fs;
    [onsets,offsets] = getOnsetOffset(vel,velThres,minRest,minRun,finalOnset);
    data.final(n).vel = vel;
    data.final(n).beh.onsets = onsets;
    data.final(n).beh.offsets = offsets;
end
