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
    
    D{i} = {name, x, time, score};
    
    switch name
        case 'log_reg'
            model_time_function = @model_linear_function;
            model_score_function = @model_exponential_function;
        case 'rnd_forest'
            model_time_function = @model_linear_function;
            model_score_function = @model_exponential_function;
    end
    
    [time_m, time_sd] = model_time_function(x, time);
    [score_m, score_sd] = model_score_function(x, score);
    
    fprintf(fout, '%s\n', name);
    fprintf(fout, 'time_m: %s\n', num2str(time_m'));
    fprintf(fout, 'time_sd: %s\n', num2str(time_sd'));
    fprintf(fout, 'score_m: %s\n', num2str(score_m'));
    fprintf(fout, 'score_sd: %s\n', num2str(score_sd'));
    fprintf(fout, '\n');
    fgetl(fin);
end

fclose(fin);





fclose(fout);

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
