function [X,Sigma_e] = Data_Generation(n,branch,chord,b,c,Cc_Con,NSamples,SNR,noise_flag,Nrepeats)

% Initialization
mean_signal_choice = [100 200 300];        % Choice of mean value of a flow measurement
sdv_signal_choice = [10 15 20];            % Choice of standard deviation of a flow measurement
var_signal = zeros(n,1);

%% Randomly generating samples for independent flows
X_noisefree = zeros(n,NSamples);
for i=1:c
    select = ceil(rand()*3);
    X_noisefree(chord(i),:) = randn(1,NSamples)*sdv_signal_choice(select)+mean_signal_choice(select);
    var_signal(chord(i)) = sdv_signal_choice(select)^2;
end

%% Obtaining the corresponding measurements in the non-sink edges
for i=1:b
    X_noisefree(branch(i),:) = -Cc_Con(i,:)*X_noisefree(chord,:);
    var_signal(branch(i)) = sum(var_signal(chord));
end
sdv_signal = sqrt(var_signal);

if noise_flag==0
    X = X_noisefree;
    Sigma_e = [];
else    
    %% Addition of Gaussian noise to the data set
    if size(SNR,1)==1
        sdv_noise = sdv_signal./(SNR*ones(n,1));
    else
        sdv_noise = sdv_signal./SNR;
    end
    Sigma_e = diag(sdv_noise.^2);      % Noise Covariance Matrix
    sdv_noise = repmat(sdv_noise,1,NSamples);
    
    X = cell(1,Nrepeats);
    for i=1:Nrepeats
        X{1,i} = X_noisefree+sdv_noise.*randn(n,NSamples);
    end
end
            