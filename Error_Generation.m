%% Generating an erroneous incidence matrix
function [Inc_rep,necon_rep,necon,nenet,ec_bar,nc_bar,error_nodes_true,error_edges_true] = Error_Generation(Inc_Con,Inc_net,e_c,n_c,error_select)
necon = [];
nenet = [];
error_nodes_true=[];
for i=1:e_c
    necon(end+1,:) = [i,find(Inc_Con(:,i)==1),find(Inc_Con(:,i)==-1)];
end
for i=1:e_c
    nenet(end+1,:) = [i,find(Inc_net(:,i)==1),find(Inc_net(:,i)==-1)];
end
Inc_rep = zeros(n_c,e_c);
switch error_select
    case 1  % Case 1: Swapped edges
        temp = randperm(e_c);
        edge1 = temp(1); % 1st edge in swap
        edge2 = temp(2); % 2nd edge is swap 
        Inc_rep = Inc_Con;
        Inc_rep(:,edge1) = Inc_Con(:,edge2);
        Inc_rep(:,edge2) = Inc_Con(:,edge1);
        Inc_rep = [1:e_c;Inc_rep];
        error_edges_true = [edge1 edge2];
        error_nodes_true = unique([necon(edge1,2:3) necon(edge2,2:3)]);
        ec_bar = e_c;
        nc_bar = n_c;
        
    case 2   % Case 2: Incorrectly specified edge
        sources = [];  % Source nodes
        sinks = [];     % sink nodes
        n = size(Inc_net,1);
        for i=1:n     % Finding the source and sink nodes
            if sum(any(Inc_net(i,:)==1))==1 && sum(any(Inc_net(i,:)==-1))==0
            sources = [sources i];
            elseif sum(any(Inc_net(i,:)==-1))==1 && sum(any(Inc_net(i,:)==1))==0
            sinks = [sinks i];
            end
        end
        intermediate = setdiff(1:n,[sources sinks]);
            
        while(sum(~any(Inc_rep,1))>0) % Ensuring that the error does not create a self loop in the conservation graph
            Inc_rep = Inc_net;
            error_edges_true = ceil(rand()*e_c);
            if rand()>0.25          % Both nodes are incorrectly specified
                temp1 = setdiff([sources intermediate],nenet(error_edges_true,2));
                new_node1 = temp1(ceil(rand()*size(temp1,2)));
                temp2 = setdiff([sinks intermediate],[nenet(error_edges_true,3) new_node1]);
                new_node2 = temp2(ceil(rand()*size(temp2,2))); 
                Inc_rep(:,error_edges_true) = zeros(size(Inc_rep,1),1);
                Inc_rep(new_node1,error_edges_true) = 1;
                Inc_rep(new_node2,error_edges_true) = -1;
            else             % Only one node is incorrectly specified
                temp1 = setdiff([sources intermediate],nenet(error_edges_true,2));
                temp2 = setdiff([sinks intermediate],nenet(error_edges_true,3));
                if rand()>0.5
                    new_node1 = temp1(ceil(rand()*size(temp1,2)));
                    new_node2 = nenet(error_edges_true,3);
                else
                    new_node1 = nenet(error_edges_true,2);
                    new_node2 = temp2(ceil(rand()*size(temp2,2))); 
                end
                Inc_rep(:,error_edges_true) = zeros(size(Inc_rep,1),1);
                Inc_rep(new_node1,error_edges_true) = 1;
                Inc_rep(new_node2,error_edges_true) = -1;
            end
            
            % Merging all the source and sink nodes into a single environment node
            del_node=[];
            for i=1:size(Inc_rep,1)
                if ~(any(Inc_rep(i,:)==1)&&any(Inc_rep(i,:)==-1))
                    del_node = [del_node i];
                end
            end
            temp = sum(Inc_rep(del_node,:),1); % Environment node
            Inc_rep(del_node,:) = [];
            Inc_rep = [temp;Inc_rep]; % Adding incidence of environment node to the to incidence matrix
        end
%             temp = ~any(Inc_rep,1);
%             Inc_rep(:,temp) = [];  % Deleting empty columns -  edges which form self loops at environment node
            nc_bar = size(Inc_rep,1);
            ec_bar = size(Inc_rep,2);
            Inc_rep = [1:e_c;Inc_rep];
            
        
    case 3   % Case 3: Unspecified edge
        error_edges_true = ceil(rand()*e_c);  % Randomly selecting the edge which is not specified
        Inc_rep = [1:e_c;Inc_net];
        Inc_rep(:,error_edges_true) = [];
        nc_bar = size(Inc_rep,1)-1;
        ec_bar = size(Inc_rep,2);
        
%         % Merging all the source and sink nodes into a single environment node
%         del_node = [];
%         for i=1:size(Inc_net,1)
%             if ~(any(Inc_net(i,:)==1)&&any(Inc_net(i,:)==-1))
%                 del_node = [del_node i];
%             end
%         end
%         temp = sum(Inc_net(del_node,:),1); % Environment node
%         Inc_rep = Inc_net;
%         Inc_rep(del_node,:) = [];
%         Inc_rep = [temp;Inc_rep]; % Adding incidence of environment node to the to incidence matrix
%         temp = ~any(Inc_rep,1);
%         Inc_rep(:,temp) = [];  % Deleting empty columns -  edges which form self loops at environment node
%         nc_bar = size(Inc_rep,1);
%         ec_bar = size(Inc_rep,2);
%         temp = setdiff(1:e_c,error_edges_true);
%         Inc_rep = [temp;Inc_rep];
         
        
    case 4  % Case 4: Unspecified node
        unsp_node = 1+ceil(rand()*n_c-1);  % Choosing an intermediate node which is not specified
        Inc_rep = Inc_Con;
        Inc_rep(unsp_node,:) = []; 
        error_edges_true = find(Inc_Con(unsp_node,:));
        temp1 = randperm(n_c-1);
        j=1;
        for i=1:size(error_edges_true,2)
            if Inc_rep(temp1(j),error_edges_true(i))==0 % Check that the edge is not already connected to the node
                Inc_rep(temp1(j),error_edges_true(i))=Inc_Con(unsp_node,error_edges_true(i));
            else
                if j==size(temp1,2)         % If the number of edges incident on unspecified node are greater than the rest of the nodes, then connect multiple edges to a node
                    j=1;
                else
                    j=j+1;
                end
                Inc_rep(temp1(j),error_edges_true(i))=Inc_Con(unsp_node,error_edges_true(i));
            end
            if j==size(temp1,2)         % If the number of edges incident on unspecified node are greater the rest of the nodes, then connect multiple edges to a node
                j=1;
            else
                j=j+1;
            end
        end
        nc_bar = size(Inc_rep,1);
        ec_bar = size(Inc_rep,2);
        Inc_rep = [1:e_c;Inc_rep];

end
necon_rep=[];
for i=1:size(Inc_rep,2)
%     if any(Inc_rep(2:end,i)==1) && any(Inc_rep(2:end,i)==-1)
        necon_rep(end+1,:) = [i,find(Inc_rep(2:end,i)==1),find(Inc_rep(2:end,i)==-1)];
%     end
end
        
        
        
%         list1 = [];
%         list2 = [];
%         for i=1:n_c
%             if sum(Inc_Con(i,:)==1)==1
%                 list1 = [list1 find(Inc_Con(i,:)==1)];
%             end
%             if sum(Inc_Con(i,:)==-1)==1
%                 list2 = [list2 find(Inc_Con(i,:)==-1)];
%             end
%         end
%         list = [list1 list2];
%         list = unique(list);    % List of edges which can be shifted 
%         temp = list(ceil(rand()*size(list,2))); % Selecting an edge from the list
%         if any(list1==temp)&&any(list2==temp)
%             test = 0;
%             while(test==0)
%                 Inc_new = [unique(Inc_Con','rows')' zeros(n_c,1)];
%                 temp1 = randperm(n_c);
%                 Inc_new(temp1(1),end)=1;
%                 Inc_new(temp1(2),end)=-1;
%                 [~,ia,ic]=unique(Inc_new','rows');
%                 if size(ic,1)==size(ia,1)
%                     test=1;
%                 end
%             end
%             Inc_rep=Inc_Con;
%             Inc_rep(:,temp)=Inc_new(:,end);
%             error_nodes = [find(Inc_Con(:,temp)~=Inc_rep(:,temp))]'
%         elseif any(list1==temp)
%             test = 0;   
%             while(test==0)
%                 Inc_new = [unique(Inc_Con','rows')' zeros(n_c,1)]; 
%                 temp1 = randperm(n_c);
%                 Inc_new(Inc_Con(:,temp)==1,end)=1;
%                 if find(Inc_Con(:,temp)==1)==temp1(1)
%                     Inc_new(temp1(2),end)=-1;
%                 else
%                     Inc_new(temp1(1),end)=-1;
%                 end
%                 [~,ia,ic]=unique(Inc_new','rows');
%                 if size(ic,1)==size(ia,1)
%                     test=1;
%                 end
%             end
%             Inc_rep=Inc_Con;
%             Inc_rep(:,temp)=Inc_new(:,end);
%             error_nodes = [find(Inc_Con(:,temp)~=Inc_rep(:,temp))]'
%         else
%             test = 0;
%             while(test==0)
%                 Inc_new = [unique(Inc_Con','rows')' zeros(n_c,1)]; 
%                 temp1 = randperm(n_c);
%                 Inc_new(Inc_Con(:,temp)==-1,end)=-1;
%                 if find(Inc_Con(:,temp)==-1)==temp1(1)
%                     Inc_new(temp1(2),end)=1;
%                 else
%                     Inc_new(temp1(1),end)=1;
%                 end
%                 [~,ia,ic]=unique(Inc_new','rows');
%                 if size(ic,1)==size(ia,1)
%                     test=1;
%                 end
%             end
%             Inc_rep=Inc_Con;
%             Inc_rep(:,temp)=Inc_new(:,end); 
%             error_nodes = [find(Inc_Con(:,temp)~=Inc_rep(:,temp))]'
%         end
%     end
% end