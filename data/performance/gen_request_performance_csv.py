#-------------------------------------------------------------------------------
#
# Project: ngEO Browse Server <http://ngeo.eox.at>
# Authors: Fabian Schindler <fabian.schindler@eox.at>
#
#-------------------------------------------------------------------------------
# Copyright (C) 2014 EOX IT Services GmbH
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

import csv
from os.path import join
from itertools import izip, product, tee
import argparse
from lxml import etree



def pairwise(iterable):
    "s -> (s0,s1), (s2,s3), (s4, s5), ..."
    a = iter(iterable)
    return izip(a, a)

def iterate_browses(csv_path, reportpath):
    ns = {"rep": "http://ngeo.eo.esa.int/schema/browseReport"}
    with open(csv_path) as f:
        reader = csv.reader(f)
        for row in reader:

            report_filename = row[0]
            if reportpath:
                report_filename = join(reportpath, report_filename)

            tree = etree.parse(report_filename)
            browse_type = tree.xpath("rep:browseType/text()", namespaces=ns)[0]
            starts = tree.xpath("rep:browse/rep:startTime/text()", namespaces=ns)
            ends = tree.xpath("rep:browse/rep:endTime/text()", namespaces=ns)

            if browse_type == "SAR_IM0_BP":
                browse_layer = "ESA.EECF.ERS_SAR_xS"
            elif browse_type == "SAR_IMM_BP":
                browse_layer = "ESA.EECF.ERS_SAR_xSM"
            else:
                browse_layer = None

            footprints = tree.xpath("rep:browse/rep:footprint/rep:coordList/text()", namespaces=ns)
            for start, end, footprint in izip(starts, ends, footprints):
                #print list(pairwise(map(float, footprint.split(" "))))
                y_coords, x_coords = zip(*list(pairwise(map(float, footprint.split(" ")))))
                extent = (
                    min(x_coords), min(y_coords),
                    max(x_coords), max(y_coords)
                )
                yield browse_layer, start, end, extent


request_template = (
    '/c/wmts/?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=%s'
    '&STYLE=default&TILEMATRIXSET=WGS84&FORMAT=image/png'
    '&TileMatrix=%d&TileRow=%d&TileCol=%d'
    '&time=%s/%s'
)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Request generation tool')

    parser.add_argument(
        '--max-zoom', dest="max_zoom", type=int, default=10,
        help='The maximum number of zoom levels.'
    )
    parser.add_argument(
        '--layer',
        help='The layer to generate requests for.'
    )
    parser.add_argument(
        '--report-dir', dest="report_dir", default=None,
        help="Optional. Specify the location of the browse reports. Used for ingest, export and delete."
    )
    parser.add_argument(
        "input_csv", nargs=1,
        help='The input CSV file.'
    )
    parser.add_argument(
        "output_csv", nargs=1,
        help='The output CSV file.'
    )
    args = parser.parse_args()


    iterator = iterate_browses(args.input_csv[0], args.report_dir)
    writer = csv.writer(open(args.output_csv[0], "w"))

    layer = args.layer
    zooms = range(args.max_zoom)
    resolutions = [180.0 / (2 ** z) for z in zooms]

    for browse_layer, start, end, (minx, miny, maxx, maxy) in iterator:

        if browse_layer is not None:
            layer = browse_layer

        for z, res in izip(zooms, resolutions):
            # calculate tile extents
            left = int((minx + 180) / res)
            right = int((maxx + 180) / res)

            down = int((miny - 90) / -res)
            up = int((maxy - 90) / -res)

            for x, y in product(xrange(left, right+1), xrange(up, down+1)):
                writer.writerow(
                    (request_template % (layer, z, y, x, start, end),)
                )
