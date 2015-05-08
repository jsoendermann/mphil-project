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
        time_m = zeros(100, 1);
        time_sd = zeros(100, 1);
        score_m = zeros(100, 1);
        score_sd = zeros(100, 1);
    else
        [~, time_m, time_sd] = gp_wrapper(time_function_type, x_percent_data, y_times);
        [~, score_m, score_sd] = gp_wrapper(score_function_type, x_percent_data, y_scores);
    end
    
    M = struct();
    M.algorithm = D.algorithm;
    M.time = struct('m', time_m', 'sd', time_sd');
    M.score = struct('m', score_m', 'sd', score_sd');
    O.models{i} = M;
end

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
        end
end
        
%         next_algorithm = I.scheduler_specific.next_algorithm;
%         
%         for i = 1:length(I.data)
%             D = I.data{i};
%             if strcmp(D.algorithm, next_algorithm)
%                 if isempty(D.x_percent_data)
%                     next_x = 0.1;
%                 else
%                     next_x = max(D.x_percent_data) + 0.1;
%                 end
%                 
%                 if next_x >= 1
%                     stop = true;
%                 else
%                     stop = false;
%                 end
%             end
%         end
% end

O.decision = struct('stop', stop, 'next_algorithm', next_algorithm, 'next_x', next_x);

savejson('', O, strcat(VAR_DIR, OUT_FILENAME));