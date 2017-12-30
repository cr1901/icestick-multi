project('multi', 'c')

yosys_bin = find_program('yosys')
arachne_bin = find_program('arachne-pnr')
icepack_bin = find_program('icepack')
iceprog_bin = find_program('iceprog')
icetime_bin = find_program('icetime')
icemulti_bin = find_program('icemulti')

pcffile = files('data/icestick.pcf')


bins = []
foreach image_no : ['1', '2', '4', '8']
  blif = custom_target('multi_blif_' + image_no,
    input : join_paths(meson.source_root(), 'rtl', 'multi.v'),
    output : 'multi' + image_no + '.blif',
    command : [yosys_bin, '-q', '-p', 'read_verilog -DMULTI_DIVIDER=' + image_no + ' @INPUT@', '-p', 'synth_ice40 -blif @OUTPUT@'],
  )

  asc = custom_target('multi_asc_' + image_no,
    input : blif,
    output : 'multi' + image_no + '.asc',
    command : [arachne_bin, '-q', '-d', '1k', '-p', pcffile, '@INPUT@', '-o', '@OUTPUT@'],
  )

  bins += custom_target('multi_bin_' + image_no,
    input : asc,
    output : 'multi' + image_no + '.bin',
    command : [icepack_bin, '@INPUT@', '@OUTPUT@'],
  )
endforeach


multi = custom_target('multi',
  input : bins,
  output : 'multi.bin',
  command : [icemulti_bin, '-p0', '-a10', '-o', '@OUTPUT@', '@INPUT@'],
  build_by_default : true
)


run_target('multi-time',
  command : [icetime_bin, '-tmd', 'hx1k', asc],
)


run_target('multi-upload',
  command : [iceprog_bin, multi]
)
