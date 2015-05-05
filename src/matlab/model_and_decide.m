%try
VAR_DIR = '/Users/jan/Dropbox/mphil_project/repo/var/';
GPML_DIR = '/Users/jan/Dropbox/mphil_project/gpml-matlab-v3.5-2014-12-08/';
IN_FILENAME = 'data.txt';
OUT_FILENAME = 'model_and_decision.txt';

run(strcat(GPML_DIR, 'startup.m'));

me = mfilename;                                            % what is my filename
mydir = which(me); 
mydir = mydir(1:end-2-numel(me));        % where am I located
addpath(mydir(1:end-1));
addpath([mydir,'util']);

fin = fopen(strcat(VAR_DIR, IN_FILENAME));
delete(strcat(VAR_DIR, OUT_FILENAME));
fout = fopen(strcat(VAR_DIR, OUT_FILENAME), 'w');

D = {};

for i = 1:intmax
    name = fgetl(fin);
    if isempty(name) || ~ischar(name)
        break;
    end
  
    x = eval(fgetl(fin))';
    time = eval(fgetl(fin))';
    score = eval(fgetl(fin))';
    % TODO check that all vectors are of the same length
    
    D{i} = {name, x, time, score};
    
    if isempty(x)
        fprintf(fout, '%s\n', name);
        fprintf(fout, 'time_m: %s\n', num2str(zeros(1,100)));
        fprintf(fout, 'time_sd: %s\n', num2str(zeros(1,100)));
        fprintf(fout, 'score_m: %s\n', num2str(zeros(1,100)));
        fprintf(fout, 'score_sd: %s\n', num2str(zeros(1,100)));
        fprintf(fout, 'time_by_score_x_lower: 0\n');
        fprintf(fout, 'time_by_score_x_upper: 1\n');
        fprintf(fout, 'time_by_score_m: %s\n', num2str(zeros(1,100)));
        fprintf(fout, 'time_by_score_sd: %s\n', num2str(zeros(1,100)));
        fprintf(fout, '\n');
        fgetl(fin);
    else
        switch name
            case 'log_reg'
                time_function_type = 'linear';
                score_function_type = 'exp';
                time_by_score_function_type = 'exp';
            case 'rnd_forest'
                time_function_type = 'linear';
                score_function_type = 'exp';
                time_by_score_function_type = 'exp';
            case 'naive_bayes'
                time_function_type = 'linear';
                score_function_type = 'exp';  
                time_by_score_function_type = 'exp';
        end

        %fprintf('%s time\n', name);
        [hyp_opt_time, time_m, time_sd] = gp_wrapper(time_function_type, x, time);
        fprintf('hyp_opt_time: %s\n', num2str(exp(hyps_struct_to_vec(hyp_opt_time))));

        %fprintf('%s score\n', name);
        [hyp_opt_score, score_m, score_sd] = gp_wrapper(score_function_type, x, score);
        fprintf('hyp_opt_score: %s\n', num2str(exp(hyps_struct_to_vec(hyp_opt_score))));
        
        %fprintf('%s time_by_score\n', name);
        min_x = 0;%max(min(time)-1, 0);
        max_x = max(time) * 2;
        z = linspace(min_x, max_x, 100)';
        [hyp_opt_time_by_score, time_by_score_m, time_by_score_sd] = gp_wrapper(time_by_score_function_type, time, score, z);
        fprintf('hyp_opt_time_by_score: %s\n', num2str(exp(hyps_struct_to_vec(hyp_opt_time_by_score))));
        

        fprintf(fout, '%s\n', name);
        fprintf(fout, 'time_m: %s\n', num2str(time_m'));
        fprintf(fout, 'time_sd: %s\n', num2str(time_sd'));
        fprintf(fout, 'score_m: %s\n', num2str(score_m'));
        fprintf(fout, 'score_sd: %s\n', num2str(score_sd'));
        fprintf(fout, 'time_by_score_x_lower: %f\n', min_x);
        fprintf(fout, 'time_by_score_x_upper: %f\n', max_x);
        fprintf(fout, 'time_by_score_m: %s\n', num2str(time_by_score_m'));
        fprintf(fout, 'time_by_score_sd: %s\n', num2str(time_by_score_sd'));
        fprintf(fout, '\n');
        fgetl(fin);
    end
end

fclose(fin);

next = 'STOP';
min_x = 1;


for i = 1:length(D)
    d = D{i};
    
    if isempty((d{2}))
        next = d{1};
        min_x = 0.0;
    elseif max(d{2}) < min_x
        next = d{1};
        min_x = max(d{2});
    end
end
    

fprintf(fout, 'next\n');
if strcmp(next, 'STOP') || min_x >= 1.0
    fprintf(fout, 'STOP\n\n');
else
    fprintf(fout, '%s\n%f\n', next, (min_x + 0.1));
end

fclose(fout);

%catch
    % TODO handle error
    % exit;
%end
