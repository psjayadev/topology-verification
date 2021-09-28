%% A function to plot the conservation graph given the incidence matrix
% MATLAB does not allow parallel edges between 2 nodes of a directed graph 
% Hence parallel edges get merged into one while plotting the graph

function Plot_Graph(Inc)

n_c = size(Inc,1);
e_c = size(Inc,2);

%% Getting Adjancy matrix of conservation graph
Adj = zeros(size(n_c,n_c)); 
for i = 1:e_c
    s(i) = find(Inc(:,i)==-1);
    t(i)= find(Inc(:,i)==1);
    Adj(s(i),t(i)) = i;
end

%% Drawing the conservation graph
G_con = digraph(Adj);
plot(G_con,'Layout','force','EdgeLabel',G_con.Edges.Weight)