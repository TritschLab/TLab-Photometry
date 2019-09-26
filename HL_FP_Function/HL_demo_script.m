%script demo: to analyze one recording session with multiple stimulus types

%{
 for this analysis you need several packags including Pratiks tool box
 the dependencies are:
 https://github.com/HaixinLiuNeuro/Wavesurfer
 https://github.com/HaixinLiuNeuro/Functions_fromMATLABcentral
 https://github.com/HaixinLiuNeuro/TLab-Photometry
 
%}

Data_root = 'R:\tritsn01lab\tritsn01labspace\Haixin\Data';

ii = 1;
WS_fn{ii} =          fullfile(Data_root, '190828\HL071\WS\HL071_190828_CSti_DLSfp_470LED_0001.h5');
WS_fn_baseline{ii} = fullfile(Data_root, '190828\HL071\WS\HL071_190828_CSti_DLSfp_470LED_baseline_0001.h5');

[Info, Result, WS_data] = HL_FP_Process_Stim_CW(WS_fn{ii}, WS_fn_baseline{ii});

[Trial_FP, FP_x_plot] = HL_FP_Format2Trial(Result.df_F_ds, Result.ts_ds, Result.Stim_ts);

% plot result
x_show = [-1 2];
n_type = length( Result.trial_type );
color_vec = varycolor(n_type);
figure; 
hold on;
for i_type = 1:n_type
    plot_jbfill_mean_se(Trial_FP( Result.idx_byTrialType.(Result.trial_type{i_type}), : ), ...
        FP_x_plot, color_vec(i_type,:));

end
xlim(x_show)
title('FP align to different Stim types')
xlabel('Time (s) Stim ON t=0')

