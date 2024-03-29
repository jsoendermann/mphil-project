from scipy.io.arff import loadarff
import numpy as np
from glob import glob
from os.path import join, dirname, realpath
from json import loads
from sklearn.feature_extraction import DictVectorizer
from sklearn.datasets import make_classification
from random import randint, shuffle

DATASETS_DIR = join(dirname(realpath(__file__)), '../../data/raw_arffs/')


# Read metadata
with open(join(dirname(realpath(__file__)), 'datasets_data.json')) as datasets_data_file:  
    datasets_data = loads(datasets_data_file.read())


# This loads all datasets of a certain size
def load_datasets(datasets="small"):
    for dataset_data in datasets_data:
        if dataset_data['sparse'] or dataset_data['hasMissingData']:
            continue
        if isinstance(datasets, list) and dataset_data['name'] in datasets:
            yield load_dataset(dataset_data)
        elif datasets == "all" or datasets == dataset_data['size']:
            yield load_dataset(dataset_data)


# Create a synthetic dataset. data_args contains the parameters to make_classification
def create_dataset(data_args={}):
    id_ = randint(10000, 19999)

    X, y = make_classification(**data_args)

    # Shuffle. This might not be necessary
    permutation = range(len(X))
    shuffle(permutation)
    X = X[permutation]
    y = y[permutation]

    # This is used to decide whether to use roc to measure score
    if 'n_classes' in data_args and data_args['n_classes'] != 2:
        binary = False
    else:
        binary = True
        
    # Return dict with data and metadata
    return {'id': id_, 'name': 'synth___{0}'.format('__'.join([k+'-'+str(v) for k,v in data_args.items()])), 
            'size': 'custom', 'sparse': False, 'hasMissingData': False, 
            'X': X, 'y': y, 'n_samples': len(X), 'binary': binary}


# Load dataset from arff file
def load_dataset(dataset_data):
    # Copy metadata
    name = dataset_data['name']
    ret = dataset_data.copy()
    for json_dataset_data in datasets_data:
        if json_dataset_data['name'] == name:
            ret.update(json_dataset_data)

    print('Loading {0}...'.format(name))
    
    arff_file_path = join(DATASETS_DIR, name+'/'+name+'.arff')

    # Load data and convert to list
    raw_data, metadata = loadarff(open(arff_file_path))
    list_data = raw_data.tolist()

    # Shuffle. Important to avoid having all samples in a fold be of the same class
    shuffle(list_data)

    attribute_names = list(metadata)
    normal_attributes = attribute_names[:len(attribute_names)-1]
    class_attribute = attribute_names[len(attribute_names)-1]

    # Convert from numpy array to lists
    X, y = [], []
    for sample in list_data:
        normal_features = sample[:len(sample)-1]
        class_feature = sample[len(sample)-1]

        X.append(dict(zip(normal_attributes, normal_features)))
        y.append({class_attribute: class_feature})

    # Convert all attributes to numeric
    vec_X = DictVectorizer()
    X_sk = vec_X.fit_transform(X).toarray()
    y_sk = np.array([yv[class_attribute] for yv in y])

    
    ret.update({'X': X_sk, 'y': y_sk, 'binary': False,
        'X_feature_names': vec_X.get_feature_names(), 'n_samples': len(list_data)})

    return ret
