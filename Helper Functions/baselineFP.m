function [dF,baseline] = baselineFP(FP,interpType,fitType,basePrc,winSize,winOv,Fs)
%baselinePhotometry - Baseline adjust photometry signal to get dF/F
%
%   [dF_F,varargout] = baselineFP(FP,interpType,fitType,basePrc,winSize,winOv,Fs)
%
%   Description: This code will baseline adjust the photometry signal using
%   a moving window and finding values within a specified percentile
%
%   Input:
%   - FP - Photometry signal to baseline
%   - interType - Interpolation method to use: 'linear' 'spline' etc
%   - fitType - Options: 'interp' --> interpolated line
%       - 'exp' --> Models interpolated line as exponentials
%       - 'line' --> models interpolated line as first degree polynomial
%   - basePrc - Percentile value to use when finding baseline points for
%   interpolation
%   - winSize - Window size in seconds for finding baseline
%   - winOv - Overlap size in seconds for finding baseline
%   - Fs - Sampling Rate
%
%   Output:
%   - dF_F - Baseline adjusted trace (%dF_F)
%   - varargout - Optional fitline output
%
%
    if size(FP,1) == 1
        FP = FP';
    end
    
    winSize = winSize * Fs;
    winOv = winOv * Fs;
    Ls = length(FP);
    L = 1:Ls; L = L';
    nPts = floor(Ls/(winSize-winOv));
    
    X = L(1:ceil(Ls/nPts):end); Y = zeros(nPts,1);
    
    if winOv == 0 || isempty(winOv)
        winStep = winSize;
    else
        winStep = winSize - winOv;
    end
    
    for n = 0:nPts-1
        I1 = (n*winStep)+1;
        I2 = I1 + winSize;
        if I2>Ls
            I2 = Ls;
        end
        Y(n+1) = prctile(FP(I1:I2),basePrc);
    end
    
    interpFit = interp1(X,Y,L,interpType,'extrap');
    
    switch fitType
        case 'interp'
            baseline = interpFit;
        case 'exp'
            expFit = fit(L,interpFit,'exp2');
            baseline = double(expFit(L));
        case 'line'
            lineFit = fit(L,interpFit,'poly1');
            baseline = double(lineFit(L));
        otherwise
            
    end
            
    dF = (FP-baseline)./baseline;
    dF = dF*100;
    
end