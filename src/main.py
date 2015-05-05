import numpy as np
import matplotlib.pyplot as plt
from data_handling.generate_data_for_config import generate_datum
from os.path import isfile, join
from os import remove
from time import sleep
from subprocess import call
from argparse import ArgumentParser
from data_handling.datasets import load_dataset, create_dataset
from data_handling.utils import name_to_classifier_object

VAR_DIR = '/Users/jan/Dropbox/mphil_project/repo/var/'
DATA_FILENAME = 'data.txt'
# TODO change filename to models_and...
MODEL_AND_DECISION_FILENAME = 'model_and_decision.txt'
MATLAB_EXECUTABLE = '/Applications/MATLAB_R2014b.app/bin/matlab'
MATLAB_SCRIPT = '/Users/jan/Dropbox/mphil_project/repo/src/matlab/model_and_decide.m'

ALGORITHMS = {
           'rnd_forest': {'single_letter': 'r', 'full_name': 'red', 'params': {'n_estimators': 8}}, 
           'log_reg': {'single_letter': 'b', 'full_name': 'blue', 'params': {}}, 
           #'naive_bayes': {'single_letter': 'g', 'full_name': 'green', 'params': {}}
           }


class Datum:
    def __init__(self, x, time, score):
        if score < 0 or score > 1:
            raise ValueError('Score has to be bewtween 0 and 1 (is {})'.format(score))
        self.x = x
        self.time = time
        self.score = score

class Model:
    def __init__(self, min_x, max_x, mean, std_dev):
        if len(mean) != len(std_dev):
            raise ValueError('mean and std_dev must be of equal length')
        self.min_x = min_x
        self.max_x = max_x
        self.mean = np.array(mean)
        self.std_dev = np.array(std_dev)

    def x(self):
        return np.linspace(self.min_x, self.max_x, len(self.mean))

    def twice_std_dev_above(self):
        return self.mean + 2 * self.std_dev

    def twice_std_dev_below(self):
        return self.mean - 2 * self.std_dev


def write_data_to_file(data):
    filename = join(VAR_DIR, DATA_FILENAME)

    if isfile(filename):
        remove(filename)
    
    with open(filename, 'a') as f:
        for name, datapoints in data.items():
            f.write(name + '\n')
            
            xs_str = [str(d.x) for d in datapoints]
            times_str = [str(d.time) for d in datapoints]
            scores_str = [str(d.score) for d in datapoints]

            f.write('[{}] % xs\n'.format(' '.join(xs_str)))
            f.write('[{}] % times\n'.format(' '.join(times_str)))
            f.write('[{}] % scores\n'.format(' '.join(scores_str)))

            f.write('\n')
            
def call_matlab_script():
    call([MATLAB_EXECUTABLE,
          "-nodisplay", 
          "-nosplash", 
          "-nodesktop", 
          "-r", 
          "run('{}'); exit();".format(MATLAB_SCRIPT)])

def read_model_and_decision_file(data):
    filename = join(VAR_DIR, MODEL_AND_DECISION_FILENAME)

    with open(filename) as f:
        lines = f.readlines()
        lines = map(lambda l: l.strip(), lines)

    new_models = {}

    i = 0
    while True:
        if lines[i] == 'next':
            name = lines[i + 1]
            if name == 'STOP':
                return (name, None)
            new_x = float(lines[i + 2])
            return (name, new_x)
        else:
            #print(lines[i])
            name = lines[i]
            time_m_raw = lines[i + 1]
            time_sd_raw = lines[i + 2]
            score_m_raw = lines[i + 3]
            score_sd_raw = lines[i + 4]
            time_by_score_x_lower_raw = lines[i + 5]
            time_by_score_x_upper_raw = lines[i + 6]
            time_by_score_m_raw = lines[i + 7]
            time_by_score_sd_raw = lines[i + 8]

            time_m_str = time_m_raw[len('time_m: '):]
            time_sd_str = time_sd_raw[len('time_sd: '):]
            score_m_str = score_m_raw[len('score_m: '):]
            score_sd_str = score_sd_raw[len('score_sd: '):]
            time_by_score_x_lower_str = time_by_score_x_lower_raw[len('time_by_score_x_lower: '):]
            time_by_score_x_upper_str = time_by_score_x_upper_raw[len('time_by_score_x_upper: '):]
            time_by_score_m_str = time_by_score_m_raw[len('time_by_score_m: '):]
            time_by_score_sd_str = time_by_score_sd_raw[len('time_by_score_sd: '):]
        

            time_m = map(lambda s: float(s), time_m_str.split())
            time_sd = map(lambda s: float(s), time_sd_str.split())
            score_m = map(lambda s: float(s), score_m_str.split())
            score_sd = map(lambda s: float(s), score_sd_str.split())
            time_by_score_x_lower = float(time_by_score_x_lower_str)
            time_by_score_x_upper = float(time_by_score_x_upper_str)
            time_by_score_m = map(lambda s: float(s), time_by_score_m_str.split())
            time_by_score_sd = map(lambda s: float(s), time_by_score_sd_str.split())

            #times = [d.time for d in data[name]]
            #if times:
                #times_lower = min(times) - 1
                #times_upper = max(times) + 1
            #else:
                #times_lower = 0
                #times_upper = 1
            models[name] = {'time': Model(0, 1, time_m, time_sd), 
                            'score': Model(0, 1, score_m, score_sd), 
                            'time_by_score': Model(time_by_score_x_lower, time_by_score_x_upper, time_by_score_m, time_by_score_sd)}

            i += 10

def update_plot(data, models, plt, ax1, ax2):
    ax1.cla()
    ax2.cla()
    ax3.cla()

    for name, datapoints in data.items():
        xs = [d.x for d in datapoints]
        times = [d.time for d in datapoints]
        scores = [d.score for d in datapoints]

        ax1.plot(xs, times, ALGORITHMS[name]['single_letter']+'o')
        ax2.plot(xs, scores, ALGORITHMS[name]['single_letter']+'o')
        ax3.plot(times, scores, ALGORITHMS[name]['single_letter']+'o')

    for name, models in models.items():
        model_time = models['time']
        model_score = models['score']
        model_time_by_score = models['time_by_score']

        if model_time:
            ax1.plot(model_time.x(), model_time.mean, ALGORITHMS[name]['single_letter']+'-', alpha=0.1)
            ax1.fill_between(model_time.x(), 
                             model_time.twice_std_dev_below(), 
                             model_time.twice_std_dev_above(), 
                             facecolor=ALGORITHMS[name]['full_name'], 
                             alpha=0.1, 
                             interpolate=True)
        if model_score:
            ax2.plot(model_score.x(), model_score.mean, ALGORITHMS[name]['single_letter']+'-', alpha=0.1)
            ax2.fill_between(model_score.x(), 
                             model_score.twice_std_dev_below(), 
                             model_score.twice_std_dev_above(), 
                             facecolor=ALGORITHMS[name]['full_name'], 
                             alpha=0.1, 
                             interpolate=True)

        if model_time_by_score:
            ax3.plot(model_time_by_score.x(), model_time_by_score.mean, ALGORITHMS[name]['single_letter']+'-', alpha=0.1)
            ax3.fill_between(model_time_by_score.x(), 
                             model_time_by_score.twice_std_dev_below(), 
                             model_time_by_score.twice_std_dev_above(), 
                             facecolor=ALGORITHMS[name]['full_name'], 
                             alpha=0.1, 
                             interpolate=True)



    ax1.set_xlabel('% of data used')
    ax1.set_ylabel('Time')
    
    ax2.set_xlabel('% of data used')
    ax2.set_ylabel('Score')

    ax3.set_xlabel('Time')
    ax3.set_ylabel('Score')

    plt.draw()



data = {}
models = {}
for name, _ in ALGORITHMS.items():
    data[name] = []
    models[name] = {'time': None, 'score': None}


#data = {'rnd_forest': [], 'log_reg': [], 'naive_bayes': []}
#models = {'rnd_forest': {'time': None, 'score': None}, 
          #'log_reg': {'time': None, 'score': None},
          #'naive_bayes': {'time': None, 'score': None}}

#params = {'rnd_forest': {}, 'log_reg': {}, 'naive_bayes': {}}


# Set up plot
plt.ion()
fig = plt.figure(1, figsize=(8, 10), dpi=80)

# Times
ax1 = plt.subplot(311)
plt.xlim(0, 1)
#plt.ylim(0, None)

# Scores
ax2 = plt.subplot(312)
plt.xlim(0, 1)
#plt.ylim(0, 1)

ax3 = plt.subplot(313)
plt.xlim(0, None)
#plt.ylim(0, 1)

fig.subplots_adjust(hspace=0.5)
plt.draw()

parser = ArgumentParser(description='Collect data')
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('-s', '--synthetic', type=str, help='Create a synthetic dataset with the given parameters')
group.add_argument('-l', '--load-arff', type=str, help='Load dataset from arff file with the given name')
args = parser.parse_args()

if args.synthetic:
    dataset = create_dataset(eval(args.synthetic))
elif args.load_arff:
    dataset = load_dataset({'name': args.load_arff})

while True:
    write_data_to_file(data)
    call_matlab_script()
    
    name, next_x = read_model_and_decision_file(data)
    update_plot(data, models, plt, ax1, ax2)

    if name == 'STOP':
        raw_input("Press Enter to terminate...")

    print('Running {}...'.format(name))
    elapsed_time, avg_score = generate_datum(dataset, name_to_classifier_object(name), next_x, ALGORITHMS[name]['params'])
    data[name].append(Datum(next_x, elapsed_time, avg_score))
    
   # update_plot(data, models, plt, ax1, ax2)


