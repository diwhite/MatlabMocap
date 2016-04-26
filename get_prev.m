function prev = get_prev(skel, current, endsite)
%
% prev = get_prev(skel, current, endsite)
%
% This function finds the parent of the current point.
%
% prev = the number of parent joint
% skel = the skeleton matrix
% current = the number of the current joint
% endsite = array of endsite points
%
%
% David White
% diwhite@cs.ubc.ca
% December, 2004

% intial value
found = 0;

% check if we have an endsite
for i=1:size(endsite,2)
    if endsite(i) == (current)*3-2
        found = 1;
    end
end

% if we don't, just return current - 1
if found == 0%if current is not an endsite
    
    prev = current - 1;
 
% if we do have an endsite
else

        % some arbitrary initial values
        k = 0;
        prev = 1;
        
        % find the previous point to attach to
        [dummy, k] = max(skel(current,:));
        
        % find the joint to attach to
        for j = current-1:-1:1
            if skel(j,k-1) == 1;
                prev = j;
            end
        end
        
    end
