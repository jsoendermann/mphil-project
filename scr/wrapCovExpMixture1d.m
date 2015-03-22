function [fX, dfX] = wrapCovExpMixture1d(hyp_value, hyp, hyp_index, x, z)
hyp(hyp_index) = hyp_value;

fX = feval(@covExpMixture1d, hyp, x, z);
dfX = feval(@covExpMixture1d, hyp, x, z, hyp_index);
end