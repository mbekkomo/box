#!/usr/bin/env bash

task.amalg()
{
  awk -f ./scripts/amalg.awk < main.sh > box
}
