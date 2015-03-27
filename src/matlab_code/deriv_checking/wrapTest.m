function [fX, dfX] = wrapTest(hyp_value, hyp, hyp_index, x, z)
hyp(hyp_index) = hyp_value;

fX = feval(@covTest, hyp, x, z);
dfX = feval(@covTest, hyp, x, z, hyp_index);
end