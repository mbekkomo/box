#!/usr/bin/env -S awk -f

function cmd(c)
{
    output = "";
    while ((c|getline o) > 0)
        output = output o "\n";
    close(c);
    return output;
}

/^#@([-_[:alnum:]]+) ?(.*)/ \
{
    sub(/^#@/, "");
    print cmd("bash scripts/amalg.sh " $0);
    next;
} 
{
    print;
}
