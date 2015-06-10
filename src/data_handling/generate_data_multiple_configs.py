from csv import writer
from sklearn.cross_validation import KFold
from itertools import product
from generate_data_for_config import generate_data_for_config
from datasets import load_datasets, load_dataset, create_dataset
from utils import convert_range_string, name_to_classifier_object
from argparse import ArgumentParser
import sys

# This function calls generate_data_for_config for all configurations
def generate_data(name, classifier, datasets, percentage_data_values, parameters, n_folds=10):
    params_tuples = parameters.items()
    param_names = [t[0] for t in params_tuples]
    param_generators = [t[1] for t in params_tuples]

    for dataset in datasets:
        n_samples = dataset['n_samples']
        kf = KFold(n_samples, n_folds, shuffle=True, random_state=42)

        csvfile = open('out/data_{0}_{1}.csv'.format(name, dataset['name']), 'wb')

        datawriter = writer(csvfile)
        header = ['dataset_id'] + param_names + ['percentage_data', 'time', 'score']
        datawriter.writerow(header)

        # Compute configurations as cartesian product
        all_parameter_values = product(*param_generators)
        all_configs = product(all_parameter_values, percentage_data_values)
        
        for param_values, percentage_data in all_configs:
            param_values, percentage_data, elapsed_time, avg_score = generate_data_for_config(dataset, classifier, param_names, param_values, percentage_data, kf)

            # Print
            output = [dataset['id']] + list(param_values) + [percentage_data, elapsed_time, avg_score]
            sys.stdout.write(' '.join(['{0}: {1:7.2f};'.format(*t) for t in zip(header, output)]) + '\n')
            sys.stdout.flush()

            # Write to csv
            datawriter.writerow([dataset['id']] + list(param_values) + [percentage_data, elapsed_time, avg_score])            
                
        csvfile.close()

# Argument parser
parser = ArgumentParser(description='Collect data')
parser.add_argument('-a', '--algorithm', type=str, required=True, default='rnd_forest', help='The learning algorithm, one of [rnd_forest, log_reg, svm]')
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('-s', '--synthetic', type=str, help='Create a synthetic dataset with the given parameters')
group.add_argument('-l', '--load-arff', type=str, help='Load dataset from arff file with the given name')
group.add_argument('-z', '--datasets-of-size', type=str, help='Load datasets of the given size')
parser.add_argument('-d', '--percentage-data-values', type=str, required=True, help='A range for the percentage of data used. a:0.1:10:1 creates ten evenly spaced steps between 0 percent and 100 percent, g:0.01:10:1:1.1 creates a geometric series from 1 percent to 100 percent with 10 steps and a growth parameter of 1.1')
parser.add_argument('parameter', metavar='parameter', nargs='*', help='Parameters to the algorithm in the form <param_name>:<int|float>-<a|g>:start:steps:end[:growth_param]')

args = parser.parse_args()

classifier = name_to_classifier_object(args.algorithm)

if args.synthetic:
    datasets = [create_dataset(eval(args.synthetic))]
elif args.load_arff:
    datasets = [load_dataset({'name': args.load_arff})]
elif args.datasets_of_size:
    datasets = load_datasets(args.datasets_of_size)

percentage_data_values = convert_range_string(args.percentage_data_values)

parameters = {}
for param_str in args.parameter:
    t1 = param_str.split('-')
    t2 = t1[0].split(':')
    r = convert_range_string(t1[1])
    if t2[1]=='int':
        r = [int(round(v)) for v in r]
    parameters[t2[0]] = r

generate_data(args.algorithm, classifier, datasets, percentage_data_values, parameters)

