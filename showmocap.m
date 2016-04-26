function showmocap(M, offset, endsite, t, lines, points, skel)
%
% showmocap(M, offset, endsite, t, lines, points, skel)
%
% This function displays the data at frame t from the matrix M.
%
% M = the matrix of mocap data
% offset = array of offsets
% endsite = array of endsites
% t = the current frame, or 0 to show the skeleton
% lines = 1 to show lines, 0 to not show lines
% points = 1 to show points, 0 to not show points
% skel = the skeleton matrix
%
%
% David White
% diwhite@cs.ubc.ca
% December, 2004

% clear previous plot, otherwise we see each previous frame as well
cla;


% initialize matricies
jnum = floor((size(M,2)-3)/3);
rz = zeros(4,4,jnum);
rx = zeros(4,4,jnum);
ry = zeros(4,4,jnum);
G = zeros(4,4,jnum);
D = zeros(4,1,jnum);
root = [0 0 0 1]';

% set up the arrays that will hold all the data
if t <= 0 | t > size(M,1) % show the skeleton
    

    
else % show the current frame
    
    trans = [1 0 0 M(t, 1) + offset(1); 0 1 0 M(t, 2) + offset(2); 0 0 1 M(t, 3) + offset(3); 0 0 0 1];
    rz(:,:,1) = [cos(M(t,4)*pi/180) -sin(M(t,4)*pi/180) 0 0; sin(M(t,4)*pi/180) cos(M(t,4)*pi/180) 0 0; 0 0 1 0; 0 0 0 1];    
    rx(:,:,1) = [1 0 0 0; 0 cos(M(t,5)*pi/180) -sin(M(t,5)*pi/180) 0; 0 sin(M(t,5)*pi/180) cos(M(t,5)*pi/180) 0; 0 0 0 1];    
    ry(:,:,1) = [cos(M(t,6)*pi/180) 0 sin(M(t,6)*pi/180) 0; 0 1 0 0; -sin(M(t,6)*pi/180) 0 cos(M(t,6)*pi/180) 0; 0 0 0 1];    
    G(:,:,1) = trans*rz(:,:,1)*rx(:,:,1)*ry(:,:,1);
    
    D(:,:,1) = G(:,:,1)*root;

end





% initialize the counters
r_count = 2; % used for the rotations
p_count = 1; % used for the line plot
e = 2; % used for the end points





% for each joint in the skeleton (except the first, which was done above)
for i=4:3:size(M,2)-3
         
    if i == endsite(e) % if the parent is not the previous point
        
        % plot the latest line, if requested
        if lines == 1
            plot3(P1, P3, P2); 
        end

        % clear the current line
        clear('P1');
        clear('P2');
        clear('P3');
        
        % some arbitrary initial values
        k = 0;
        prev = 1;
        
        % find the previous point to attach to
        [dummy, k] = max(skel(ceil(endsite(e)/3),:));

        % find the joint to attach to
        for j = ceil(endsite(e)/3)-1:-1:1
            if skel(j,k) == 1;
                prev = j;
            end
        end

        % set new initial point for the line
        P1(1) = D(1,1,prev);
        P2(1) = D(2,1,prev);
        P3(1) = D(3,1,prev);
        p_count = 2;
        
        % if we are making the skeleton, neglect rotations
        if t <= 0 | t > size(M,1)
            % add the second point to the line
            P1(2) = M1(3*(prev-1)+1) + offset(i);
            P2(2) = M1(3*(prev-1)+2) + offset(i+1);
            P3(2) = M1(3*(prev-1)+3) + offset(i+2);
            p_count = 3;
        
            % add the latest point
            M1(i) = M1(3*(prev-1)+1) + offset(i);
            M1(i+1) = M1(3*(prev-1)+2) + offset(i+1);
            M1(i+2) = M1(3*(prev-1)+3) + offset(i+2);
            e = e + 1;
   
        
        else % if we are not making the skeleton

            trans = [1 0 0 offset(i); 0 1 0 offset(i+1); 0 0 1 offset(i+2); 0 0 0 1];
            rz(:,:,r_count) = [cos(M(t,i+3)*pi/180) -sin(M(t,i+3)*pi/180) 0 0; sin(M(t,i+3)*pi/180) cos(M(t,i+3)*pi/180) 0 0; 0 0 1 0; 0 0 0 1];    
            rx(:,:,r_count) = [1 0 0 0; 0 cos(M(t,i+4)*pi/180) -sin(M(t,i+4)*pi/180) 0; 0 sin(M(t,i+4)*pi/180) cos(M(t,i+4)*pi/180) 0; 0 0 0 1];    
            ry(:,:,r_count) = [cos(M(t,i+5)*pi/180) 0 sin(M(t,i+5)*pi/180) 0; 0 1 0 0; -sin(M(t,i+5)*pi/180) 0 cos(M(t,i+5)*pi/180) 0; 0 0 0 1];  
            G(:,:,r_count) = trans*rz(:,:,r_count)*rx(:,:,r_count)*ry(:,:,r_count);            
 
            temp = G(:,:,r_count);
            
        
            prev = get_prev(skel, r_count, endsite);
        
        
            
            
            while(prev ~= 1) % while we are not at the root, multiply the current joint's rotations on
        
                % use the rotation from the previous joint
                temp = G(:,:,prev)*temp;
        
                prev = get_prev(skel, prev, endsite);
            end
        
            D(:,:,r_count) = G(:,:,prev)*temp*root;
        
        
            P1(p_count) = D(1,1,r_count);
            P2(p_count) = D(2,1,r_count);
            P3(p_count) = D(3,1,r_count);


           % plot the points, if requested
            if points == 1
                plot3(D(1,1,r_count),D(3,1,r_count),D(2,1,r_count),'o');
            end
        
            r_count = r_count + 1;
            p_count = p_count + 1;
            e = e + 1;
        end
              
     else % if its parent is the previous joint (not an endsite)

        if t <= 0 | t > size(M,1) % if we are making the skeleton
                
            M1(i) = M1(i-3) + offset(i);
            M1(i+1) = M1(i-2) + offset(i+1);
            M1(i+2) = M1(i-1) + offset(i+2);
        
            P1(p_count) = M1(i-3) + offset(i);
            P2(p_count) = M1(i-2) + offset(i+1);
            P3(p_count) = M1(i-1) + offset(i+2);
            p_count = p_count + 1;
            
        else % if we are not making the skeleton
            
            
            trans = [1 0 0 offset(i); 0 1 0 offset(i+1); 0 0 1 offset(i+2); 0 0 0 1];
            rz(:,:,r_count) = [cos(M(t,i+3)*pi/180) -sin(M(t,i+3)*pi/180) 0 0; sin(M(t,i+3)*pi/180) cos(M(t,i+3)*pi/180) 0 0; 0 0 1 0; 0 0 0 1];    
            rx(:,:,r_count) = [1 0 0 0; 0 cos(M(t,i+4)*pi/180) -sin(M(t,i+4)*pi/180) 0; 0 sin(M(t,i+4)*pi/180) cos(M(t,i+4)*pi/180) 0; 0 0 0 1];    
            ry(:,:,r_count) = [cos(M(t,i+5)*pi/180) 0 sin(M(t,i+5)*pi/180) 0; 0 1 0 0; -sin(M(t,i+5)*pi/180) 0 cos(M(t,i+5)*pi/180) 0; 0 0 0 1];  
            G(:,:,r_count) = trans*rz(:,:,r_count)*rx(:,:,r_count)*ry(:,:,r_count);            
 

            temp = G(:,:,r_count);
            
            
            prev = get_prev(skel, r_count, endsite);
            
            
                
                
            while(prev ~= 1) % while we are not at the root, multiply the current joint's rotations on
            
                % use the rotation from the previous joint
                temp = G(:,:,prev)*temp;
            
                prev = get_prev(skel, prev, endsite);
            end
            
            D(:,:,r_count) = G(:,:,prev)*temp*root;
            
            
            P1(p_count) = D(1,1,r_count);
            P2(p_count) = D(2,1,r_count);
            P3(p_count) = D(3,1,r_count);

    
            % plot the points, if requested
            if points == 1
                plot3(D(1,1,r_count),D(3,1,r_count),D(2,1,r_count),'o');
            end
            p_count = p_count + 1;            
            r_count = r_count + 1;
            
        end
        
    end


    
    % fix and label the axis
    gmax = ceil(max(max(max(M(:,1)),max(M(:,2))),max(M(:,3))) + max(offset));
    axis([-gmax gmax -gmax gmax -gmax gmax]);
    xlabel('x');ylabel('z');zlabel('y');  
    
    % allow the axis to be rotated and keep the hold on the axis (so that
    % the current figure remains constant)
    rotate3d on;
    hold on;
    
end

% plot the latest line, if requested
if lines == 1
    plot3(P1, P3, P2); 
end



