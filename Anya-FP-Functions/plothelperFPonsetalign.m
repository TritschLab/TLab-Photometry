function [fig] = plothelperFPonsetalign (plotName, time, dfOnAll, plot_dfOn, plot_behOn, varargin)

% Created by: Anya Krok
% Created on: 18 June 2019
% Description: plot photometry and behavior signal aligned to onset of
% event, after acquiring variables using getAKFPonsetavg function
%
% [fig] = plothelperFPonsetalign (plotName, time, dfOnAll, plot_dfOn, plot_behOn, Fs, varargin)
%
% INPUT
%   'time': (*sec*), vector with time values
%   'plotName': data identifier for plot title
%   'dfOnAll': extracted FP traces aligned to movement onset for all bouts
%   'plot_dfOn'
%   'plot_behOn'
%       matrix where rows correspond to onset-aligned FP and behavior, 
%       averaging across rows for multiple acquisitions and/or rec days
%   varargin: 
%       {1, vector}: 'right_color' - for plotting averaged photometry trace
%       {1, scalar}: Fs - sampling frequency 
%
% OUTPUT
%   'fig': figure, plot of photometry and behavior aligned to onset

%% 
%aligning traces in Y-axis such that minimum value betweel -4 and -3 sec
%preceding onset is at zero, for visualization in figure subplot
if nargin == 6 && isscalar(varargin{1})
    Fs = varargin{1};
else 
    Fs = 50;
end

sec = [-4 -3 3 4]; 
sec2 = ((sec+4)*Fs)+1;
    minmatrix = dfOnAll(:,sec2(1):sec2(2)); 
        mins = min(minmatrix,[],2);
for i = 1:size(dfOnAll,1)
    dfOnMin(i,:) = dfOnAll(i,:) + (-1*mins(i));
end 

%%
fig = figure;
%BOTTOM subplot: individual photometry traces aligned to onset in X-axis,
%   traces are aligned in Y-axis for visualization such that 
%   minimum value between -4 and -3 seconds preceding onset is zero
sp(2) = subplot(2,1,2);
    title('dF/F Traces at ONSET')
    ylabel('Fluorescence (dF/F)')
    xlabel('Time (s)')
    hold on
    for trace = 1:size(dfOnMin,1)
        plot(time, dfOnMin(trace,:));   %plotting all normalized traces
    end
    hold off

%Assigning colors to axes of top subplot of figure
left_color = [0 0 0];
if nargin == 6 && ~isscalar(varargin{1}) 
    right_color = varargin{1};      %variable input of color
else
    right_color = [0 0.75 0];
end
set(fig,'defaultAxesColorOrder',[left_color; right_color]);

%TOP subplot: averaged photometry and behavior traces aligned to onset,
%   where averaging depends on plot_dfOn and plot_behOn inputs
sp(1) = subplot(2,1,1); hold on
    title ([plotName,' - avg dF/F at ONSET'],'Interpreter', 'none');   
    yyaxis left
        shadederrbar(time, mean(plot_behOn,1), SEM(plot_behOn,1),'k'); 
        ylabel('Velocity (m/s)')

    yyaxis right
        shadederrbar(time, mean(plot_dfOn,1), SEM(plot_dfOn,1), right_color);
        ylabel('Fluorescence (dF/F)')
    hold off; 

linkaxes(sp,'x') %link x-axes of top and bottom subplots

end
