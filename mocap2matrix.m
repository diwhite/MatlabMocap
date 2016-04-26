function M = mocap2matrix(filename)
%
% M = mocap2matrix(filename)
%
% This function reads in a motion capture file 
% (either as a bvh file or an amc file).
%    
%   filename = the name of the file to open (as a string)
%
% David White
% diwhite@cs.ubc.ca
% December, 2004

% check that filename is a string
if isstr(filename) ~= 1
    error('invalid filename');
end

% open filename
fp = fopen(filename, 'rt');

% find the filetype
[type, rem] = strtok(filename, '.');
type = strtok(rem);

% if we have a .bvh file
if strcmp(type, '.bvh') == 1
    
    % find the line "MOTION"
    line = fgets(fp);
    while (strcmp(strtok(line), 'MOTION') ~= 1)
        line = fgets(fp);
    end
    
    % get the number of frames
    line = fgets(fp);
    [fnum, frem] = strtok(line, ':');
    [fnum, frem] = str2num(strtok(frem, ':'));
    
    % get rid of the frame rate line
    line = fgets(fp);
    
    % read the first data line to get the size of the matrix
    line = fgets(fp);
    
    temp = line;
    
    num_num = 0;
    
    [data_temp, data_rem] = strtok(temp);
    while isempty(data_rem) ~= 1
        num_num = num_num + 1;
        [data_temp, data_rem] = strtok(data_rem);
    end
    
    % initiate the matrix
    M = zeros(fnum, num_num);
    
    % for each frame
    for i=1:fnum

        % for each piece of data
        [data, data_rem] = strtok(line);
        M(i,1) = str2num(data);    
        for j=2:num_num
            [data, data_rem] = strtok(data_rem);
            % store the data in the matrix
            M(i,j) = str2num(data);
        end
        line = fgets(fp);            
    end

else if strcmp(type, '.asf') == 1 | strcmp(type, '.amc') == 1

    error('Not yet implemented, please check http://www.cs.ubc.ca/~diwhite for updates');   
            
        

else
    error('invalid file type');
    
end

fclose(fp);

end