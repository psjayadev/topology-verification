function [Inc_pred] = inc_edges_rectify(Inc_rep,error_nodes1,error_nodes2,inc_edges,type,meanX)
if type==1
    temp1 = setdiff(error_nodes1,inc_edges(2:3));   
    temp2 = setdiff(error_nodes2,inc_edges(2:3));
    if meanX(inc_edges(1))>0
        inc_edges(2) = temp2; 
        inc_edges(3) = temp1;
    else
        inc_edges(2) = temp1; 
        inc_edges(3) = temp2;
    end
elseif type==2
    temp = inc_edges(3);        % Exchanging position of the common node 
    inc_edges(3) = inc_edges(2);
    inc_edges(2) = temp;
    temp = setdiff(error_nodes1,inc_edges(2:3)); % Finding the actual node of the edge
    [~,ind] = intersect(inc_edges(2:3),error_nodes1); 
    inc_edges(ind+1) = temp;
else
    if sum(setdiff(inc_edges,[error_nodes1,error_nodes2]))==0 % handling error due to reversal of terminal nodes
        temp = inc_edges(3);
        inc_edges(3)=inc_edges(2);
        inc_edges(2)=temp;
    else  % errors other than reversal of nodes
        if inc_edges(2)==error_nodes1
            inc_edges(2)=error_nodes2;
        elseif inc_edges(2)==error_nodes2
            inc_edges(2)=error_nodes1;
        elseif inc_edges(3)==error_nodes1
            inc_edges(3)=error_nodes2;
        else
            inc_edges(3)=error_nodes1;
        end
    end
end
Inc_pred = Inc_rep(2:end,:);
Inc_pred(:,inc_edges(1))=0;
Inc_pred(inc_edges(2),inc_edges(1))=1;  % Inserting +1 in right position
Inc_pred(inc_edges(3),inc_edges(1))=-1;  % Inserting -1 in right position