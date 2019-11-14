function vel = getVel(distTravel,Fs,winSize)
% Get Velocity
%
%   vel = getVel(rawData,radius,Fs,winSize);
%
%   Description: This function performs the simple manipulations to obtain
%   velocity information from raw rotary encoder data.
%
%   Input:
%   - disTravel - Vector of distance traveled over time
%   - Fs - Sample Rate of Acquisition
%   - winSize - Window size in seconds for smoothing the unwrapped encoder
%   data to remove in the trace that prevent us from obtaining an
%   appropriate velocity trace
%
%   Output:
%   - vel - Velocity trace
%

if size(distTravel,1) == 1
    distTravel = distTravel';
end

if winSize ~= 0
    distTravel = movmean(distTravel,ceil(Fs*winSize*0.5));
end
vel = [diff(distTravel);(distTravel(end)-distTravel(end-1))] * Fs;
vel = medfilt1(vel,ceil(Fs*winSize));
end