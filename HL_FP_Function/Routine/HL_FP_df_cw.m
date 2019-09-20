% function  [df_F_ds, ts_ds, df_F, F_baseline, FP_filter] = HL_FP_df_cw (rawFP, ts, rawFs, system_baseline, ...
%                                                                         lpCut, filtOrder, interpType, fitType, winSize, winOv, basePrc)
% function to process photometry data using constant excitation imaging
% method, using Pratik's functions 
%
%   INPUT:
%
%   
%   OUTPUT:
%       df_F_ds: processed dF/F data, downsampled using the low-pass filter
%                value (raw sample freq/filtered freq)
%       ts_ds: downsampled time stamp for each data point in df_F_ds
%       df_F: dF/F not downsampled
%       F_baseline: estimated baseline, not downsampled
%       FP_filter: low-pass filtered data, not down sampled


%%
function  [df_F_ds, ts_ds, df_F, F_baseline, FP_filter] = HL_FP_df_cw (rawFP, ts, rawFs, system_baseline, ...
                                                                        lpCut, filtOrder, interpType, fitType, winSize, winOv, basePrc)
%% default params
params.FP.lpCut = 10; % Cut-off frequency for filter
params.FP.filtOrder = 10; % Order of the filter
params.FP.interpType = 'linear'; % 'linear' 'spline' 
params.FP.fitType = 'interp'; % Fit method 'interp' , 'exp' , 'line'
params.FP.winSize = 20; % Window size for baselining in seconds
params.FP.winOv = 1; %Window overlap size in seconds
params.FP.basePrc = 10; % Percentile value from 1 - 100 to use when finding baseline points

%%
if nargin < 4
    system_baseline = 0;
    lpCut = params.FP.lpCut; % Cut-off frequency for filter
    filtOrder = params.FP.filtOrder; % Order of the filter
    interpType = params.FP.interpType;
    fitType = params.FP.fitType;
    winSize = params.FP.winSize;
    winOv = params.FP.winOv;
    basePrc = params.FP.basePrc;
elseif nargin < 5
    lpCut = params.FP.lpCut; % Cut-off frequency for filter
    filtOrder = params.FP.filtOrder; % Order of the filter
    interpType = params.FP.interpType;
    fitType = params.FP.fitType;
    winSize = params.FP.winSize;
    winOv = params.FP.winOv;
    basePrc = params.FP.basePrc;    
elseif nargin >=5 && nargin < 11
    help HL_FP_df_cw
    error('Not enought input paramters')
elseif nargin > 11
    help HL_FP_df_cw
    error('too many input paramters')    
end

%  filter and calcuate dF/F using method: 
FP_filter = filterFP(rawFP - system_baseline,rawFs,lpCut,filtOrder,'lowpass');
[df_F,F_baseline] = baselineFP(FP_filter,interpType,fitType,basePrc,winSize,winOv,rawFs);

% downsample to reduce data size, but not lose temporal info. 
dsRate = rawFs/lpCut; % raw sample freq/filtered freq
df_F_ds = downsample(df_F,dsRate);
% baseline = downsample(baseline,dsRate);

%also return down sampled time stamps to match processed data
ts_ds = downsample(ts,dsRate);

