#! /usr/bin/python
#-------------------------------------------------------------------------------
#
# Project: ngEO Browse Server <http://ngeo.eox.at>
# Authors: Fabian Schindler <fabian.schindler@eox.at>
#
#-------------------------------------------------------------------------------
# Copyright (C) 2015 European Space Agency
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies of this Software or works derived from this Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#-------------------------------------------------------------------------------

tmpl = """<?xml version="1.0" encoding="UTF-8"?>
<synchronizeConfiguration xmlns="http://ngeo.eo.esa.int/schema/configurationElements">
  <startRevision>0</startRevision>
  <endRevision>%d</endRevision>
  <removeConfiguration />
  <addConfiguration>
    <browseLayers>
      <browseLayer browseLayerId="TEST_LAYER_%04d">
        <browseType>TEST_TYPE_%04d</browseType>
        <title>TEST_TITLE_%04d</title>
        <description></description>
        <grid>urn:ogc:def:wkss:OGC:1.0:GoogleCRS84Quad</grid>
        <browseAccessPolicy>OPEN</browseAccessPolicy>
        <hostingBrowseServerName/>
        <relatedDatasetIds/>
        <containsVerticalCurtains>false</containsVerticalCurtains>
        <highestMapLevel>4</highestMapLevel>
        <lowestMapLevel>0</lowestMapLevel>
        <timeDimensionDefault>2010</timeDimensionDefault>
        <tileQueryLimit>100</tileQueryLimit>
      </browseLayer>
    </browseLayers>
  </addConfiguration>
</synchronizeConfiguration>"""

for i in range(2000):
    with open("configurations/config_%04d.xml" % i, "w") as f:
        f.write(tmpl % (i, i, i, i))
