function [nlml] = nlmlfunc(hyp_vec, meanfunc, covfunc, likfunc, xx, yy)

% This is a small wrapper that uses GPML's gp function to compute the marginal likelihood

try
    nlml = gp(hyps_vec_to_struct(hyp_vec), @infExact, meanfunc, covfunc, likfunc, xx, yy);
catch
    nlml = Inf;
end
end
