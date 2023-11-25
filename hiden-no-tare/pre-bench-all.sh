#!/bin/bash
set -uex

ssh -n isucon13-final-1 pre-bench.sh &
ssh -n isucon13-final-2 pre-bench.sh &
ssh -n isucon13-final-3 pre-bench.sh &
wait