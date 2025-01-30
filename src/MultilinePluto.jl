module MultilinePluto

using Pluto: Pluto, run
export Pluto

function __init__()
    # Replace Pluto's `parse_custom` with a copy of it that does not throw an error
    # when a cell has multiple expressions in it
    @eval Pluto begin
        # copied from https://github.com/fonsp/Pluto.jl/blob/main/src/analysis/Parse.jl
        # except with step 1. of `parse_custom` modified to not throw errors when a cell
        # contains multiple expressions
        function parse_custom(notebook::Notebook, cell::Cell)::Expr
            filename = pluto_filename(notebook, cell)
            raw = Base.parse_input_line(cell.code, filename=filename)
            
            # 2.
            filename = pluto_filename(notebook, cell)

            if !can_insert_filename
                fix_linenumbernodes!(raw, filename)
            end

            # 3.
            topleveled = if ExpressionExplorer.is_toplevel_expr(raw)
                raw
            else
                Expr(:toplevel, LineNumberNode(1, Symbol(filename)), raw)
            end

            # 4.
            Expr(topleveled.head, topleveled.args[1], preprocess_expr(topleveled.args[2]))
        end
    end
end

end # module MultilinePluto
