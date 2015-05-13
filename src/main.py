import numpy as np
import matplotlib.pyplot as plt
from data_handling.generate_data_for_config import generate_datum
from os.path import isfile, join
from os import remove
from subprocess import call
from argparse import ArgumentParser
from data_handling.datasets import load_dataset, create_dataset
from data_handling.utils import name_to_classifier_object, exp_incl_float_range
from datetime import datetime
from json import dumps, load
from itertools import product
from scipy.stats import norm
from collections import defaultdict

VAR_DIR = '/Users/jan/Dropbox/mphil_project/repo/var/'
FIG_DIR = '/Users/jan/Dropbox/mphil_project/repo/figs/'
OUT_FILENAME = 'scheduler_data.json'
IN_FILENAME = 'models.json'
MATLAB_EXECUTABLE = '/Applications/MATLAB_R2014b.app/bin/matlab'
MATLAB_SCRIPT = '/Users/jan/Dropbox/mphil_project/repo/src/matlab/model.m'

ALGORITHMS = {
           #'rnd_forest': {'single_letter': 'r', 'full_name': 'red', 'params': {'n_estimators': 15}}, 
           'log_reg': {'single_letter': 'b', 'full_name': 'blue', 'params': {}}, 
           #'naive_bayes': {'single_letter': 'g', 'full_name': 'green', 'params': {}}
           }

def call_matlab_script():
    call([MATLAB_EXECUTABLE,
          "-nodisplay", 
          "-nosplash", 
          "-nodesktop", 
          "-r", 
          "run('{}'); exit();".format(MATLAB_SCRIPT)])

class Datum:
    def __init__(self, x, time, score):
        if score < 0 or score > 1:
            raise ValueError('Score has to be bewtween 0 and 1 (is {})'.format(score))
        self.x = x
        self.time = time
        self.score = score

class Model:
    def __init__(self, mean, std_dev):
        if len(mean) != len(std_dev):
            raise ValueError('mean and std_dev must be of equal length')
        self.mean = np.array(mean)
        self.std_dev = np.array(std_dev)

    def twice_std_dev_above(self):
        return self.mean + 2 * self.std_dev

    def twice_std_dev_below(self):
        return self.mean - 2 * self.std_dev

class Scheduler(object):
    def __init__(self, scheduler_name):
        self.scheduler_name = scheduler_name

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
            self.models[name] = {'time': [Model(np.ones(100), np.ones(100) * 100)], 'score': [Model(np.ones(100), np.ones(100) * 100)]}

    @staticmethod
    def _write_datapoints(datapoints):
        x_percent_data = [d.x for d in datapoints]
        y_times = [d.time for d in datapoints]
        y_scores = [d.score for d in datapoints]
        res = {'x_percent_data': x_percent_data, 'y_times': y_times, 'y_scores': y_scores}

        filename = join(VAR_DIR, OUT_FILENAME)
        if isfile(filename):
            remove(filename)
        with open(filename, 'a') as f:
            f.write(dumps(res))

    @staticmethod
    def _read_models():
        filename = join(VAR_DIR, IN_FILENAME)

        with open(filename) as f:
            D = load(f)

        #print D

        time_models = []
        for time_model_data in D['time_models']:
            if time_model_data:
                time_models.append(Model(time_model_data['m'], time_model_data['sd']))

        score_models = []
        for score_model_data in D['score_models']:
            if score_model_data:
                score_models.append(Model(score_model_data['m'], score_model_data['sd']))

        return {'time': time_models, 'score': score_models}
        

    def execute(self):
        if not self.decision:
            return

        x, algorithm = self.decision

        # TODO catch ValueError: The number of classes has to be greater than one.
        elapsed_time, avg_score = generate_datum(dataset, 
                                                 name_to_classifier_object(algorithm), 
                                                 x, 
                                                 ALGORITHMS[algorithm]['params'])
        self.data[algorithm].append(Datum(x, elapsed_time, avg_score))
        self.cumulative_time.append(self.cumulative_time[len(self.cumulative_time)-1] + elapsed_time)
        self.highest_scores.append(max(self.highest_scores + [avg_score]))


    def model(self):
        if not self.decision:
            return

        _, last_algorithm = self.decision
        Scheduler._write_datapoints(self.data[last_algorithm])
        call_matlab_script()
        self.models[last_algorithm] = Scheduler._read_models()


    def draw(self, plt):
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
            time_models = models['time']
            score_models = models['score']

            for model in time_models:
                self.ax_time.plot(np.linspace(0, 1, 100), model.mean, ALGORITHMS[name]['single_letter']+'-', alpha=0.3)
                self.ax_time.plot(np.linspace(0, 1, 100), 
                                 model.twice_std_dev_above(), 
                                 ALGORITHMS[name]['single_letter']+':', 
                                 alpha=0.15)
                self.ax_time.plot(np.linspace(0, 1, 100), 
                                 model.twice_std_dev_below(), 
                                 ALGORITHMS[name]['single_letter']+':', 
                                 alpha=0.15)

                #self.ax_time.fill_between(np.linspace(0, 1, 100), 
                                 #model.twice_std_dev_below(), 
                                 #model.twice_std_dev_above(), 
                                 #facecolor=ALGORITHMS[name]['full_name'], 
                                 #alpha=0.05, 
                                 #interpolate=True)
            for model in score_models:
                self.ax_score.plot(np.linspace(0, 1, 100), model.mean, ALGORITHMS[name]['single_letter']+'-', alpha=0.3)
                self.ax_score.plot(np.linspace(0, 1, 100), 
                                 model.twice_std_dev_above(), 
                                 ALGORITHMS[name]['single_letter']+':', 
                                 alpha=0.15)
                self.ax_score.plot(np.linspace(0, 1, 100), 
                                 model.twice_std_dev_below(), 
                                 ALGORITHMS[name]['single_letter']+':', 
                                 alpha=0.15)
                
                #self.ax_score.fill_between(np.linspace(0, 1, 100), 
                                 #model.twice_std_dev_below(), 
                                 #model.twice_std_dev_above(), 
                                 #facecolor=ALGORITHMS[name]['full_name'], 
                                 #alpha=0.05, 
                                 #interpolate=True)

            # TODO put this back in
            #if model_time and model_score:
                #epsilon = np.ones(100) * 0.0001
                #self.ax_time_by_score.plot(np.random.normal(model_time.mean, model_time.std_dev + epsilon), 
                                           #np.random.normal(model_score.mean, model_score.std_dev + epsilon), ALGORITHMS[name]['single_letter']+'.')
                #self.ax_time_by_score.set_xlabel('Time')
                #self.ax_time_by_score.set_ylabel('Score')


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
        #self.ax_score.set_ylim(score_y_lim)
        self.ax_score.set_ylim(-0.01, 1)

        self.ax_time_by_score.set_xlim(0, None)
        ylim = self.ax_time_by_score.get_ylim()
        self.ax_time_by_score.set_ylim(max(0, ylim[0]), min(1, ylim[1]))

        plt.draw()

         
class FixedSequenceScheduler(Scheduler):
    def __init__(self, scheduler_name, sequence):
        Scheduler.__init__(self, scheduler_name)

        algorithms = ALGORITHMS.keys()
        self.sequence = list(product(sequence, algorithms))
        self.sequence_index = 1
    
    def decide(self):
        if self.sequence_index >= len(self.sequence):
            self.decision = None
        else:
            x, algorithm = self.sequence[self.sequence_index]
            self.decision = (x, algorithm)
            self.sequence_index += 1

class ProbabilisticScheduler(Scheduler):
    def __init__(self, scheduler_name, burn_in_percentages):
        super(ProbabilisticScheduler, self).__init__(scheduler_name)
 
        algorithms = ALGORITHMS.keys()
        self.burn_in_sequence = list(product(burn_in_percentages, algorithms))
        self.burn_in_sequence_index = 0

        self.acquisition_functions = defaultdict(list)

    @staticmethod
    def gamma(overall_best_score, mean, std_dev):
        # add epsilon to avoid div by 0
        return (mean - overall_best_score) / (std_dev + np.ones(100) * 0.0001)

    def draw(self, plt):
        super(ProbabilisticScheduler, self).draw(plt)

        for algorithm, acquisition_function in self.truncated_average_acquisition_functions().items():
            
            xs, ys = acquisition_function
            #print len(xs), len(ys)
            self.ax_score.plot(xs, ys, ALGORITHMS[algorithm]['single_letter']+'--')

        plt.draw()

    def decide(self):
        if self.burn_in_sequence_index < len(self.burn_in_sequence):
            x, algorithm = self.burn_in_sequence[self.burn_in_sequence_index]
            self.decision = (x, algorithm)
            self.burn_in_sequence_index += 1
        else:
            truncated_average_acquisition_functions = self.truncated_average_acquisition_functions()

            max_x = -1
            max_a = -1
            max_algorithm = None
            for algorithm, acquisition_function in truncated_average_acquisition_functions.items():
               
                xs, ys = acquisition_function
                if not xs:
                    # We're already at 100% of data
                    continue
                m = max(ys)
                if m > max_a:

                    max_a = m
                    max_x = xs[ys.argmax()]
                    max_algorithm = algorithm
            if max_algorithm:
                self.decision = (max_x, max_algorithm)
            else:
                self.decision = None

    def truncated_average_acquisition_functions(self):
        res = {}
        for algorithm, acquisition_functions in self.acquisition_functions.items():
            c = 0
            s = np.zeros(100)
            for acquisition_function in acquisition_functions:
                c += 1
                s += acquisition_function
            average_acquisition_function = s / c

            # Truncate
            max_x = 0
            for datum in self.data[algorithm]:
                max_x = max(datum.x, max_x)

            #print max_x

            xs = filter(lambda v: v > max_x, np.linspace(0, 1, 100))
            #print len(xs), xs
            if not xs:
                truncated_average_acquisition_function = []
            else:
                truncated_average_acquisition_function = average_acquisition_function[-len(xs):]
            #print len(truncated_average_acquisition_function), truncated_average_acquisition_function

            res[algorithm] = (xs, truncated_average_acquisition_function)
        return res

    def model(self):
        super(ProbabilisticScheduler, self).model()
        
        overall_best_score = 0
        for _, datapoints in self.data.items():
            for datum in datapoints:
                overall_best_score = max(overall_best_score, datum.score)

        self.acquisition_functions = defaultdict(list)
        for algorithm, models_for_algorithm in self.models.items():
            for score_model in models_for_algorithm['score']:
                acquisition_function = ProbabilityOfImprovementScheduler.a(overall_best_score, score_model.mean, score_model.std_dev)
                self.acquisition_functions[algorithm].append(acquisition_function)


class ProbabilityOfImprovementScheduler(ProbabilisticScheduler):
    @staticmethod
    def a(overall_best_score, mean, std_dev):
        return norm.cdf(ProbabilisticScheduler.gamma(overall_best_score, mean, std_dev))
        
class ExpectedImprovementScheduler(ProbabilisticScheduler):
    @staticmethod
    def a(overall_best_score, mean, std_dev):
        pass
                



            
            






#def update_highest_score_fig(schedulers, plt, ax):
    #ax.cla()
    #for scheduler in schedulers:
        #ax.plot(scheduler.cumulative_time, scheduler.highest_scores, '-', label=scheduler.scheduler_name)
    
    #plt.legend(loc=4)
    #plt.draw()

parser = ArgumentParser(description='Collect data')
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('-s', '--synthetic', type=str, help='Create a synthetic dataset with the given parameters')
group.add_argument('-l', '--load-arff', type=str, help='Load dataset from arff file with the given name')
args = parser.parse_args()

if args.synthetic:
    dataset = create_dataset(eval(args.synthetic))
elif args.load_arff:
    dataset = load_dataset({'name': args.load_arff})



schedulers = [
        ProbabilityOfImprovementScheduler('prob_of_impr', [0.01, 0.02, 0.04, 0.08]), 
        #FixedSequenceScheduler('fixed_exponential', exp_incl_float_range(0.05, 10, 1.0, 1.3))
        ]
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
    ax_counter += 1


    scheduler.ax_time = ax_time
    scheduler.ax_score = ax_score
    scheduler.ax_time_by_score = ax_time_by_score


ax_highest_score = plt.subplot(n_schedulers + 1, 3, ax_counter)
# TODO make this work
ax_highest_score.set_xlabel('Cumulative time')
ax_highest_score.set_ylabel('Highest score')



fig.subplots_adjust(hspace=0.35)
plt.draw()


while True:
    all_done = True
    for scheduler in schedulers:
        scheduler.decide()
        if scheduler.decision:
            all_done = False
            scheduler.execute()
            scheduler.model()
            scheduler.draw(plt)
            plt.savefig(FIG_DIR + 'fig_{}.pdf'.format(datetime.now().strftime('%Y-%m-%d_%H-%M-%S-%f')), format='pdf')

    if all_done:
        break

        #scheduler.draw(plt)
        #plt.savefig(FIG_DIR + 'fig_{}.pdf'.format(datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S-%f')), format='pdf')

    # TODO put this back in
    #update_highest_score_fig(schedulers, plt, ax_highest_score)

    
