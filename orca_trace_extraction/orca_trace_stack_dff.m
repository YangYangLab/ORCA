function dffvideo = orca_trace_stack_dff(v, baseline_frm)
% v video

v = double(v);
baseline = mean(v(:,:,baseline_frm),3);
baseline2 = imgaussfilt(baseline, 1);
dffvideo = (v - baseline2) ./ baseline2;
