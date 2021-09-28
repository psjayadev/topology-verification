function [Inc_rect] = unsp_node_rectify_check(Inc_rep,e_c,ec_bar,nc_bar,X,meanX,res_mean)

Inc_rect = [Inc_rep(2:end,:); zeros(1,ec_bar)];  % Adding a zero row
for i=1:nc_bar
    if sum(round(abs(meanX))==round(abs(res_mean(i))))==1
        temp = find(round(abs(meanX))==round(abs(res_mean(i))));
        Inc_rect(end,temp)=Inc_rect(i,temp);
        Inc_rect(i,temp)=0;
    elseif sum(round(abs(meanX))==round(abs(res_mean(i))))>1
    fprintf('Exceptional case - Error due to unspecified node cannot be rectified unambiguously');
    break
    end
end
if sum(any(round(Inc_rect*X)))==0
    fprintf('Presence of unspecified node is detected and recitified. The rectified incidence matrix is given by Inc_rect.');
    Inc_rect = [1:e_c;Inc_rect];
else
    fprintf('Error rectification failed.');
end
