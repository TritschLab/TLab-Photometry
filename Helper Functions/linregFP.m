%% Finding df/f using linear regression - least square fitting model
function [dF, baseline] = linregFP(iso,sig,prc)
% Description: This function will find the baseline of a signal by applying
% a linear least-squares fit between the two timeseries (that is, the
% isosbestic control signal values were the independent variable and the 
% excitation signal was the dependent variable). Change in fluorescence 
% (dF) was calculated as (sig-nm signal–fitted iso-nm signal). dF/F was 
% calculated by dividing each point in dF by the iso-nm fit. 

% INPUT:
% - iso - demodulated isosbestic signal
% - sig - demodulated excitation signal
% - prc - percentile value
% OUTPUT:
% - Scatter plot with line of best fit of iso vs sig
% - Baseline values of the signal

% Author: Akhila Sankaramanchi, 2019

scatter(iso,sig);
% Scatter plot of iso vs sig
hl = lsline;
% Best fit line of scatter plot using the least squares method
p2 = polyfit(get(hl,'xdata'),get(hl,'ydata'),1);
% Finds the slope and y-intercept of the best-fit line
baseline = (p2(1).*iso)+p2(2);
dF1 = sig - baseline;
x = prctile(dF1,prc); 
dF2 = dF1 + abs(x);
% Adjusted so that a dF of 0 corresponded to a specified percentile value 
% of the signal. This is done to achieve a true baseline value which is
% below the mean of the signal. Typically, 10th percentile is used.
dF3 = dF2./(baseline);
dF = dF3*100;
end

