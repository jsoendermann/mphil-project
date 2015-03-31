from scipy.io.arff import loadarff
import numpy as np
from glob import glob
from os.path import join, basename
from json import loads
from sklearn.feature_extraction import DictVectorizer
from sklearn.datasets import make_classification
from random import randint, shuffle

DATASETS_DIR = '../../data/raw_arffs/'

with open('datasets_data.json') as datasets_data_file:  
    datasets_data = loads(datasets_data_file.read())


def load_datasets(datasets="small"):
    for dataset_data in datasets_data:
        if dataset_data['sparse'] or dataset_data['hasMissingData']:
            continue
        if isinstance(datasets, list) and dataset_data['name'] in datasets:
            yield load_dataset(dataset_data)
        elif datasets == "all" or datasets == dataset_data['size']:
            yield load_dataset(dataset_data)


def create_dataset(data_args={}):
    # TODO find a better solution to this
    id_ = randint(10000, 19999)

    X, y = make_classification(**data_args)
    permutation = range(len(X))
    shuffle(permutation)
    X = X[permutation]
    y = y[permutation]

    if 'n_classes' in data_args and data_args['n_classes'] != 2:
        binary = False
    else:
        binary = True
        
    return {'id': id_, 'name': 'synth___{0}'.format('__'.join([k+'-'+str(v) for k,v in data_args.items()])), 
            'size': 'custom', 'sparse': False, 'hasMissingData': False, 
            'X': X, 'y': y, 'n_samples': len(X), 'binary': binary}

def convert_y_values_to_ints(y):
    return y

def load_dataset(dataset_data):
    name = dataset_data['name']

    print('Loading {0}...'.format(name))

    
    arff_file_path = join(DATASETS_DIR, name+'/'+name+'.arff')

    raw_data, metadata = loadarff(open(arff_file_path))
    list_data = raw_data.tolist()

    # TODO this is done to avoid the problem of only having one class in the data when taking subsets
    # find a more robust solution
    shuffle(list_data)

    attribute_names = list(metadata)
    
    normal_attributes = attribute_names[:len(attribute_names)-1]
    class_attribute = attribute_names[len(attribute_names)-1]

    X, y = [], []

    for sample in list_data:
        normal_features = sample[:len(sample)-1]
        class_feature = sample[len(sample)-1]

        X.append(dict(zip(normal_attributes, normal_features)))
        y.append({class_attribute: class_feature})

    vec_X = DictVectorizer()
    X_sk = vec_X.fit_transform(X).toarray()
    y_sk = convert_y_values_to_ints(np.array([yv[class_attribute] for yv in y]))

    ret = dataset_data.copy()
    ret.update({'X': X_sk, 'y': y_sk, 'binary': False, # TODO check if the data is really binary and set this to true if yes
        'X_feature_names': vec_X.get_feature_names(), 'n_samples': len(list_data)})

    return ret
