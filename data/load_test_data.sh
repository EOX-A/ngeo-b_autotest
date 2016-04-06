#!/bin/sh
#-------------------------------------------------------------------------------
#
# Project: ngEO Browse Server <http://ngeo.eox.at>
# Authors: Fabian Schindler <fabian.schindler@eox.at>
#          Marko Locher <marko.locher@eox.at>
#          Stephan Meissl <stephan.meissl@eox.at>
#
#-------------------------------------------------------------------------------
# Copyright (C) 2012 European Space Agency
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
# This script loads the demo/test data in an ngEO Browse Server instance via
# HTTP POST.

# Running:
# =======
# ./load_test_data.sh [URL]

################################################################################
# Usually there should be no need to change anything below.                    #
################################################################################

url=$1
upload=$2

[ "$1" ] || url="http://localhost:3080"

if [ "$2" ] ; then
    echo "Sending browse images to: $url"

    curl --digest -u test:eiNoo7ae -T reference_test_data/ASA_IM__0P_20100722_213840.jpg "$url"/store/
    curl --digest -u test:eiNoo7ae -T reference_test_data/ASA_IM__0P_20100731_103315.jpg "$url"/store/
    curl --digest -u test:eiNoo7ae -T reference_test_data/ASA_IM__0P_20100807_101327.jpg "$url"/store/
    curl --digest -u test:eiNoo7ae -T reference_test_data/ASA_IM__0P_20100807_101327_new.jpg "$url"/store/
    curl --digest -u test:eiNoo7ae -T reference_test_data/ASA_IM__0P_20100813_102453.jpg "$url"/store/
    curl --digest -u test:eiNoo7ae -T reference_test_data/ASA_WS__0P_20100719_101023.jpg "$url"/store/
    curl --digest -u test:eiNoo7ae -T reference_test_data/ASA_WS__0P_20100722_101601.jpg "$url"/store/
    curl --digest -u test:eiNoo7ae -T reference_test_data/ASA_WS__0P_20100725_102231.jpg "$url"/store/
    curl --digest -u test:eiNoo7ae -T reference_test_data/ATS_TOA_1P_20100719_105257.jpg "$url"/store/
    curl --digest -u test:eiNoo7ae -T reference_test_data/ATS_TOA_1P_20100719_213253.jpg "$url"/store/
    curl --digest -u test:eiNoo7ae -T reference_test_data/ATS_TOA_1P_20100722_101606.jpg "$url"/store/

    curl --digest -u test:eiNoo7ae -T test_data/ASA_WSM_1PNDPA20050331_075939_000000552036_00035_16121_0775.tif "$url"/store/
    curl --digest -u test:eiNoo7ae -T test_data/MER_FRS_1PNPDE20060822_092058_000001972050_00308_23408_0077_RGB_reduced_nogeo.tif "$url"/store/
    curl --digest -u test:eiNoo7ae -T test_data/MER_FRS_1PNPDE20060822_092058_000001972050_00308_23408_0077_RGB_reduced.tif "$url"/store/

    curl --digest -u test:eiNoo7ae -T aiv_test_data/NGEO-FEED-VTC-0040.jpg "$url"/store/

    curl --digest -u test:eiNoo7ae -T feed_test_data/quick-look.png "$url"/store/

    # replace/merge tests
    curl --digest -u test:eiNoo7ae -T input_merge_test_data/to_be_replaced.jpg "$url"/store/
    curl --digest -u test:eiNoo7ae -T input_merge_test_data/replacing.jpg "$url"/store/

    curl --digest -u test:eiNoo7ae -T input_merge_test_data/to_be_merged.jpg "$url"/store/
    curl --digest -u test:eiNoo7ae -T input_merge_test_data/merging.jpg "$url"/store/

    # regularGrid clipping
    curl --digest -u test:eiNoo7ae -T regular_grid_clipping/ID_quick-look_1.png "$url"/store/
    curl --digest -u test:eiNoo7ae -T regular_grid_clipping/ID_quick-look_2.png "$url"/store/

    # dateline crossing
    curl --digest -u test:eiNoo7ae -T test_data/_20120101T022322540-20120101T030036350_D_T-AA0B.jpg "$url"/store/
    curl --digest -u test:eiNoo7ae -T test_data/BrowseReport_crosses_dateline2.png "$url"/store/
fi


echo "Sending browse reports to: $url"

curl -d @reference_test_data/browseReport_ASA_IM__0P_20100722_213840.xml "$url"/browse/ingest
curl -d @reference_test_data/browseReport_ASA_IM__0P_20100731_103315.xml "$url"/browse/ingest
curl -d @reference_test_data/browseReport_ASA_IM__0P_20100807_101327.xml "$url"/browse/ingest
curl -d @reference_test_data/browseReport_ASA_IM__0P_20100807_101327_new.xml "$url"/browse/ingest
curl -d @reference_test_data/browseReport_ASA_IM__0P_20100813_102453.xml "$url"/browse/ingest
curl -d @reference_test_data/browseReport_ASA_WS__0P_20100719_101023_group.xml "$url"/browse/ingest
curl -d @reference_test_data/browseReport_ATS_TOA_1P_20100719_105257.xml "$url"/browse/ingest
curl -d @reference_test_data/browseReport_ATS_TOA_1P_20100719_213253.xml "$url"/browse/ingest
curl -d @reference_test_data/browseReport_ATS_TOA_1P_20100722_101606.xml "$url"/browse/ingest

curl -d @test_data/ASA_WSM_1PNDPA20050331_075939_000000552036_00035_16121_0775.xml "$url"/browse/ingest
curl -d @test_data/MER_FRS_1PNPDE20060822_092058_000001972050_00308_23408_0077_RGB_reduced_nogeo.xml "$url"/browse/ingest
curl -d @test_data/MER_FRS_1PNPDE20060822_092058_000001972050_00308_23408_0077_RGB_reduced.xml "$url"/browse/ingest

curl -d @aiv_test_data/BrowseReport.xml "$url"/browse/ingest

curl -d @feed_test_data/BrowseReport.xml "$url"/browse/ingest

curl --digest -u test:eiNoo7ae -T test_data/MER_FRS_1PNPDE20060816_090929_000001972050_00222_23322_0058_uint16_reduced_compressed.tif "$url"/store/
curl -d @test_data/MER_FRS_1PNPDE20060816_090929_000001972050_00222_23322_0058_uint16_reduced_compressed_NO_BANDS.xml "$url"/browse/ingest
curl --digest -u test:eiNoo7ae -T test_data/MER_FRS_1PNPDE20060816_090929_000001972050_00222_23322_0058_uint16_reduced_compressed.tif "$url"/store/
curl -d @test_data/MER_FRS_1PNPDE20060816_090929_000001972050_00222_23322_0058_uint16_reduced_compressed.xml "$url"/browse/ingest
curl --digest -u test:eiNoo7ae -T test_data/MER_FRS_1PNPDE20060822_092058_000001972050_00308_23408_0077_RGB_reduced.tif "$url"/store/
curl -d @test_data/MER_FRS_1PNPDE20060822_092058_000001972050_00308_23408_0077_RGB_reduced_GOOGLE_MERCATOR.xml "$url"/browse/ingest

# replace/merge tests
curl -d @input_merge_test_data/to_be_replaced.xml "$url"/browse/ingest
curl -d @input_merge_test_data/replacing.xml "$url"/browse/ingest

curl -d @input_merge_test_data/to_be_merged.xml "$url"/browse/ingest
curl -d @input_merge_test_data/merging.xml "$url"/browse/ingest

# regularGrid clipping
curl -d @regular_grid_clipping/1434370912775_BrowseServerIngest_1434370912587_input.xml "$url"/browse/ingest
curl -d @regular_grid_clipping/1434370922099_BrowseServerIngest_1434370922061_input.xml "$url"/browse/ingest

# dateline crossing
curl -d @test_data/BrowseReport_crosses_dateline.xml "$url"/browse/ingest
curl -d @test_data/BrowseReport_crosses_dateline2.xml "$url"/browse/ingest
