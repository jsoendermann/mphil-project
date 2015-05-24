import numpy as np
import matplotlib.pyplot as plt
from data_handling.generate_data_for_config import generate_datum
from os.path import isfile, join
from os import remove
from subprocess import call
from argparse import ArgumentParser
from data_handling.datasets import load_dataset, create_dataset
from data_handling.utils import name_to_classifier_object, exp_incl_float_range, truncate_func_at_x, trunc_norm_mean_upper_tail
from datetime import datetime
from json import dumps, load
from itertools import product
from scipy.stats import norm, truncnorm
from collections import defaultdict
from shutil import move
from termcolor import colored


VAR_DIR = '/Users/jan/Dropbox/mphil_project/repo/var/'
FIG_DIR = '/Users/jan/Dropbox/mphil_project/repo/figs/'
OUT_FILENAME = 'scheduler_data.json'
IN_FILENAME = 'models.json'
MATLAB_EXECUTABLE = '/Applications/MATLAB_R2014b.app/bin/matlab'
MATLAB_SCRIPT = '/Users/jan/Dropbox/mphil_project/repo/src/matlab/model.m'

def call_matlab_script():
    call([MATLAB_EXECUTABLE,
          "-nodisplay", 
          "-nosplash", 
          "-nodesktop", 
          "-r", 
          "run('{}'); exit();".format(MATLAB_SCRIPT)])


ALGORITHMS = {
    'rnd_forest': {'single_letter': 'r', 'full_name': 'red', 'params': {'n_estimators': 50}},
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
    def __init__(self, mean, std_dev):
        if len(mean) != len(std_dev):
            raise ValueError('Mean and std_dev must be of equal length')
        self.mean = np.array(mean)
        self.std_dev = np.array(std_dev)

    def twice_std_dev_above(self):
        return self.mean + 2 * self.std_dev

    def twice_std_dev_below(self):
        return self.mean - 2 * self.std_dev


class Scheduler(object):
    def __init__(self, scheduler_name):
        self.scheduler_name = scheduler_name

        self.data = {}
        self.models = None

        self.cumulative_time = [0]
        self.highest_scores = [0]

        self.decision = None

        for name in ALGORITHMS.keys():
            self.data[name] = []

    
    def decide(self):
        raise NotImplementedError()

    # TODO this should be a class method
    def needs_model(self):
        raise NotImplementedError()
        

    def execute(self):
        if not self.decision:
            return None

        x, algorithm = self.decision

        # TODO catch ValueError: The number of classes has to be greater than one.
        elapsed_time, avg_score = generate_datum(dataset, 
                                                 name_to_classifier_object(algorithm), 
                                                 x, 
                                                 ALGORITHMS[algorithm]['params'])
        self.data[algorithm].append(Datum(x, elapsed_time, avg_score))
        self.cumulative_time.append(self.cumulative_time[len(self.cumulative_time)-1] + elapsed_time)
        self.highest_scores.append(max(self.highest_scores + [avg_score]))

        return (elapsed_time, avg_score)


    def model(self):
        if not self.models:
            self._reset_models()
            for algorithm, _ in ALGORITHMS.items():
                self._model_algorithm(algorithm)
        elif self.decision:
            _, last_algorithm = self.decision
            self._model_algorithm(last_algorithm)
        

    def _reset_models(self):
        self.models = {}
        for name in ALGORITHMS.keys():
            self.models[name] = {'time': [], 'score': []}


    def _model_algorithm(self, algorithm):
        self._write_datapoints(algorithm)
        call_matlab_script()
        self._read_models(algorithm)


    def _write_datapoints(self, algorithm):
        datapoints = self.data[algorithm]

        x_percent_data = [d.x for d in datapoints]
        y_times = [d.time for d in datapoints]
        y_scores = [d.score for d in datapoints]
        res = {'x_percent_data': x_percent_data, 'y_times': y_times, 'y_scores': y_scores}

        filename = join(VAR_DIR, OUT_FILENAME)
        if isfile(filename):
            #move(filename, join(VAR_DIR, 'scheduler_data_{}.json'.format(datetime.now().strftime('%Y-%m-%d_%H-%M-%S-%f'))))
            remove(filename)

        with open(filename, 'a') as f:
            f.write(dumps(res))


    def _read_models(self, algorithm):
        filename = join(VAR_DIR, IN_FILENAME)

        with open(filename) as f:
            D = load(f)

        time_models = []
        for time_model_data in D['time_models']:
            if time_model_data:
                time_models.append(Model(time_model_data['m'], time_model_data['sd']))

        score_models = []
        for score_model_data in D['score_models']:
            if score_model_data:
                score_models.append(Model(score_model_data['m'], score_model_data['sd']))

        self.models[algorithm] = {'time': time_models, 'score': score_models}


    def draw(self):
        self._clear_axes()
        self._draw_data()
        self._set_labels_and_limits()
        self.plt.draw()


    def _clear_axes(self):
        self.ax_time.cla()
        self.ax_score.cla()
        self.ax_time_by_score.cla()


    def _draw_data(self):
        for name, datapoints in self.data.items():
            xs = [d.x for d in datapoints]
            times = [d.time for d in datapoints]
            scores = [d.score for d in datapoints]

            self.ax_time.plot(xs, times, ALGORITHMS[name]['single_letter']+'.')
            self.ax_score.plot(xs, scores, ALGORITHMS[name]['single_letter']+'.')
 
        if self.models:
            for name, models in self.models.items():
                time_models = models['time']
                score_models = models['score']

                for model in time_models:
                    self.ax_time.plot(np.linspace(0, 1, 100), model.mean, ALGORITHMS[name]['single_letter']+'-', alpha=0.3)

                    self.ax_time.fill_between(np.linspace(0, 1, 100), 
                                     model.twice_std_dev_below(), 
                                     model.twice_std_dev_above(), 
                                     facecolor=ALGORITHMS[name]['full_name'], 
                                     alpha=0.05, 
                                     interpolate=True)
                for model in score_models:
                    self.ax_score.plot(np.linspace(0, 1, 100), model.mean, ALGORITHMS[name]['single_letter']+'-', alpha=0.3)

                    self.ax_score.fill_between(np.linspace(0, 1, 100), 
                                     model.twice_std_dev_below(), 
                                     model.twice_std_dev_above(), 
                                     facecolor=ALGORITHMS[name]['full_name'], 
                                     alpha=0.05, 
                                     interpolate=True)

                for time_model, score_model in zip(time_models, score_models):
                    epsilon = np.ones(100) * 0.0001
                    self.ax_time_by_score.plot(np.random.normal(time_model.mean, time_model.std_dev + epsilon), 
                                               np.random.normal(score_model.mean, score_model.std_dev + epsilon), ALGORITHMS[name]['single_letter']+'.')
                    self.ax_time_by_score.set_xlabel('Time')
                    self.ax_time_by_score.set_ylabel('Score')

    
    def _set_labels_and_limits(self):
        time_y_lim = [10e5, 0]
        for _, datapoints in self.data.items():
            for datum in datapoints:
                time_y_lim[0] = min(time_y_lim[0], datum.time)
                time_y_lim[1] = max(time_y_lim[1], datum.time)
        if time_y_lim[0] > 10e4:
            time_y_lim = [0, 1]

        time_d = time_y_lim[1] - time_y_lim[0]
        if time_d == 0:
            time_d = 0.1
        
        ZOOM = 0.5
        time_y_lim[0] -= time_d * ZOOM
        time_y_lim[1] += time_d * ZOOM
        
        
        self.ax_time.set_xlabel('% of data used')
        self.ax_time.set_ylabel('Time')
        self.ax_time.set_ylim(max(time_y_lim[0], 0), time_y_lim[1])
        
        self.ax_score.set_title(self.scheduler_name)
        self.ax_score.set_xlabel('% of data used')
        self.ax_score.set_ylabel('Score')
        self.ax_score.set_xlim(0, 1)
        self.ax_score.set_ylim(0, 1)

        self.ax_time_by_score.set_xlim(0, None)
        ylim = self.ax_time_by_score.get_ylim()
        self.ax_time_by_score.set_ylim(max(0, ylim[0]), min(1, ylim[1]))

    
    @classmethod
    def has_acquisition_function(self):
        raise NotImplementedError()


         
class FixedSequenceScheduler(Scheduler):
    def __init__(self, scheduler_name, sequence):
        super(FixedSequenceScheduler, self).__init__(scheduler_name)

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


    def needs_model(self):
        return False


    @classmethod
    def has_acquisition_function(self):
        return False



class ProbabilisticScheduler(Scheduler):
    def __init__(self, scheduler_name, burn_in_percentages):
        super(ProbabilisticScheduler, self).__init__(scheduler_name)
 
        self.ax_acq = None
        
        algorithms = ALGORITHMS.keys()
        self.burn_in_sequence = list(product(burn_in_percentages, algorithms))
        self.burn_in_sequence_index = 0

        self.acquisition_functions = dict()


    def decide(self):
        if self.burn_in_sequence_index < len(self.burn_in_sequence):
            x, algorithm = self.burn_in_sequence[self.burn_in_sequence_index]
            self.decision = (x, algorithm)
            
        else:
            max_x = -1
            max_a = -1
            max_algorithm = None
            for algorithm, acquisition_function in self.acquisition_functions.items():
                xs, ys = acquisition_function
                if len(xs) == 0:
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

        self.burn_in_sequence_index += 1


    def model(self):
        super(ProbabilisticScheduler, self).model()
        
        overall_best_score = self._overall_best_score()
        additional_parameters = self._additional_acquisition_function_parameters()

        self.acquisition_functions = dict()
        for algorithm, models_for_algorithm in self.models.items():
            acquisition_functions = []
            for score_model, time_model in zip(models_for_algorithm['score'], models_for_algorithm['time']):
                acquisition_function = self.__class__.a(self, overall_best_score, score_model.mean, score_model.std_dev, time_model.mean, time_model.std_dev, **additional_parameters)
                acquisition_functions.append(acquisition_function)
            avg_acquisition_function = (np.linspace(0,1,100), np.mean(acquisition_functions, axis=0))

            if self._truncate_a():
                max_x = 0
                for datum in self.data[algorithm]:
                    max_x = max(datum.x, max_x)

                xs_org, ys_org = avg_acquisition_function
                xs, ys = truncate_func_at_x(max_x, xs_org, ys_org)
                avg_acquisition_function = (xs, ys)
            else:
                xs_org, ys_org = avg_acquisition_function
                xs, ys = truncate_func_at_x(0.01, xs_org, ys_org)
                avg_acquisition_function = (xs, ys)
                
            self.acquisition_functions[algorithm] = avg_acquisition_function

    def _truncate_a(self):
        return True

    def _additional_acquisition_function_parameters(self):
        return dict()

    def _overall_best_score(self):
        overall_best_score = 0
        for _, datapoints in self.data.items():
            for datum in datapoints:
                overall_best_score = max(overall_best_score, datum.score)
        return overall_best_score

    def needs_model(self):
        return self.burn_in_sequence_index >= len(self.burn_in_sequence)

    def _clear_axes(self):
        super(ProbabilisticScheduler, self)._clear_axes()
        
        self.ax_acq.cla()


    def _draw_data(self):
        super(ProbabilisticScheduler, self)._draw_data()

        for algorithm, acquisition_function in self.acquisition_functions.items():
            xs, ys = acquisition_function
            self.ax_acq.plot(xs, ys, ALGORITHMS[algorithm]['single_letter']+'--')


    def _set_labels_and_limits(self):
        super(ProbabilisticScheduler, self)._set_labels_and_limits()

        self.ax_acq.set_xlim(0, 1)
        self.ax_acq.set_ylim(0, None)
        self.ax_acq.set_ylabel('Acq. function value')


    @classmethod
    def has_acquisition_function(self):
        return True

    @staticmethod
    def _gamma(mean, overall_best, sd):
        return (mean - overall_best) / (sd + np.ones(100) * 0.0001)

    @classmethod
    def a(cls, self, overall_best_score, score_mean, score_std_dev, time_mean, time_std_dev):
        raise NotImplementedError()
    



class ProbabilityOfImprovementScheduler(ProbabilisticScheduler):
    @classmethod
    def a(cls, self, overall_best_score, score_mean, score_std_dev, time_mean, time_std_dev):
        return ProbabilisticScheduler._gamma(score_mean, overall_best_score, score_std_dev)
        #return norm.cdf((score_mean - overall_best_score) / (score_std_dev + np.ones(100) * 0.0001))
      


class ExpectedImprovementScheduler(ProbabilisticScheduler):
    @classmethod
    def a(cls, self, overall_best_score, score_mean, score_std_dev, time_mean, time_std_dev):
        g = ProbabilisticScheduler._gamma(score_mean, overall_best_score, score_std_dev)
        return score_std_dev * (g * norm.cdf(g) + norm.pdf(g))


class ExpectedImprovementPerTimeScheduler(ExpectedImprovementScheduler):
    @classmethod
    def a(cls, self, overall_best_score, score_mean, score_std_dev, time_mean, time_std_dev):
        # TODO Find out if there's a way to refer to this class indirectly
        ei = ExpectedImprovementScheduler.a(self, overall_best_score, score_mean, score_std_dev, time_mean, time_std_dev)
        return ei / time_mean



class TimedScheduler(ProbabilisticScheduler):
    def __init__(self, scheduler_name, burn_in_percentages, available_time):
        super(TimedScheduler, self).__init__(scheduler_name, burn_in_percentages)
        self.remaining_time = available_time


    def add_time(self, t):
        self.remaining_time += t
        print colored('Added time, now {}'.format(self.remaining_time), 'cyan')

    def execute(self):
        res = super(TimedScheduler, self).execute()
        if not res:
            return None

        time, _ = res

        if self.burn_in_sequence_index > len(self.burn_in_sequence):
            self.remaining_time -= time
            
        print colored('Remaining time: {}'.format(self.remaining_time), 'cyan')

    def _additional_acquisition_function_parameters(self):
        return {'remaining_time': self.remaining_time}

    def _draw_data(self):
        super(TimedScheduler, self)._draw_data()

        time_x_min, time_x_max = self.ax_time.get_xlim()
        self.ax_time.plot([0, 1], [self.remaining_time, self.remaining_time], 'k-')
        self.ax_time.annotate('Remaining time', xy=(0, self.remaining_time), va="top", ha="left")
        self.ax_time.set_xlim(time_x_min, min(1, time_x_max * 1.05))

    def _set_labels_and_limits(self):
        super(TimedScheduler, self)._set_labels_and_limits()

        ylim = self.ax_time.get_ylim()
        self.ax_time.set_ylim(0, max(0.01, ylim[1], self.remaining_time * 1.025))

    def _truncate_a(self):
        return False

        


class ExpectedImprovementTimesProbOfSuccessScheduler(TimedScheduler, ExpectedImprovementScheduler):
    def __init__(self, scheduler_name, burn_in_percentages, time_steps):
        super(ExpectedImprovementTimesProbOfSuccessScheduler, self).__init__(scheduler_name, burn_in_percentages, time_steps[0])
        self.time_steps = time_steps[1:]

    def decide(self):
        super(ExpectedImprovementTimesProbOfSuccessScheduler, self).decide()
        if self.remaining_time < 0:
            self.decision = None

    def execute(self):
        super(ExpectedImprovementTimesProbOfSuccessScheduler, self).execute()

        print self.remaining_time, self.time_steps

        if self.remaining_time < 0:
            if self.time_steps:
                self.add_time(self.time_steps[0])
                self.time_steps = self.time_steps[1:]
            else:
                return None

    @classmethod
    def a(cls, self, overall_best_score, score_mean, score_std_dev, time_mean, time_std_dev, remaining_time):
        # TODO Change this to a list comprehension
        prob_of_success = np.zeros(len(time_mean))
        for i, (tm, tsd) in enumerate(zip(time_mean, time_std_dev)):
            prob_of_success[i] = norm.cdf(remaining_time, loc=tm, scale=tsd)

        # TODO Find out if there's a way to refer to this class indirectly
        ei = ExpectedImprovementScheduler.a(self, overall_best_score, score_mean, score_std_dev, time_mean, time_std_dev)

        #print ei
        #print prob_of_success

        res = ei * prob_of_success
        
        print res

        return res

class MinimiseUncertaintyAndExploitScheduler(TimedScheduler):
    def __init__(self, scheduler_name, burn_in_percentages, explore_time, exploit_time):
        super(MinimiseUncertaintyAndExploitScheduler, self).__init__(scheduler_name, burn_in_percentages, explore_time)
        self.burn_in_end = burn_in_percentages[-1]
        
        self.exploit_time = exploit_time
        self.exploring = True


    def decide(self):
        super(MinimiseUncertaintyAndExploitScheduler, self).decide()
        
        if self.remaining_time < 0:
            if self.exploring:
                print colored('Exploiting!', 'red')
                self.exploring = False
                self.remaining_time += self.exploit_time
            else:
                self.decision = None

    def execute(self):
        super(MinimiseUncertaintyAndExploitScheduler, self).execute()


    def model(self):
        super(MinimiseUncertaintyAndExploitScheduler, self).model()

        for algorithm, acquisition_function in self.acquisition_functions.items():
            xs_org, ys_org = acquisition_function
            xs, ys = truncate_func_at_x(self.burn_in_end, xs_org, ys_org)
            acquisition_function = (xs, ys)
                
            self.acquisition_functions[algorithm] = acquisition_function


    @classmethod
    def a(cls, self, overall_best_score, score_mean, score_std_dev, time_mean, time_std_dev, remaining_time):
        prob_of_success = np.zeros(len(time_mean))
        for i, (tm, tsd) in enumerate(zip(time_mean, time_std_dev)):
            prob_of_success[i] = norm.cdf(remaining_time, loc=tm, scale=tsd)
        if self.exploring:
            return score_std_dev / time_mean * prob_of_success
        else:
            return score_mean * prob_of_success
            







def update_highest_score_fig(schedulers, plt, ax):
    ax.cla()
    for scheduler in schedulers:
        ax.plot(scheduler.cumulative_time, scheduler.highest_scores, '-', label=scheduler.scheduler_name)
    
    plt.legend(loc=4)

    ax.set_xlabel('Cumulative time')
    ax.set_ylabel('Highest score')

    plt.draw()



def save_fig(plt):
    plt.savefig(FIG_DIR + 'fig_{}.pdf'.format(datetime.now().strftime('%Y-%m-%d_%H-%M-%S-%f')), format='pdf')



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
    #MinimiseUncertaintyAndExploitScheduler('explore then exploit', exp_incl_float_range(0.005, 15, 0.15, 1.3), 5, 20),
    ExpectedImprovementTimesProbOfSuccessScheduler('EI * prob. of success', exp_incl_float_range(0.005, 15, 0.15, 1.3), exp_incl_float_range(1, 8, 30, 1.3) ),
    #FixedSequenceScheduler('fixed_exponential', exp_incl_float_range(0.005, 15, 0.15, 1.3) + exp_incl_float_range(0.175, 10, 1.0, 1.3))
    #ProbabilityOfImprovementScheduler('Prob. of improvement', exp_incl_float_range(0.005, 15, 0.1, 1.3)),
    #ExpectedImprovementPerTimeScheduler('EI/Time', exp_incl_float_range(0.005, 15, 0.2, 1.3)),
    #ExpectedImprovementPerTimeScheduler('EI/Time', exp_incl_float_range(0.005, 15, 0.2, 1.3)),
    #FixedSequenceScheduler('fixed_exponential', exp_incl_float_range(0.05, 10, 1.0, 1.3))
    ]
n_schedulers = len(schedulers)


# Set up plot
plt.ion()
fig = plt.figure(1, figsize=(20, 14), dpi=80)

ax_counter = 1
for scheduler in schedulers:
    # Time
    ax_time = plt.subplot(n_schedulers + 1, 3, ax_counter)
    scheduler.ax_time = ax_time
    ax_counter += 1

    # Score
    ax_score = plt.subplot(n_schedulers + 1, 3, ax_counter)
    scheduler.ax_score = ax_score
    ax_counter += 1

    if scheduler.__class__.has_acquisition_function():
        ax_acq = ax_score.twinx()
        scheduler.ax_acq = ax_acq
    
    # Time by score
    ax_time_by_score = plt.subplot(n_schedulers + 1, 3, ax_counter)
    scheduler.ax_time_by_score = ax_time_by_score
    ax_counter += 1

    scheduler.plt = plt

ax_highest_score = plt.subplot(n_schedulers + 1, 3, ax_counter)

SPACE = 0.3
fig.subplots_adjust(wspace=SPACE, hspace=SPACE)

plt.draw()

while True:
    terminate = True

    for scheduler in schedulers:
        scheduler.decide()
        if scheduler.decision:
            terminate = False
            scheduler.execute()
            if scheduler.needs_model():
                scheduler.model()
            scheduler.draw()
            update_highest_score_fig(schedulers, plt, ax_highest_score)
            save_fig(plt)

    if terminate:
        break
