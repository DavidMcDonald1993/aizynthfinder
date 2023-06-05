#!/bin/bash
source /venv/bin/activate
exec "python" "/aizynthfinder/interfaces/aizynthcli.py" "$@"