export kcommand='create'

if [ "$1" == "create" ]; then
    export kcommand='create'
elif [ "$1" == "delete" ]; then
    export kcommand='delete'
elif [ "$1" == "apply" ]; then
    export kcommand='apply'
fi