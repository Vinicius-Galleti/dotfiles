#!/usr/bin/env bash
date +"%u %d %m %Y" | awk '{
  d[1]="SEGUNDA"; d[2]="TERÇA"; d[3]="QUARTA"; d[4]="QUINTA"; d[5]="SEXTA"; d[6]="SÁBADO"; d[7]="DOMINGO";
  m[1]="JANEIRO"; m[2]="FEVEREIRO"; m[3]="MARÇO"; m[4]="ABRIL"; m[5]="MAIO"; m[6]="JUNHO";
  m[7]="JULHO"; m[8]="AGOSTO"; m[9]="SETEMBRO"; m[10]="OUTUBRO"; m[11]="NOVEMBRO"; m[12]="DEZEMBRO";
  printf "%s · %d %s %s", d[$1], $2+0, m[$3+0], $4
}'
