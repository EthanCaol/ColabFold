#!/bin/bash -e

CURRENTPATH=`pwd`
COLABFOLDDIR="${CURRENTPATH}/localcolabfold"

mamba create -p "$COLABFOLDDIR/colabfold-conda" -c conda-forge -c bioconda \
    python=3.10 openmm==8.2.0 pdbfixer \
    kalign2=2.04 hhsuite=3.3.0 mmseqs2 -y
conda activate "$COLABFOLDDIR/colabfold-conda"

"$COLABFOLDDIR/colabfold-conda/bin/pip" install --no-warn-conflicts \
    "colabfold[alphafold-minus-jax] @ git+https://github.com/sokrypton/ColabFold"
"$COLABFOLDDIR/colabfold-conda/bin/pip" install "colabfold[alphafold]"
"$COLABFOLDDIR/colabfold-conda/bin/pip" install --upgrade "jax[cuda12]==0.5.3"
"$COLABFOLDDIR/colabfold-conda/bin/pip" install --upgrade tensorflow
"$COLABFOLDDIR/colabfold-conda/bin/pip" install silence_tensorflow


pushd "${COLABFOLDDIR}/colabfold-conda/lib/python3.10/site-packages/colabfold"
sed -i -e "s#from matplotlib import pyplot as plt#import matplotlib\nmatplotlib.use('Agg')\nimport matplotlib.pyplot as plt#g" plot.py
sed -i -e "s#appdirs.user_cache_dir(__package__ or \"colabfold\")#\"${COLABFOLDDIR}/colabfold\"#g" download.py
sed -i -e "s#from io import StringIO#from io import StringIO\nfrom silence_tensorflow import silence_tensorflow\nsilence_tensorflow()#g" batch.py
rm -rf __pycache__
popd

# Download weights
"$COLABFOLDDIR/colabfold-conda/bin/python3" -m colabfold.download
echo "alias colabfold_batch=\"${COLABFOLDDIR}/colabfold-conda/bin/colabfold_batch --disable-unified-memory\"" >> ~/.bashrc
echo "For more details, please run 'colabfold_batch --help'."
