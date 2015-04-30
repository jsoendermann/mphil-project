from generate_data_for_configuration import generate_data

from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.naive_bayes import GaussianNB

from sys import argv
from datasets import load_datasets, load_dataset, create_dataset
from utils import convert_range_string
from argparse import ArgumentParser

parser = ArgumentParser(description='Collect data')
parser.add_argument('-a', '--algorithm', type=str, required=True, default='rnd_forest', help='The learning algorithm, one of [rnd_forest, log_reg, svm]')

group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('-s', '--synthetic', type=str, help='Create a synthetic dataset with the given parameters')
group.add_argument('-l', '--load-arff', type=str, help='Load dataset from arff file with the given name')
group.add_argument('-z', '--datasets-of-size', type=str, help='Load datasets of the given size')

parser.add_argument('-d', '--all-percentage-data-values', type=str, required=True, help='A range for the percentage of data used. a:0.1:10:10 creates ten evenly spaced steps between 0 percent and 100 percent, g:0.01:10:1:1.1 creates a geometric series from 1 percent to 100 percent with 10 steps and a growth parameter of 1.1')
parser.add_argument('parameter', metavar='parameter', nargs='*', help='Parameters to the algorithm in the form <param_name>:<int|float>-<a|g>:start:steps:end[:growth_param]')

parser.add_argument('-p', '--parallel', action='store_true', default=False, help='Paralellise data collection')
args = parser.parse_args()

if args.algorithm == 'rnd_forest':
    classifier = RandomForestClassifier
elif args.algorithm == 'log_reg':
    classifier = LogisticRegression
elif args.algorithm == 'svm':
    classifier = SVC
elif args.algorithm == 'naive_bayes':
    classifier = GaussianNB

if args.synthetic:
    datasets = [create_dataset(eval(args.synthetic))]
elif args.load_arff:
    datasets = [load_dataset({'name': args.load_arff})]
elif args.datasets_of_size:
    datasets = load_datasets(args.datasets_of_size)

all_percentage_data_values = convert_range_string(args.all_percentage_data_values)

parameters = {}
for param_str in args.parameter:
    t1 = param_str.split('-')
    t2 = t1[0].split(':')
    r = convert_range_string(t1[1])
    if t2[1]=='int':
        r = [int(round(v)) for v in r]
    parameters[t2[0]] = r

generate_data(args.algorithm, classifier, datasets, all_percentage_data_values, parameters, parallel=args.parallel)
