#!/bin/bash
source ~/install/gromacs_2021_symm_128awhblocks_build/install/bin/GMXRC.bash

if [ $# -lt 1 ]; then
    echo "Usage:"
    echo "setup_runs_awh_fep.sh moleculename systemname nConfs"
    exit 1
fi
PROJECTNAME=${1}_permeability
ORIGDIR=`pwd`
ORIGTOPFILE=$ORIGDIR/topol.top
NCONFS=24
MOLECULENAME=${1}
LIG_COORDFILE=$ORIGDIR/permeants/${1}.gro
SYS_COORDFILE=$ORIGDIR/lipid_system.gro
# Set this to False (or anything except True) if not running a GROMACS version that can handle symmetric AWH sampling.
USE_SYMMETRIC_SAMPLING=True
if [ "$USE_SYMMETRIC_SAMPLING" = "True" ]
then
  MDPFILE=$ORIGDIR/grompp.mdp
else
  MDPFILE=$ORIGDIR/grompp_nonsymm.mdp
fi

LIG_ITPFILE=$ORIGDIR/permeants/${1}.itp
TOP_LIG_ITP=${1}.itp

if [ ! -d $PROJECTNAME ]
then
  mkdir $PROJECTNAME || exit
fi
cd $PROJECTNAME || exit
cp $MDPFILE grompp.mdp
sed -i "s/LIG/$MOLECULENAME/" grompp.mdp
cp $ORIGTOPFILE topol.top
~/install/mdscripts/add_include_to_top.py topol.top $TOP_LIG_ITP 2
sed -i 's/\"forcefield\//\"..\/forcefield\//g' topol.top
echo "$MOLECULENAME        1" >> topol.top
cp $LIG_ITPFILE .

for ((i=0; i<$NCONFS; i++))
do
  if [ ! -d $i ]
  then
    mkdir $i
  fi
  cd $i
  if [ ! -f conf_${i}.gro ]
  then
    gmx insert-molecules -f $SYS_COORDFILE -ci $LIG_COORDFILE -o conf_${i}.gro -nmol 1 -scale 0.10 -try 10000
  fi
  cd ..
done
printf "r LIG\nq\n"|gmx make_ndx -f 0/conf_0.gro -o index.ndx
cat $ORIGDIR/index.ndx >> index.ndx
sed -i "s/LIG/$MOLECULENAME/" index.ndx

for ((i=0; i<$NCONFS; i++))
do
  cd $i
  gmx grompp -f ../grompp.mdp -p ../topol.top -c conf_$i.gro -n ../index.ndx -maxwarn 1
  cp ../../awhinit.xvg awhinit.xvg
  cd ..
done
