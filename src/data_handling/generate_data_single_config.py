from csv import writer
from generate_data_for_config import generate_data_for_config
from sklearn.cross_validation import KFold
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.naive_bayes import GaussianNB
from datasets import load_datasets, load_dataset, create_dataset
from argparse import ArgumentParser

parser = ArgumentParser(description='Collect data')
parser.add_argument('-a', '--algorithm', type=str, required=True, default='rnd_forest', help='The learning algorithm, one of [rnd_forest, log_reg, svm, naive_bayes]')

group = parser.add_mutually_exclusive_group(required=True)
group.add_argument('-s', '--synthetic', type=str, help='Create a synthetic dataset with the given parameters')
group.add_argument('-l', '--load-arff', type=str, help='Load dataset from arff file with the given name')

parser.add_argument('-d', '--percentage-data', type=float, required=True, help='The percentage of data used')

parser.add_argument('parameter', metavar='parameter', nargs='*', help='Parameters to the algorithm in the form <param_name>:<int|float>:<number>')

# TODO add option to select scoring algorithm
# TODO add option to set # folds
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

kf = KFold(dataset['n_samples'], 10, shuffle=True, random_state=42)

param_values, percentage_data, elapsed_time, avg_score = generate_data_for_config(dataset, classifier, param_names, param_values, args.percentage_data, kf)

print('Time: {}'.format(elapsed_time))
print('Score: {}'.format(avg_score))
