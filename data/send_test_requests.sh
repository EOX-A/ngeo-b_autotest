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

echo "WMTS GetTile: Zoom in on one time interval"
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010-07-22T10:16:01Z--2012-10-02T09:20:00Z/WGS84/0/0/0.png" -o results/WMTS_TEST_SAR_0_0_0.png
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010-07-22T10:16:01Z--2012-10-02T09:20:00Z/WGS84/1/0/1.png" -o results/WMTS_TEST_SAR_1_0_1.png
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010-07-22T10:16:01Z--2012-10-02T09:20:00Z/WGS84/2/0/3.png" -o results/WMTS_TEST_SAR_2_0_3.png
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010-07-22T10:16:01Z--2012-10-02T09:20:00Z/WGS84/3/1/7.png" -o results/WMTS_TEST_SAR_3_1_7.png
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010-07-22T10:16:01Z--2012-10-02T09:20:00Z/WGS84/4/3/15.png" -o results/WMTS_TEST_SAR_4_3_15.png
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010-07-22T10:16:01Z--2012-10-02T09:20:00Z/WGS84/5/7/31.png" -o results/WMTS_TEST_SAR_5_7_31.png
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010-07-22T10:16:01Z--2012-10-02T09:20:00Z/WGS84/6/14/63.png" -o results/WMTS_TEST_SAR_6_14_63.jpg

echo "WMTS GetTile: Same tile different times to test merging in MapCache responses"
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010-07-25T10:22:31Z/WGS84/4/3/15.png" -o results/WMTS_TEST_SAR_4_3_15_1.png
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010-07-22T21:38:40Z/WGS84/4/3/15.png" -o results/WMTS_TEST_SAR_4_3_15_2.png
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010-07-22T10:16:01Z/WGS84/4/3/15.png" -o results/WMTS_TEST_SAR_4_3_15_3.png

echo "WMTS GetTile: Test merging in MapCache seeding of overlapping time intervals"
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010-08-07T10:13:27Z/WGS84/4/3/16.png" -o results/WMTS_TEST_SAR_seed_merge.png # Should show image with number 2 on top of a real image

echo "WMTS GetTile: Test merging/replacing of input images"
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010-09-07T10:13:27Z/WGS84/2/1/4.png" -o results/WMTS_TEST_SAR_input_merge.png # Should show image with number 2 on top of image with number 1
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010-08-07T10:13:27Z/WGS84/5/6/32.png" -o results/WMTS_TEST_SAR_input_replace.png # Should show image with number 2 and no image with number 1

echo "WMTS GetTile: Different layers"
curl -s "$url/c/wmts/1.0.0/TEST_OPTICAL/default/2000--2014/WGS84/2/0/4.png" -o results/WMTS_TEST_OPTICAL.png
curl -s "$url/c/wmts/1.0.0/TEST_ASA_WSM/default/2000--2014/WGS84/2/2/4.png" -o results/WMTS_TEST_ASA_WSM.png
curl -s "$url/c/wmts/1.0.0/TEST_MER_FRS/default/2000--2014/WGS84/2/1/4.png" -o results/WMTS_TEST_MER_FRS.png
curl -s "$url/c/wmts/1.0.0/TEST_GOOGLE_MERCATOR/default/2000--2014/GoogleMapsCompatible/2/1/2.png" -o results/WMTS_GOOGLE_MERCATOR.png

echo "WMS GetCapabilities"
curl -s "$url/c?service=wms&version=1.0.0&request=GetCapabilities" -o results/WMS_Capabilities_100.xml
curl -s "$url/c?service=wms&version=1.1.1&request=GetCapabilities" -o results/WMS_Capabilities_111.xml
curl -s "$url/c?service=wms&version=1.3.0&request=GetCapabilities" -o results/WMS_Capabilities_130.xml
curl -s "$url/c?service=wms&request=GetCapabilities" -o results/WMS_Capabilities_130_highest_1.xml
curl -s "$url/c?service=wms&version=2&request=GetCapabilities" -o results/WMS_Capabilities_130_highest_2.xml

echo "WMS GetMap: Zoom in"
curl -s "$url/c?service=wms&version=1.3.0&request=GetMap&bbox=-90,-180,90,180&width=800&height=400&crs=EPSG:4326&layers=TEST_SAR&time=2000/2014" -o results/WMS_TEST_SAR_0.png
curl -s "$url/c?service=wms&version=1.3.0&request=GetMap&bbox=0,-10,90,170&width=800&height=400&crs=EPSG:4326&layers=TEST_SAR&time=2000/2014" -o results/WMS_TEST_SAR_1.png
curl -s "$url/c?service=wms&version=1.3.0&request=GetMap&bbox=30,-10,75,80&width=800&height=400&crs=EPSG:4326&layers=TEST_SAR&time=2000/2014" -o results/WMS_TEST_SAR_2.png
curl -s "$url/c?service=wms&version=1.3.0&request=GetMap&bbox=40,-10,62.5,35&width=800&height=400&crs=EPSG:4326&layers=TEST_SAR&time=2000/2014" -o results/WMS_TEST_SAR_3.png
curl -s "$url/c?service=wms&version=1.3.0&request=GetMap&bbox=45,-10,56.25,12.5&width=800&height=400&crs=EPSG:4326&layers=TEST_SAR&time=2000/2014" -o results/WMS_TEST_SAR_4.png

echo "WMS GetMap: Same map different times"
curl -s "$url/c?service=wms&version=1.3.0&request=GetMap&bbox=45,-10,56.25,12.5&width=800&height=400&crs=EPSG:4326&layers=TEST_SAR&time=2010-07-25T10:22:31Z" -o results/WMS_TEST_SAR_4_1.png
curl -s "$url/c?service=wms&version=1.3.0&request=GetMap&bbox=45,-10,56.25,12.5&width=800&height=400&crs=EPSG:4326&layers=TEST_SAR&time=2010-07-22T21:38:40Z" -o results/WMS_TEST_SAR_4_2.png
curl -s "$url/c?service=wms&version=1.3.0&request=GetMap&bbox=45,-10,56.25,12.5&width=800&height=400&crs=EPSG:4326&layers=TEST_SAR&time=2010-07-22T10:16:01Z" -o results/WMS_TEST_SAR_4_3.png
curl -s "$url/c?service=wms&version=1.3.0&request=GetMap&bbox=45,-10,56.25,12.5&width=800&height=400&crs=EPSG:4326&layers=TEST_SAR&time=2010-08-07T10:13:27Z" -o results/WMS_TEST_SAR_4_4.png

echo "WMS GetMap: Different versions"
curl -s "$url/c?service=wms&version=1.1.1&request=GetMap&bbox=-10,45,12.5,56.25&width=800&height=400&srs=EPSG:4326&layers=TEST_SAR&time=2000/2014" -o results/WMS_TEST_SAR_4_111.png
curl -s "$url/c?service=wms&version=1.3.0&request=GetMap&bbox=45,-10,56.25,12.5&width=800&height=400&crs=EPSG:4326&layers=TEST_SAR&time=2000/2014" -o results/WMS_TEST_SAR_4_130.png

echo "WMS GetMap: Different projections & formats"
curl -s "$url/c?service=wms&version=1.3.0&request=GetMap&bbox=-1000000,5500000,1000000,7500000&width=800&height=800&crs=EPSG:3857&layers=TEST_SAR&format=image/png&transparent=true" -o results/WMS_TEST_SAR_4_EPSG3857.png
curl -s "$url/c?service=wms&version=1.3.0&request=GetMap&bbox=-1000000,5500000,1000000,7500000&width=800&height=800&crs=EPSG:3857&layers=TEST_SAR&format=image/jpeg&transparent=true" -o results/WMS_TEST_SAR_4_EPSG3857.jpg
curl -s "$url/c?service=wms&version=1.3.0&request=GetMap&bbox=-1000000,5500000,1000000,7500000&width=800&height=800&crs=EPSG:3857&layers=TEST_SAR&format=image/tiff&transparent=true" -o results/WMS_TEST_SAR_4_EPSG3857.tiff

echo "Sending some invalid requests"
curl -s "$url/c/INVALID/1.0.0/TEST_SAR/default/2010-07-22T10:16:01Z--2012-10-02T09:20:00Z/WGS84/0/0/0.png" -o results/exception_wmts_invalid_service_empty_image.png

echo "Invalid WMTS requests"
curl -s "$url/c/wmts/INVALID/TEST_SAR/default/2010-07-22T10:16:01Z--2012-10-02T09:20:00Z/WGS84/0/0/0.png" -o results/exception_wmts_invalid_version_empty_image.png
curl -s "$url/c/wmts/1.0.0/INVALID/default/2010-07-22T10:16:01Z--2012-10-02T09:20:00Z/WGS84/0/0/0.png" -o results/exception_wmts_invalid_layer_empty_image.png
curl -s "$url/c/wmts/1.0.0/TEST_SAR/INVALID/2010-07-22T10:16:01Z--2012-10-02T09:20:00Z/WGS84/0/0/0.png" -o results/exception_wmts_invalid_style_empty_image.png
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/INVALID/WGS84/0/0/0.png" -o results/exception_wmts_invalid_time_empty_image.png
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010-07-22T10:16:01Z--2012-10-02T09:20:00Z/INVALID/0/0/0.png" -o results/exception_wmts_invalid_tilematrixset_empty_image.png
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010-07-22T10:16:01Z--2012-10-02T09:20:00Z/WGS84/INVALID/0/0.png" -o results/exception_wmts_invalid_tilematrix_empty_image.png
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010-07-22T10:16:01Z--2012-10-02T09:20:00Z/WGS84/0/INVALID/0.png" -o results/exception_wmts_invalid_tilerow_empty_image.png
curl -s "$url/c/wmts/1.0.0/TEST_SAR/default/2010-07-22T10:16:01Z--2012-10-02T09:20:00Z/WGS84/0/0/INVALID.png" -o results/exception_wmts_invalid_tilecol_empty_image.png

echo "Invalid WMS requests"
curl -s "$url/c?service=wms&version=INVALID&request=GetCapabilities" -o results/exception_wms_invalid_version.xml
curl -s "$url/c?service=wms&version=1.3.0&request=INVALID" -o results/exception_wms_invalid_request.xml
curl -s "$url/c?service=wms&version=1.3.0&request=GetMap&bbox=INVALID&width=800&height=400&crs=EPSG:4326&layers=TEST_SAR&time=2000-01-01T00:00:00Z/2014-12-31T23:59:59Z&format=image/png" -o results/exception_wms_invalid_bbox.xml
curl -s "$url/c?service=wms&version=1.3.0&request=GetMap&bbox=45,-10,56.25,12.5&width=INVALID&height=400&crs=EPSG:4326&layers=TEST_SAR&time=2000-01-01T00:00:00Z/2014-12-31T23:59:59Z&format=image/png" -o results/exception_wms_invalid_width.xml
curl -s "$url/c?service=wms&version=1.3.0&request=GetMap&bbox=45,-10,56.25,12.5&width=800&height=INVALID&crs=EPSG:4326&layers=TEST_SAR&time=2000-01-01T00:00:00Z/2014-12-31T23:59:59Z&format=image/png" -o results/exception_wms_invalid_height.xml
curl -s "$url/c?service=wms&version=1.3.0&request=GetMap&bbox=45,-10,56.25,12.5&width=800&height=400&crs=EPSG:INVALID&layers=TEST_SAR&time=2000-01-01T00:00:00Z/2014-12-31T23:59:59Z&format=image/png" -o results/exception_wms_invalid_crs.xml
curl -s "$url/c?service=wms&version=1.3.0&request=GetMap&bbox=45,-10,56.25,12.5&width=800&height=400&crs=EPSG:4326&layers=INVALID&time=2000-01-01T00:00:00Z/2014-12-31T23:59:59Z&format=image/png" -o results/exception_wms_invalid_layer.xml
curl -s "$url/c?service=wms&version=1.3.0&request=GetMap&bbox=45,-10,56.25,12.5&width=800&height=400&crs=EPSG:4326&layers=TEST_SAR&time=INVALID&format=image/png" -o results/exception_wms_invalid_time_empty_image.png
