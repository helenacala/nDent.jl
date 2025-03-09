module nDent


const PIPE = :|>
const UND  = :_    # underscore
const PUSH = :push
const JOIN = :join

function replace(symbol_in :: Symbol, value)
     if (symbol_in === UND) value else symbol_in end
end


function replace(expression :: Expr, value)
    exp_copy = copy(expression)
    exp_args = exp_copy.args
    
    # Check that we need to pipe
    if exp_args[1] === PIPE
        # We will evaluate the left hand side, and pass it onto the right
        left_eval = replace(exp_args[2], value)
        return replace(exp_args[3], left_eval)
    else
        # If there is no pipe, lets evaluate both the left and the right with the same
        # repalace value
        mapped_args = map(param -> replace(param, value), exp_args)
        exp_copy.args = mapped_args
        return exp_copy
    end
end


function replace(literal :: Any, _) 
    literal
end
end
