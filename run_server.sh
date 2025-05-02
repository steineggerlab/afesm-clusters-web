#!/bin/sh
eval "$(/home/mmirdit/miniforge3/condabin/conda shell.bash hook)"
conda activate node 2>&1 >/dev/null
#npm run server
node ./src/server/index.mjs
