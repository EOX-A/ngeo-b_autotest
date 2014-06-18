#!/bin/sh
#-------------------------------------------------------------------------------
#
# Project: ngEO Browse Server <http://ngeo.eox.at>
# Authors: Stephan Meissl <stephan.meissl@eox.at>
#          Fabian Schindler <fabian.schindler@eox.at>
#
#-------------------------------------------------------------------------------
# Copyright (C) 2012 EOX IT Services GmbH
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

# About:
# =====
# This script sends test requests to an ngEO Browse Server instance via
# HTTP GET.
# Make sure to run against an instance with loaded test data e.g. by using
# the "load_test_data.sh" script.

# Running:
# =======
# ./send_test_requests.sh [URL]

################################################################################
# Usually there should be no need to change anything below.                    #
################################################################################

url=$1

[ "$1" ] || url="http://localhost:3080"

echo "Sending test requests to: $url"

echo "WMTS GetCapabilities"
curl -s "$url/c/wmts/1.0.0/WMTSCapabilities.xml" -o results/WMTSCapabilities.xml

echo "WMTS GetTile: Zoom in"
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010/WGS84/0/0/0.png" -o results/WMTS_TEST_SAR_0_0_0.png
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010/WGS84/1/0/1.png" -o results/WMTS_TEST_SAR_1_0_1.png
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010/WGS84/2/0/3.png" -o results/WMTS_TEST_SAR_2_0_3.png
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010/WGS84/3/1/7.png" -o results/WMTS_TEST_SAR_3_1_7.png
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010/WGS84/4/3/15.png" -o results/WMTS_TEST_SAR_4_3_15.png
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010/WGS84/5/7/31.png" -o results/WMTS_TEST_SAR_5_7_31.png
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010/WGS84/6/14/63.png" -o results/WMTS_TEST_SAR_6_14_63.jpg

echo "WMTS GetTile: Same tile different times"
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010-07-25T10:22:31Z/WGS84/4/3/15.png" -o results/WMTS_TEST_SAR_4_3_15_1.png
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010-07-22T21:38:40Z/WGS84/4/3/15.png" -o results/WMTS_TEST_SAR_4_3_15_2.png
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010-07-22T10:16:01Z/WGS84/4/3/15.png" -o results/WMTS_TEST_SAR_4_3_15_3.png

echo "WMS GetCapabilities"
curl -s "$url/c?service=wms&request=GetCapabilities" -o results/WMS_Capabilities_111.xml
curl -s "$url/c?service=wms&version=1.3.0&request=GetCapabilities" -o results/WMS_Capabilities_130.xml

echo "WMS GetMap: Zoom in"

echo "WMS GetMap: Same map different times"

echo "WMS GetMap: Different formats"
echo "WMS GetMap: Different projections"

echo "Invalid requests"
