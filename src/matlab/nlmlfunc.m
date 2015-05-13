function [nlml] = nlmlfunc(hyp_vec, meanfunc, covfunc, likfunc, xx, yy)

try
    nlml = gp(hyps_vec_to_struct(hyp_vec), @infExact, meanfunc, covfunc, likfunc, xx, yy);
catch
    nlml = Inf;
end

end

