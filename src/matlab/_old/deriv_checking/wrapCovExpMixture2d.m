function [fX, dfX] = wrapCovExpMixture1d(hyp_value, hyp, hyp_index, x, z)
hyp(hyp_index) = hyp_value;

exp1 = {@covMask, {[1 0], @covExpMixture1d}};
exp2 = {@covMask, {[0 1], @covExpMixture1d}};
prod = {@covProd, {exp1, exp2}};
covfunc = {@covSum, {prod, @covConst}};

fX = feval(covfunc{:}, hyp, x, z);
dfX = feval(covfunc{:}, hyp, x, z, hyp_index);
end