function [Inc_rect,unsp_edge] = unsp_edge_rectify_check(Inc_rep,e_c,ec_bar,nc_bar,X,meanX)

unsp_edge = setdiff(1:e_c,Inc_rep(1,:));    % Finding the unspecified edge based on the different between edge labels in data and incidence matrix
Inc_test = [Inc_rep(2:end,1:unsp_edge-1) zeros(nc_bar,1) Inc_rep(2:end,unsp_edge:end)]; % Adding a zero column in the position where there is the unspecified edge
sources = [];
sinks = [];
for i=1:nc_bar     % Finding the source and sink nodes
    if sum(any(Inc_test(i,:)==1))==1 && sum(any(Inc_test(i,:)==-1))==0
    sources = [sources i];
    elseif sum(any(Inc_test(i,:)==-1))==1 && sum(any(Inc_test(i,:)==1))==0
    sinks = [sinks i];
    end
end
intermediate = setdiff(1:nc_bar,[sources sinks]);
Inc_rect_inter = Inc_test(intermediate,:);

%Finding the residue at intermediate nodes
res_inter = Inc_rect_inter*X;
res_inter_mean = round(mean(res_inter,2));
if meanX(unsp_edge)>0
    Inc_rect_inter(res_inter_mean<0,unsp_edge)=1;
    Inc_rect_inter(res_inter_mean>0,unsp_edge)=-1;
else
    Inc_rect_inter(res_inter_mean<0,unsp_edge)=-1;
    Inc_rect_inter(res_inter_mean>0,unsp_edge)=1;
end
Inc_test(intermediate,:)=Inc_rect_inter;

%Finding the residue at source and sink nodes
Inc_test_source = Inc_test(sources,:);
Inc_test_sink = Inc_test(sinks,:);
Inc_test_source(:,unsp_edge)=-1;
Inc_test_sink(:,unsp_edge)=1;
res_source = Inc_test_source*X;
res_source_mean = round(mean(res_source,2));
res_sink = Inc_test_sink*X;
res_sink_mean = round(mean(res_sink,2));
temp1 = find(round(res_source_mean)==0)';
temp2 = find(round(res_sink_mean)==0)';
intermediate = [intermediate sources(temp1) sinks(temp2)];


% Merging all the source and sink nodes into a single environment node
del_node = [];
for i=1:size(Inc_test,1)
    if ~(any(Inc_test(i,:)==1)&&any(Inc_test(i,:)==-1))
        del_node = [del_node i];
    end
end
Inc_rect = Inc_test;
temp = sum(Inc_rect(del_node,:),1); % Environment node
Inc_rect(del_node,:) = [];
Inc_rect = [temp;Inc_rect]; % Adding incidence of environment node to the to incidence matrix

if sum(any(round(Inc_rect*X)))==0  % When the unspecified edge is connected to intermediate nodes of degree >2
    Inc_rect = [1:e_c;Inc_rect];
    fprintf('Edge %d is unspecified and now its connectivity is detemined. The rectified incidence matrix is given by Inc_rect.',unsp_edge);
else        % When the unspecified edge is connected to atleast one source or sink
    res = Inc_rect*X;
    res_mean = round(mean(res,2));
    if meanX(unsp_edge)>0
        Inc_rect(res_mean<0,unsp_edge)=1;
        Inc_rect(res_mean>0,unsp_edge)=-1;
    else
        Inc_rect(res_mean<0,unsp_edge)=-1;
        Inc_rect(res_mean>0,unsp_edge)=1;
    end
    if sum(any(round(Inc_rect*X)))==0
        fprintf('Edge %d is unspecified and now its connectivity is detemined. The rectified incidence matrix is given by Inc_rect.',unsp_edge);
        Inc_rect = [1:e_c;Inc_rect];
    else    % When the unspecified edge is connected to an intermediate node of degree 2
        del_node = setdiff(1:nc_bar,intermediate); 
        temp = sum(Inc_test(del_node,:),1); % Environment node
        Inc_test(del_node,:) = [];
        Inc_test = [temp;Inc_test]; % Adding incidence of environment node to the to incidence matrix
        res = Inc_test*X;
        res_mean = round(mean(res,2));
        if meanX(unsp_edge)>0
            Inc_test(res_mean<0,unsp_edge)=1;
            Inc_test(res_mean>0,unsp_edge)=-1;
        else
            Inc_test(res_mean<0,unsp_edge)=-1;
            Inc_test(res_mean>0,unsp_edge)=1;
        end
        if sum(any(round(Inc_test*X)))==0
            fprintf('Edge %d is unspecified and now its connectivity is detemined. The rectified incidence matrix is given by Inc_rect.',unsp_edge);
            Inc_rect = [1:e_c;Inc_test];
        else      
            fprintf('Error rectification failed.');
        end
    end
end