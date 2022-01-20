Input files to generate GROMACS input (tpr files) and run permeability calculations as used in Lundborg et al.
Refined Predictions of Skin Permeability Using Molecular Dynamics Simulation and the Accelerated Weight Histogram Method.

The input files are generate by running
./setup.sh [permeant]

where [permeant] is chosen from the list permeants used in the publication (with parameters and input coordinates in the permeants/ directory):
1-decanol
benzene
caffeine
codeine
diclofenac
dmso
estradiol
ethanol
hydromorphone
ibuprofen
lidocaine
naproxen
nicotine
octanol
paracetamol
salicylic_acid
testosterone
toluene
urea
water

Separate directories are created for each permeant. These directories, in turn, contain 24 subdirectories (by default) that are used for the communicating AWH walkers when running GROMACS, e.g.:
mpirun -np 24 gmx_mpi mdrun -multidir 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 -cpi

It is recommended to generate the input, and run the simulations, with a version of GROMACS able to symmetrize AWH sampling, such as:
https://gitlab.com/gromacs/gromacs/-/tree/2021-awhsymm-fepsimd-fixes-awhcorrblocks
Otherwise it is possible to use an MDP file that is not using symmetric sampling by setting
USE_SYMMETRIC_SAMPLING=False
in setup.sh.

If more than one set of simulations, per permeant, is of interest, just change:
PROJECTNAME=${1}_permeability
to, e.g.:
PROJECTNAME=${1}_permeability_2
in setup.sh. For comparison, 4 to 6 sets per permeant were run in the paper (see above).
