function [Ahat,sin_vals] = Linear_Model(X,n,m,Sigma_e)

% This function performs PCA on steady state flow measurements 

%% Getting the Constraint matrix by applying svd
L = chol(Sigma_e);
Xs = inv(L)*X;
[u,s,~]=svd(Xs);
Ahat = u(:,n-m+1:n)'*inv(L);      % A linear model of data
sin_vals = s(1:n,1:n);










