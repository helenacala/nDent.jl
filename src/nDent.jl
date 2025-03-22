module nDent

using DataStructures
export @nDent

stack = Stack{Any}()

const PIPE = :|>
const UND  = :_
const PUSH = :push
const POP = :pop
const JOIN = :join

macro nDent(value, expression)
    empty!(stack)
    push!(stack, value)
    for i in expression.args
        if i isa Expr
            value = eval(replace(i, value))
            push!(stack, value)
        end             
    end
    return esc(value)
end

function replace(literal :: Any,_ )
    return literal
end

function replace(literal :: QuoteNode, _)
    if literal.value == POP
        return pop!(stack)
    end
end 

function replace(symbol_in :: Symbol, value)
    if (symbol_in === UND)
        return value
    else
        return symbol_in
    end
end

function replace(expression :: Expr, value)
    exp_copy = copy(expression)
    exp_args = exp_copy.args

    # Check that we need to pipe
    if exp_args[1] === PIPE
        # Evaluate the left-hand side, and pass it to the right
        left_eval = replace(exp_args[2], value)
        return replace(exp_args[3], left_eval)
    else
        # If there is no pipe, evaluate both left and right with the same value
        mapped_args = map(param -> replace(param, value), exp_args)
        exp_copy.args = mapped_args
        return exp_copy
    end
end
end  # Closing module nDent
