set terminal pdfcairo enhanced font "Gill Sans, 20" linewidth 4 rounded dashed
# Linux/Windows users should download the 'Clear Sans' font and
#  use the following line.
# set terminal pdfcairo enhanced font "Clear Sans, 20" linewidth 4 rounded dashed

set style line 80 lc rgb "#808080" lw 0.5
# Border: 3 (X & Y axes)
set border 0 back ls 80

set style line 81 lc rgb "#909090" lt 1 lw 0.3 dt 4
set style line 82 lc rgb "#AEAEAE" lt 1 lw 0.2 dt 3
set grid mxtics xtics back ls 81, ls 82

# Based on colorbrewer2.org's Set1 palette.
set style line 1 lt 1 lc rgb "#e41a1c" lw 1.0
set style line 2 lt 1 lc rgb "#377eb8" lw 1.0
set style line 3 lt 1 lc rgb "#4daf4a" lw 1.0
set style line 4 lt 1 lc rgb "#984ea3" lw 1.0
set style line 5 lt 1 lc rgb "#ff7f00" lw 1.0
set style line 6 lt 1 lc rgb "#a65628" lw 1.0
set style line 9 lt 1 lc rgb "#202020" lw 1.0


set xtics border in scale 1,0.5 nomirror norotate autojustify
set ytics border in scale 1,0.5 nomirror norotate autojustify

set tics out
set xtics scale 0.05

set ytics nomirror

set key top right
set key samplen 0 spacing 1.2 font ",18"


# set boxwidth 1 absolute
set style fill solid 0.85 noborder


set xrange [0:X_MAX/12.0]
set xtics 0, 1
set mxtics 12


set noytics
# set ytics ("FAIL" 0, "PASS" 1) font ',14'
# set ytics format ""


set size 1,1
set origin 0,0

unset bmargin
unset lmargin
unset tmargin
unset rmargin

set lmargin at screen 0.1
set rmargin at screen 0.95


set output OUT_FILE
set multiplot layout 2,1

set size 1,0.3
set origin 0,0.6
set tmargin at screen 0.95
set bmargin at screen 0.7

set xtics format ""

set ylabel DS1
set noxlabel

plot IN_FILE u ($1/12):4  not w fillsteps ls 1 lw 0.5 dt 1


set size 1,0.3
set origin 0,0.3
set tmargin at screen 0.65
set bmargin at screen 0.4

set ylabel DS2

plot IN_FILE u ($1/12):7  not w fillsteps ls 2 lw 0.5 dt 1


set size 1,0.3
set origin 0,0
set tmargin at screen 0.35
set bmargin at screen 0.1

set xtics format "%.0f" font ',14'
set xtics offset 0, graph 0.12

set ylabel DS3
set xlabel "Time (in hour)" offset 0,1.5 font ',18'

plot IN_FILE u ($1/12):10 not w fillsteps ls 3 lw 0.5 dt 1

unset multiplot
unset output
