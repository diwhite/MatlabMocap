function matrix2mocap(M, newfilename, oldfilename)
%
% matrix2mocap(M, newfilename, oldfilename)
%
% This function reads in a motion capture file 
% (either as a bvh file or an amc file).
%
%   M = matrix of mocap data
%   newfilename = the name of the file to write to
%   oldfilename = the file the matrix came from, with the right header
% 
%
% David White
% diwhite@cs.ubc.ca
% December, 2004

% check that M is a matrix
if isa(M,'double') ~= 1
    error('invalid matrix');
end

% check that the filenames are strings
if isstr(newfilename) ~= 1 | isstr(oldfilename) ~= 1
    error('invalid filename');
end

% open filename
fp1 = fopen(oldfilename, 'r');
fp2 = fopen(newfilename, 'w');

% find the filetypes
[type1, rem1] = strtok(oldfilename, '.');
type1 = strtok(rem1);
[type2, rem2] = strtok(newfilename, '.');
type2 = strtok(rem2);

% check that the filetypes are the same
if strcmp(type1, type2) ~= 1
    error('incompatible file types');
end

% if we have a .bvh file
if strcmp(type1, '.bvh') == 1
    
    % write the header
    line = fgets(fp1);
    while (strcmp(strtok(line), 'MOTION') ~= 1)
        fprintf(fp2, line);
        line = fgets(fp1);
    end
    fprintf(fp2, line);
    
    % get rid of the number of frames
    line = fgets(fp1);
    
    % get the frame rate
    line = fgets(fp1);
    [frate, frem] = strtok(line, ':');
    [frate, frem] = str2num(strtok(frem, ':'));
    
    % print the rest of the header
    fprintf(fp2, 'Frames: %d\n', size(M,1));
    fprintf(fp2, 'Frame Time: %2.6f\n', frate); 
    
    
    % count the number of data points on each line in the old file
    line = fgets(fp1);
    num_num = 0;
    [data_temp, data_rem] = strtok(line);
    while isempty(data_rem) ~= 1
        num_num = num_num + 1;
        [data_temp, data_rem] = strtok(data_rem);
    end
    
    % compare with the matrix
    if num_num ~= size(M,2)
        error('matrix does not match the header in %s\n', oldfilename);
    end
    
    % write the matrix to the new file
    
    for i=1:size(M,1)
        new_out_line = sprintf('%2.6f     ',M(i,1));
        for j=2:size(M,2)
            new_out_line = sprintf('%s\t%2.6f', new_out_line,M(i,j));
        end
        fprintf(fp2,'%s\n',new_out_line);
    end
fclose(fp1);
fclose(fp2);


else if strcmp(type1, '.asf') == 1 | strcmp(type1, '.amc') == 1

        
    error('Not yet implemented, please check http://www.cs.ubc.ca/~diwhite for updates');   
        

else
    error('invalid file type');
    
end







end