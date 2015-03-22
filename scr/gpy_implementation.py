#!/usr/bin/env python

from GPy import *
from GPy.kern import Kern
import numpy as np
import matplotlib.pyplot as plt

class ExpMixture1d(Kern):
    def __init__(self, sf, psi, xi):
        super(ExpMixture1d, self).__init__(input_dim=1, active_dims=None, name='exp_mixture_1d')
        self.sf2 = sf**2
        self.psi = psi
        self.xi = xi

    def K(self, X, X2):
        X2 = X2.T

        x_mat = np.tile(X, X2.shape[1])
        z_mat = np.tile(X2, (X.shape[0], 1))
        x_plus_z = np.add(x_mat, z_mat)

        nom = (1/(self.psi*self.xi)) ** (1/self.xi)
        denom = (x_plus_z + 1/(self.psi*self.xi)) ** (1/self.xi)
        return nom / denom

_ = ExpMixture1d(1, 1.0, 1).plot(ax=plt.gca(), plot_limits=(0,10))
_ = ExpMixture1d(1, 1.5, 1).plot(ax=plt.gca(), plot_limits=(0,10))
_ = ExpMixture1d(1, 2.0, 1).plot(ax=plt.gca(), plot_limits=(0,10))

plt.show(block=True)

