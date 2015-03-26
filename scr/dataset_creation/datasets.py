from scipy.io.arff import loadarff
import numpy as np
from glob import glob
from os.path import join, basename

dataset_ids = {}
with open('../../data/dataset_list.txt', 'r') as f:
    for i, line in enumerate(f):
        dataset_ids[line.rstrip()] = i

def load_datasets():
    for ds_dirname in glob('/Users/jan/mphil_project_datasets/medium_large/*'):
        yield load_dataset(basename(ds_dirname), ds_dirname)

def load_dataset(name, dirname):
    print('Loading {}...'.format(name))
    fp_train = join(dirname, 'train.arff')
    # TODO also use test data, maybe merge the two?
    # fp_test = join(dirname, 'test.arff')

    raw_data, _ = loadarff(open(fp_train))
    list_data = raw_data.tolist()

    X, y = [], []
    for sample in list_data:
        X.append(sample[:len(sample)-1])
        y.append(sample[len(sample)-1])

    return {'name': name, 'id': dataset_ids[name], 'X': np.array(X), 'y': np.array(y)}
