from csv import writer
from generate_data_for_config import generate_datum
from sklearn.cross_validation import KFold
from utils import name_to_classifier_object
from datasets import load_datasets, load_dataset, create_dataset
from argparse import ArgumentParser

# Argument parser
parser = ArgumentParser(description='Collect data')
parser.add_argument('-a', '--algorithm', type=str, required=True, default='rnd_forest', help='The learning algorithm, one of [rnd_forest, log_reg, svm, naive_bayes]')
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('-s', '--synthetic', type=str, help='Create a synthetic dataset with the given parameters')
group.add_argument('-l', '--load-arff', type=str, help='Load dataset from arff file with the given name')
parser.add_argument('-d', '--percentage-data', type=float, required=True, help='The percentage of data used')
parser.add_argument('parameter', metavar='parameter', nargs='*', help='Parameters to the algorithm in the form <param_name>:<int|float>:<number>')

args = parser.parse_args()

classifier = name_to_classifier_object(args.algorithm)

if args.synthetic:
    dataset = create_dataset(eval(args.synthetic))
elif args.load_arff:
    dataset = load_dataset({'name': args.load_arff})

param_names = []
param_values = []

for param_str in args.parameter:
    name, type_, value_str = param_str.split(':')
    param_names.append(name)
    if type_ == 'int':
        param_values.append(int(value_str))
    elif type_ == 'float':
        param_values.append(float(value_str))

elapsed_time, avg_score = generate_datum(dataset, classifier, args.percentage_data, dict(zip(param_names, param_values)))

print('Time: {}'.format(elapsed_time))
print('Score: {}'.format(avg_score))
