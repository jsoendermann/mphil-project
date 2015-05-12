VAR_DIR = '/Users/jan/Dropbox/mphil_project/repo/var/';
GPML_DIR = '/Users/jan/Dropbox/mphil_project/gpml-matlab-v3.5-2014-12-08/';
JSONLAB_DIR = '/Users/jan/Dropbox/mphil_project/repo/src/matlab/jsonlab/';
IN_FILENAME = 'scheduler_data.json';
OUT_FILENAME = 'models_and_decision.json';

% Add all the necessary dirs do the path
run(strcat(GPML_DIR, 'startup.m'));
addpath(JSONLAB_DIR);
me = mfilename;                                            % what is my filename
mydir = which(me); 
mydir = mydir(1:end-2-numel(me));        % where am I located
addpath(mydir(1:end-1));
addpath([mydir,'util']);

I = loadjson(strcat(VAR_DIR, IN_FILENAME));

O = struct();
O.models = {};

current_best.algo = 'None';
current_best.x = nan;
current_best.y = 0;

% Model
for i = 1:length(I.data)
    
    D = I.data{i};
    
    disp(D.algorithm);
    
    switch D.algorithm
        case {'log_reg', 'rnd_forest', 'naive_bayes'}
            time_function_type = 'linear';
            score_function_type = 'exp';
    end

    x_percent_data = D.x_percent_data';
    y_times = D.y_times';
    y_scores = D.y_scores';
    
    if isempty(x_percent_data)
        time_m = ones(100, 1);
        time_sd = ones(100, 1) * 100;
        score_m = ones(100, 1);
        score_sd = ones(100, 1) * 100;
    else
        [~, time_m, time_sd] = gp_wrapper(time_function_type, x_percent_data, y_times);
        [~, score_m, score_sd] = gp_wrapper(score_function_type, x_percent_data, y_scores);
        
        if strcmp(I.type, 'probability_of_improvement')
            [y_best, index_y_best] = max(y_scores);

            if y_best > current_best.y
                current_best.algo = D.algorithm;
                current_best.x = x_percent_data(index_y_best);
                current_best.y = y_best;
            end
        end
    end
    
    M = struct();
    M.algorithm = D.algorithm;
    M.time = struct('m', time_m', 'sd', time_sd');
    M.score = struct('m', score_m', 'sd', score_sd');
    O.models{i} = M;
end

% Decide
O.scheduler_specific = I.scheduler_specific;
switch I.type
    case 'fixed'
        sequence = I.scheduler_specific.sequence;
        sequence_index = I.scheduler_specific.sequence_index;
        
        sequence_index = sequence_index + 1;
        if sequence_index > length(sequence)
            stop = true;
            next_algorithm = 'STOP';
            next_x = -1;
        else
            stop = false;
            next_algorithm = sequence{sequence_index}{2};
            next_x = sequence{sequence_index}{1};
            O.scheduler_specific.sequence_index = O.scheduler_specific.sequence_index + 1;
        end
    case 'probability_of_improvement'
        O.scheduler_specific.current_best = current_best;
        
        burn_in_sequence = I.scheduler_specific.burn_in_sequence;
        burn_in_sequence_index = I.scheduler_specific.burn_in_sequence_index;
        
        burn_in_sequence_index = burn_in_sequence_index + 1;
        if burn_in_sequence_index <= length(burn_in_sequence)
            stop = false;
            next_algorithm = burn_in_sequence{burn_in_sequence_index}{2};
            next_x = burn_in_sequence{burn_in_sequence_index}{1};
            O.scheduler_specific.burn_in_sequence_index = O.scheduler_specific.burn_in_sequence_index + 1;
        else
            fprintf('Current best: %s; x:%f; y:%f\n', current_best.algo, current_best.x, current_best.y);
            Vs = []; % [algo_id x m sd]
            for i = 1:length(O.models)
                M = O.models{i};
                algo_id_column = repmat(i, 100, 1);
                score_x_column = linspace(0, 1, 100)';
                score_m_column = M.score.m';
                % TODO is this necessary? can the std dev be 0?
                score_sd_column = M.score.sd';% + 0.001; % add epsilon to avoid div by 0
                V = [algo_id_column score_x_column score_m_column score_sd_column];
                if isempty(Vs)
                    Vs = V;
                else
                    Vs = [Vs; V];
                end
            end
            
            Gamma = (Vs(:,3) - current_best.y)./Vs(:,4);
            % TODO maybe normcdf is unnecessary
            A = [Vs(:,1) Vs(:,2) normcdf(Gamma)];
            O.scheduler_specific.a = A(:,3)';
            
            [max_a_y, i_max_a] = max(A(:,3));
            max_a_algo_id = Vs(i_max_a, 1);
            max_a_x = Vs(i_max_a, 2);
            
            stop = false;
            next_algorithm = I.data{max_a_algo_id}.algorithm;
            % TODO deal with very small values or 0 for next_x
            next_x = max_a_x;
        end        
end
O.decision = struct('stop', stop, 'next_algorithm', next_algorithm, 'next_x', next_x);

savejson('', O, strcat(VAR_DIR, OUT_FILENAME));