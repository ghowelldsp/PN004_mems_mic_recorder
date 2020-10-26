onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib mmcm_clock_opt

do {wave.do}

view wave
view structure
view signals

do {mmcm_clock.udo}

run -all

quit -force
