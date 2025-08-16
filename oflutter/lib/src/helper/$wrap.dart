// ignore_for_file: specify_nonobvious_property_types, file_names, gen entries.

import 'package:flutter/widgets.dart';
import 'package:oflutter/annotation.dart';

@GenerateBuildInWrap(methodName: 'asText', targetParameterName: 'data')
const text = Text.new;

@wrapBuildIn
const Set<Widget Function()> geometry = {Center.new, Align.new};
