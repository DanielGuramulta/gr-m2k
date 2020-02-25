/* -*- c++ -*- */

#define M2K_API

%include "gnuradio.i"
%include "stdint.i"


%{
#include "m2k/analog_in_converter.h"
#include "m2k/analog_in_source.h"
#include "m2k/analog_out_converter.h"
#include "m2k/analog_out_sink.h"
%}

#ifdef GR_DIGITAL
#endif

%include "m2k/analog_in_converter.h"
%include "m2k/analog_in_source.h"
%include "m2k/analog_out_converter.h"
%include "m2k/analog_out_sink.h"

#ifdef GR_DIGITAL
#endif

GR_SWIG_BLOCK_MAGIC2(m2k, analog_in_converter);
GR_SWIG_BLOCK_MAGIC2(m2k, analog_in_source);
GR_SWIG_BLOCK_MAGIC2(m2k, analog_out_converter);
GR_SWIG_BLOCK_MAGIC2(m2k, analog_out_sink);

#ifdef GR_DIGITAL
#endif
