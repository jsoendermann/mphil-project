try
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
        fprintf(fout, '\n');
        fgetl(fin);
    else
    
    
    
        switch name
            case 'log_reg'
                time_function_type = 'linear';
                score_function_type = 'exp';
            case 'rnd_forest'
                time_function_type = 'linear';
                score_function_type = 'exp';
        end

        [hyp_opt_time, time_m, time_sd] = gp_wrapper(time_function_type, x, time);

        [hyp_opt_score, score_m, score_sd] = gp_wrapper(score_function_type, x, score);

        fprintf(fout, '%s\n', name);
        fprintf(fout, 'time_m: %s\n', num2str(time_m'));
        fprintf(fout, 'time_sd: %s\n', num2str(time_sd'));
        fprintf(fout, 'score_m: %s\n', num2str(score_m'));
        fprintf(fout, 'score_sd: %s\n', num2str(score_sd'));
        fprintf(fout, '\n');
        fgetl(fin);
    end
end

fclose(fin);

next = 'STOP';
min_x = 1;


for i = 1:length(D)
    d = D{i};
    
    disp(d);
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

catch
    % TODO handle error
    exit;
end

%     fh=figure;
%     hold on;
%     plot(x, time, 'bo');
%     plot(linspace(0,1,100), time_m);
%     plot(linspace(0,1,100), time_m + 2 * time_sd);
%     plot(linspace(0,1,100), time_m - 2 * time_sd);
%     waitfor(fh);



% rf_x = eval(fgetl(fin))';
% rf_time = eval(fgetl(fin))';
% rf_score = eval(fgetl(fin))';
% 
% [rf_time_m, rf_time_sd] = model_linear_function(rf_x, rf_time);
% [rf_score_m, rf_score_sd] = model_exponential_function(rf_x, rf_score);
% 
% fprintf(fout, 'rnd_forest\n');
% fprintf(fout, 'm_time: %s\n', num2str(rf_time_m'));
% fprintf(fout, 'sd_time: %s\n', num2str(rf_time_sd'));
% fprintf(fout, 'm_score: %s\n', num2str(rf_score_m'));
% fprintf(fout, 'sd_score: %s\n', num2str(rf_score_sd'));
% 
% fprintf(fout, '\n');
% fgetl(fin)
% 
% if ~strcmp(fgetl(fin), 'lin_reg')
%     error('Error'); % TODO
% end
% 
% lr_x = eval(fgetl(fin))';
% lr_time = eval(fgetl(fin))';
% lr_score = eval(fgetl(fin))';
% 
% [lr_time_m, lr_time_sd] = model_linear_function(lr_x, lr_time);
% [lr_score_m, lr_score_sd] = model_exponential_function(lr_x, lr_score);
% 
% fprintf(fout, 'lin_reg\n');
% fprintf(fout, 'm_time: %s\n', num2str(lr_time_m'));
% fprintf(fout, 'sd_time: %s\n', num2str(lr_time_sd'));
% fprintf(fout, 'm_score: %s\n', num2str(lr_score_m'));
% fprintf(fout, 'sd_score: %s\n', num2str(lr_score_sd'));



% tline = fgetl(f);
% while ischar(tline)
%     disp(tline)
%     tline = fgetl(f);
% end
% 
