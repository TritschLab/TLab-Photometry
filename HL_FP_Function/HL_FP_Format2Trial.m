% [Trial_FP, FP_x_plot] = HL_FP_Format2Trial(df_F_ds, ts_ds, Stim_ts, FP_trial_window_length, FP_trial_window_start) 
% to format session FP data into trial structure according to Stimulus time
%   INPUT:
%       df_F_ds, ts_ds, Stim_ts: data and data structure from  
%       FP_trial_window_length, FP_trial_window_start: in sec, optional
%           default are: 
%                 FP_trial_window_length = 6;
%                 FP_trial_window_start = -4;
%
%
% Haixin Liu 2019-9
%%
function [Trial_FP, FP_x_plot] = HL_FP_Format2Trial(df_F_ds, ts_ds, Stim_ts, FP_trial_window_length, FP_trial_window_start) 

if nargin < 4
FP_trial_window_length = 6;
FP_trial_window_start = -4;
elseif nargin >=4 && nargin < 6
    help HL_FP_Format2Trial
    error('Input number not match criteria')
end

% get data selection window
df_sr = median(diff(ts_ds));% sampling rate in processed df
trial_window =[1:round(FP_trial_window_length/df_sr)] + round(FP_trial_window_start/df_sr);  %50Hz 2s => 100 data points

FP_x_plot = [0:1:(length(trial_window)-1)]*df_sr+FP_trial_window_start;

Trial_FP = nan(size(Stim_ts,1), length(trial_window));
for ii = 1:size(Stim_ts,1)
     [frame_idx] = HL_getFrameIdx(ts_ds, Stim_ts(ii,1));
     if frame_idx+trial_window(end) > length(df_F_ds)
         fprintf('Window end exceeds the data range, skip trial # %d, put in NaNs\n', ii);
         continue;
     elseif  frame_idx+trial_window(1) < 1
         fprintf('Window begining exceeds the data range, skip trial # %d, put in NaNs\n', ii);
         continue;
     else
         Trial_FP(ii,:) = df_F_ds(frame_idx+trial_window);
     end
end
