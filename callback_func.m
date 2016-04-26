function callback_func
% This is a subfunction only for use within the display_mocap function.
%
%
% David White
% diwhite@cs.ubc.ca
% December, 2004

global mocap_toolbox_global_N mocap_toolbox_global_ui mocap_toolbox_global_ui2 mocap_toolbox_global_offset mocap_toolbox_global_endsite mocap_toolbox_global_ui_line mocap_toolbox_global_ui_point mocap_toolbox_global_skel
% I hate using global variables, but they are the only way to pass
% variables to the callback function (I think)

% get the frame slider value
t=round(get(mocap_toolbox_global_ui,'value'));  

% are we plotting lines?
line = get(mocap_toolbox_global_ui_line,'value');

% are we plotting points?
point = get(mocap_toolbox_global_ui_point,'value');

% set the frame value for display
set(mocap_toolbox_global_ui2, 'String', strcat('Frame:',num2str(t)));

% update the figure
showmocap(mocap_toolbox_global_N, mocap_toolbox_global_offset, mocap_toolbox_global_endsite, t, line, point, mocap_toolbox_global_skel);
