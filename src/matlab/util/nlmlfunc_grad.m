function [grad] = nlmlfunc_grad(hyp, meanfunc, covfunc, likfunc, xx, y)
[~,~,grad_struct] = feval(@infExact, hyp, {meanfunc}, covfunc, {likfunc}, xx, y);
grad = hyps_struct_to_vec(grad_struct);
end

