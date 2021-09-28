%% Generating a random Conservation graph based on different algorithms

function [Inc_net,sources,sinks,intermediate,Inc_Con,Cc_Con,n_c,e_c,branch,chord,b,c] = Network_Generation(n,network_flag)
del_node = [];
sources = [];
sinks = [];
intermediate = [];

if network_flag==1
    % Generating a random network based on Erdos Renyi algorithm
    G_ER = erdosRenyi(n,0.5,1);         
    Adj = full(G_ER.Adj);             % Adjacent matrix 
elseif network_flag==2
    % Generating a random small world network
    G_SW = smallw(n,3,0.05);
    Adj = full(adjacency(G_SW));   % Adjacent matrix 
else
    % Generating a random scale free network
    Adj = BAgraph_dir(n,5,3);      % Adjacent matrix 
end
    

%% Converting the generated graph into a conservation graph
while isempty(del_node)
    Adj_dir = Adj;
    % Randomly assigning directions to the edges
    for i=1:n
        for j =i:n
            if Adj_dir(i,j)==1
                if i==j
                    Adj_dir(i,j)=0;
                else
                    if(rand()<=0.6)
                        Adj_dir(i,j)=0;
                        Adj_dir(j,i)=1;
                    else
                        Adj_dir(i,j)=1;
                        Adj_dir(j,i)=0;
                    end
                end
            end
        end
    end      

    % Getting Incidence Matrix of the generated directedgraph
    e = sum(Adj_dir(:));
    Inc_net = zeros(n,e);
    m=1;
    for i=1:n
        for j=1:n
            if Adj_dir(i,j)==1
                Inc_net(i,m)=-1;
                Inc_net(j,m)=1;
                m=m+1;
            end
        end
    end
    
    % Ensuring all sources and sinks in network have degree one
    for i=1:n
        if ~(any(Inc_net(i,:)==1))
            temp=find(Inc_net(i,:)==-1);
            for j=2:size(temp,2)
                Inc_net(i,temp(j))=0;
                Inc_net = [Inc_net;zeros(1,e)];
                Inc_net(end,temp(j))= -1;
            end
        end
        if ~(any(Inc_net(i,:)==-1))
            temp=find(Inc_net(i,:)==1);
            for j=2:size(temp,2)
                Inc_net(i,temp(j))=0;
                Inc_net = [Inc_net;zeros(1,e)];
                Inc_net(end,temp(j))= 1;
            end
        end
    end
    
    % Checking if the network has sources, sinks and intermediate nodes
    for i=1:n     % Finding the source and sink nodes
        if sum(any(Inc_net(i,:)==1))==1 && sum(any(Inc_net(i,:)==-1))==0
        sources = [sources i];
        elseif sum(any(Inc_net(i,:)==-1))==1 && sum(any(Inc_net(i,:)==1))==0
        sinks = [sinks i];
        end
    end
    intermediate = setdiff(1:n,[sources sinks]);
    if isempty(sources)||isempty(sinks)||isempty(intermediate)
        sources = [];
        sinks = [];
        intermediate = [];
        continue
    end
    
    % Merging all the source and sink nodes into a single environment node
    for i=1:size(Inc_net,1)
        if ~(any(Inc_net(i,:)==1)&&any(Inc_net(i,:)==-1))
            del_node = [del_node i];
        end
    end
end

temp = sum(Inc_net(del_node,:),1); % Environment node
Inc_Con = Inc_net;
Inc_Con(del_node,:) = [];
Inc_Con = [temp;Inc_Con]; % Adding incidence of environment node to the to incidence matrix
temp = ~any(Inc_Con,1);
Inc_Con(:,temp) = [];  % Deleting empty columns -  edges which form self loops at environment node
Inc_net(:,temp) = []; % Deleting edges which connect sources to sinks in the original network
temp = ~any(Inc_net,2);
Inc_net(temp,:) = []; % Deleting empty rows if they appear after deleting edges in previous step
n_c = size(Inc_Con,1);
e_c = size(Inc_Con,2);

          

%% Getting Adjancy matrix of conservation graph
Adj_Con = zeros(n_c,n_c); 
for i = 1:e_c
    s(i) = find(Inc_Con(:,i)==-1);
    t(i)= find(Inc_Con(:,i)==1);
    Adj_Con(s(i),t(i)) = i;
end

%% Finding a spanning tree of the graph
Adj_temp = Adj_Con;
for i=1:n_c
    for j=1:n_c
         if Adj_Con(i,j)==0
            Adj_temp(i,j) = Adj_Con(j,i);
        end
    end
end
G_temp = graph(Adj_temp,'upper');
T_con = minspantree(G_temp);
branch = T_con.Edges.Weight';
chord = setdiff(1:e_c,branch);
b = n_c-1; % No of branches
c = e_c-b; % No of chords        
     
%% Getting the f-cutset Matrix from Incidence Matrix 
Cc_Con = (inv(Inc_Con(1:end-1,branch))*Inc_Con(1:end-1,chord)); % Non-identity part

% % %% Partial Network Information
% % Ab = Inc_Con(1:end-1,branch);







