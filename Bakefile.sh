#!/usr/bin/env bash

task.amalg()
{
  cd src ||:
  awk -v amalg_script=../scripts/amalg.sh -f ../scripts/amalg.awk < main.sh > ../bin/box
  chmod 755 ../bin/box
}
