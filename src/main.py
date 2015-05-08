import numpy as np
import matplotlib.pyplot as plt
from data_handling.generate_data_for_config import generate_datum
from os.path import isfile, join
from os import remove
from subprocess import call
from argparse import ArgumentParser
from data_handling.datasets import load_dataset, create_dataset
from data_handling.utils import name_to_classifier_object, exp_incl_float_range
import datetime
from json import dumps, load
from itertools import product

VAR_DIR = '/Users/jan/Dropbox/mphil_project/repo/var/'
FIG_DIR = '/Users/jan/Dropbox/mphil_project/repo/figs/'
OUT_FILENAME = 'scheduler_data.json'
IN_FILENAME = 'models_and_decision.json'
MATLAB_EXECUTABLE = '/Applications/MATLAB_R2014b.app/bin/matlab'
MATLAB_SCRIPT = '/Users/jan/Dropbox/mphil_project/repo/src/matlab/model_and_decide.m'

ALGORITHMS = {
           'rnd_forest': {'single_letter': 'r', 'full_name': 'red', 'params': {'n_estimators': 3}}, 
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

class Scheduler:
    def __init__(self, scheduler_name, type_):
        self.scheduler_name = scheduler_name
        self.type_ = type_
        self.ax_time = None
        self.ax_score = None
        self.ax_time_by_score = None

        self.data = {}
        self.models = {}

        self.cumulative_time = [0]
        self.highest_scores = [0]

        self.decision = None

        for name, _ in ALGORITHMS.items():
            self.data[name] = []
            self.models[name] = {'time': None, 'score': None}

        self.scheduler_specific = {}


    def write_to_file(self):
        res = {'type': self.type_, 'scheduler_specific': self.scheduler_specific}
        out_data = []
        for name, datapoints in self.data.items():
            x_percent_data = [d.x for d in datapoints]
            y_times = [d.time for d in datapoints]
            y_scores = [d.score for d in datapoints]
            out_data.append({'algorithm': name, 'x_percent_data': x_percent_data, 'y_times': y_times, 'y_scores': y_scores})
        res['data'] = out_data

        filename = join(VAR_DIR, OUT_FILENAME)
        if isfile(filename):
            remove(filename)
        with open(filename, 'a') as f:
            f.write(dumps(res))
                    
    def load_models_and_decision(self): 
        filename = join(VAR_DIR, IN_FILENAME)

        with open(filename) as f:
            D = load(f)

        for model_data in D['models']:
            time_model = Model(0, 1, model_data['time']['m'], model_data['time']['sd'])
            score_model = Model(0, 1, model_data['score']['m'], model_data['score']['sd'])
            self.models[model_data['algorithm']] = {'time': time_model, 'score': score_model}

        self.decision = D['decision']
        

    def execute_decision(self):
        if not self.decision or self.decision['stop']:
            return
        else:
            next_algorithm = self.decision['next_algorithm']
            next_x = self.decision['next_x']
            elapsed_time, avg_score = generate_datum(dataset, 
                                                     name_to_classifier_object(next_algorithm), 
                                                     next_x, 
                                                     ALGORITHMS[next_algorithm]['params'])
            self.data[next_algorithm].append(Datum(next_x, elapsed_time, avg_score))
            self.cumulative_time.append(self.cumulative_time[len(self.cumulative_time)-1] + elapsed_time)
            self.highest_scores.append(max(self.highest_scores + [avg_score]))


    def draw_data_and_models(self, plt):
        self.ax_time.cla()
        self.ax_score.cla()
        self.ax_time_by_score.cla()

        for name, datapoints in self.data.items():
            xs = [d.x for d in datapoints]
            times = [d.time for d in datapoints]
            scores = [d.score for d in datapoints]

            self.ax_time.plot(xs, times, ALGORITHMS[name]['single_letter']+'o')
            self.ax_score.plot(xs, scores, ALGORITHMS[name]['single_letter']+'o')
 
        for name, models in self.models.items():
            model_time = models['time']
            model_score = models['score']

            if model_time:
                self.ax_time.plot(model_time.x(), model_time.mean, ALGORITHMS[name]['single_letter']+'-', alpha=0.1)
                self.ax_time.fill_between(model_time.x(), 
                                 model_time.twice_std_dev_below(), 
                                 model_time.twice_std_dev_above(), 
                                 facecolor=ALGORITHMS[name]['full_name'], 
                                 alpha=0.1, 
                                 interpolate=True)
            if model_score:
                self.ax_score.plot(model_score.x(), model_score.mean, ALGORITHMS[name]['single_letter']+'-', alpha=0.1)
                self.ax_score.fill_between(model_score.x(), 
                                 model_score.twice_std_dev_below(), 
                                 model_score.twice_std_dev_above(), 
                                 facecolor=ALGORITHMS[name]['full_name'], 
                                 alpha=0.1, 
                                 interpolate=True)

            if model_time and model_score:
                self.ax_time_by_score.plot(model_time.mean, model_score.mean, ALGORITHMS[name]['single_letter']+'.')
                self.ax_time_by_score.set_xlabel('Time')
                self.ax_time_by_score.set_ylabel('Score')
                self.ax_time_by_score.set_xlim(max(0, min(model_score.mean)), None)

        time_y_lim = [10e5, 0]
        score_y_lim = [10e5, 0]
        for _, datapoints in self.data.items():
            for datum in datapoints:
                time_y_lim[0] = min(time_y_lim[0], datum.time)
                time_y_lim[1] = max(time_y_lim[1], datum.time)
                score_y_lim[0] = min(score_y_lim[0], datum.score)
                score_y_lim[1] = max(score_y_lim[1], datum.score)
        if time_y_lim[0] > 10e4:
            time_y_lim = [0, 1]
        if score_y_lim[0] > 10e4:
            score_y_lim = [0, 1]

        time_d = time_y_lim[1] - time_y_lim[0]
        if time_d == 0:
            time_d = 0.1
        score_d = score_y_lim[1] - score_y_lim[0]
        if score_d == 0:
            score_d = 0.1
        
        ZOOM = 0.5
        time_y_lim[0] -= time_d * ZOOM
        time_y_lim[1] += time_d * ZOOM
        score_y_lim[0] -= score_d * ZOOM
        score_y_lim[1] += score_d * ZOOM
        
        
        self.ax_time.set_xlabel('% of data used')
        self.ax_time.set_ylabel('Time')
        self.ax_time.set_ylim(max(time_y_lim[0], 0), time_y_lim[1])
        
        self.ax_score.set_title(self.scheduler_name)
        self.ax_score.set_xlabel('% of data used')
        self.ax_score.set_ylabel('Score')
        self.ax_score.set_ylim(score_y_lim)

        
        #self.ax_time_by_score.set_ylim(0, 1)


        plt.draw()
         
class FixedSequenceScheduler(Scheduler):
    def __init__(self, scheduler_name, sequence):
        Scheduler.__init__(self, scheduler_name, 'fixed')
        algorithms = ALGORITHMS.keys()

        self.scheduler_specific = {'sequence': list(product(sequence, algorithms)), 'sequence_index': 0}
                
    def load_models_and_decision(self):
        Scheduler.load_models_and_decision(self)
        self.scheduler_specific['sequence_index'] += 1


def call_matlab_script():
    call([MATLAB_EXECUTABLE,
          "-nodisplay", 
          "-nosplash", 
          "-nodesktop", 
          "-r", 
          "run('{}'); exit();".format(MATLAB_SCRIPT)])

def update_highest_score_fig(schedulers, plt, ax):
    ax.cla()
    for scheduler in schedulers:
        ax.plot(scheduler.cumulative_time, scheduler.highest_scores, '-', label=scheduler.scheduler_name)
    
    plt.legend(loc=4)
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



schedulers = [FixedSequenceScheduler('fixed_linear', [0.05 + x/20.0 for x in range(20)]), 
        FixedSequenceScheduler('fixed_exponential', exp_incl_float_range(0.05, 20, 1.0, 1.1))]
n_schedulers = len(schedulers)


# Set up plot
plt.ion()
fig = plt.figure(1, figsize=(15, 12), dpi=80)

ax_counter = 1
for scheduler in schedulers:
    # Time
    ax_time = plt.subplot(n_schedulers + 1, 3, ax_counter)
    plt.xlim(0, 1)
    ax_counter += 1

    # Score
    ax_score = plt.subplot(n_schedulers + 1, 3, ax_counter)
    plt.xlim(0, 1)
    ax_counter += 1

    # Time by score
    ax_time_by_score = plt.subplot(n_schedulers + 1, 3, ax_counter)
    plt.xlim(0, 1)
    ax_counter += 1


    scheduler.ax_time = ax_time
    scheduler.ax_score = ax_score
    scheduler.ax_time_by_score = ax_time_by_score


ax_highest_score = plt.subplot(n_schedulers + 1, 3, ax_counter)
#plt.xlim(0, None)


fig.subplots_adjust(hspace=0.35)
plt.draw()


while True:
    for scheduler in schedulers:
        scheduler.write_to_file()
        call_matlab_script()
        scheduler.load_models_and_decision()

        scheduler.draw_data_and_models(plt)
    update_highest_score_fig(schedulers, plt, ax_highest_score)

    now = datetime.datetime.now()
    plt.savefig(FIG_DIR + 'fig_{}.pdf'.format(now.strftime('%Y-%m-%d_%H-%M-%S-%f')), format='pdf')
    
    for scheduler in schedulers:
        scheduler.execute_decision()

