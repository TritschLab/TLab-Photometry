% function [FP_clean, Thred, n_trial] = HL_FP_CleanStiArtiFact(FP,Sti,sr, Thred)
% use Sti recorded channel to NaN the portion in FP data,
% INPUT:
%       FP: nx1 vector of photometry data
%       Sti: nx1 vector of stimulation data
% FP and Sti should be equal in length
% OUTPUT:
%       FP_clean: nx1 vector of data with stimulation portion replaced with NaNs
%       Thred: return selected threshld 
%       n_trial: use stim. data to estimate trial number, not great but work,
%       temporally use for no Bpod DI data
%
% Haixin Liu 2019-9

%%
function [FP_clean, Thred, n_trial] = HL_FP_CleanStiArtiFact(FP,Sti,sr, Thred)

% stimulus can be TTL trigger or MOD analog signal
% make the threshold ? 
% now use a response of GUI
% if not provided
if nargin < 4
   figure;
   plot(unique(Sti));
   title('Click Threshold for detecting artifact, then PRESS ENTER')
   disp('Click Threshold for detecting artifact, then PRESS ENTER');
   [xi,yi]=getpts;
   Thred = yi;
   close
end
% some parameters used 
exclude_leeway = 0.006; % s
disp(['exclude s around stimulation (half on each end) ',num2str(exclude_leeway)]);
% there is a responding time for LED (laser probably the same or worse)=>
% extend the excluding window
to_exclude = Sti>Thred;
% for sf 2k there are at least 4 data points need to be removed 2 ms =>
% extend 3 ms before and after 
leeway = ceil(exclude_leeway/(1/sr));
leeway_filt = ones(leeway,1);

to_exclude = logical(conv2(+to_exclude,leeway_filt,'same'));

FP_clean = FP;
FP_clean(to_exclude) = NaN;

% also estimate the number of stim. train from the sti. rec
% assume train stim > 1Hz and ITI > 1s
train_check = logical(conv2(+to_exclude,ones(ceil(1/(1/sr)),1),'same'));
train_check_shift = [0; train_check(1:end-1) ];
% train_check_2 =
% logical(conv2(+train_check,-ones(ceil(1/(1/sr)),1),'same'));  % not
% working ....
n_trial = length(find(train_check == 1 &  train_check_shift == 0));

