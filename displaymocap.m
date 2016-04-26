function display_mocap(M, filename)
%
% display_mocap(M, filename)
%
% This function reads in a motion capture data and displays it 
% 
%
%   M = matrix of mocap data
%   filename = the name of the file with the proper header
% 
%
% David White
% diwhite@cs.ubc.ca
% December, 2004


global mocap_toolbox_global_N mocap_toolbox_global_ui mocap_toolbox_global_ui2 mocap_toolbox_global_offset mocap_toolbox_global_endsite mocap_toolbox_global_ui_line mocap_toolbox_global_ui_point mocap_toolbox_global_skel
% I hate using global variables, but they are the only way to pass
% variables to the callback function (I think)



% check that M is a matrix
if isa(M,'double') ~= 1
    error('invalid matrix');
end

% do not allow 'M' to be named 'N'



% check that filename is a string
if isstr(filename) ~= 1
    error('invalid filename');
end

% open filename
fp = fopen(filename, 'rt');

% find the filetype
[type, rem] = strtok(filename, '.');
type = strtok(rem);

% open the figure
f = figure;

% initialize some variables
mocap_toolbox_global_N = M;
mocap_toolbox_global_offset = zeros(1,size(M,2)-3);
mocap_toolbox_global_skel = zeros(floor(size(M,2)/3),size(M,2)-3);
mocap_toolbox_global_skel(1,1) = 1;
mocap_toolbox_global_endsite(1) = 1;
numback(1) = 0;
joints_pointer = zeros(size(M,2),3);
i=1;
j=2;
sc1 = 1;
sc2 = 1;


% avoid flickering when slider is used
set(gcf,'doublebuffer','on');

% if we have a .bvh file
if strcmp(type, '.bvh') == 1
    
    line = fgets(fp);
    while (strcmp(strtok(line),'MOTION') ~= 1) & strcmp(strtok(line),'Frames:') ~= 1 
        
        % store the offset values and write the skeleton matrix
        if (strcmp(strtok(line), 'OFFSET') == 1)
            mocap_toolbox_global_skel(sc2,sc1) = 1;
            sc1 = sc1 + 1;
            sc2 = sc2 + 1;
            [off, rem] = strtok(line);
            [off, rem] = strtok(rem);
            mocap_toolbox_global_offset(i) = str2num(off);
            [off, rem] = strtok(rem);
            mocap_toolbox_global_offset(i+1) = str2num(off);
            [off, rem] = strtok(rem);
            mocap_toolbox_global_offset(i+2) = str2num(off);
            i = i + 3;
            line = fgets(fp);    
        end
        
        % if we have reached an End Site, store the endsite
        if strcmp(strtok(line), 'End') == 1
            while strcmp(strtok(line), '}') ~= 1
                line = fgets(fp);
            end
            k = -1;
            while strcmp(strtok(line), '}') == 1
                k = k + 1;
                line = fgetl(fp);
                while strcmp(line,'') == 1
                    line = fgetl(fp);
                end
            end
            sc1 = sc1 - k;
            mocap_toolbox_global_endsite(j) = i;
            j = j + 1;
        end
        line = fgets(fp); 
        
    end

    % display the first frame of data
    t = 1;
    showmocap(M, mocap_toolbox_global_offset, mocap_toolbox_global_endsite, t, 1, 1, mocap_toolbox_global_skel);
    
    % display the filename and frame #
    mocap_toolbox_global_ui1=uicontrol('style','text','String',strcat('File:',filename),'HorizontalAlignment','left','position',[20 60 200 15]);
    mocap_toolbox_global_ui2=uicontrol('style','text','String','Frame:1','HorizontalAlignment','left','position',[20 40 60 15]);
    
    
    % make a toggle switch for lines
    mocap_toolbox_global_ui_line = uicontrol('style','togglebutton','min',0,'max',1,'value',1,'callback','callback_func',...
        'position',[20 80 50 50], 'String','lines');
       
    % make a toggle switch for points
    mocap_toolbox_global_ui_point = uicontrol('style','togglebutton','min',0,'max',1,'value',1,'callback','callback_func',...
        'position',[75 80 50 50], 'String','points');
    
    % make the slider
    mocap_toolbox_global_ui = uicontrol('style','slider',... 
    'SliderStep',[1 10]/(size(mocap_toolbox_global_N,1)+1),'value',1,... 
    'min',1,'max',size(mocap_toolbox_global_N,1),...
    'callback','callback_func', 'position', [20 20 300 20]);  



else if strcmp(type, '.asf') == 1 | strcmp(type, '.amc') == 1

     error('Not yet implemented, please check http://www.cs.ubc.ca/~diwhite for updates');   
        

else
    error('invalid file type');
end



close(fp);

end

