#-------------------------------------------------------------------------------
#
# Project: ngEO Browse Server <http://ngeo.eox.at>
# Authors: Daniel Santillan <daniel.santillan@eox.at>
#
#-------------------------------------------------------------------------------
# Copyright (C) 2013 EOX IT Services GmbH
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
import argparse
import os
from os.path import join
from datetime import datetime
from itertools import izip
from time import time
from lxml import etree
from glob import glob

#class to allow easier timing of method calls
class Timer:    
    def __enter__(self):
        self.start = time()
        return self

    def __exit__(self, *args):
        self.end = time()
        self.interval = self.end - self.start


def iterate_browses(csv_path, basepath):
    ns = {"rep": "http://ngeo.eo.esa.int/schema/browseReport"}
    with open(csv_path) as f:
        reader = csv.reader(f)
        for row in reader:

            report_filename = row[0]
            if basepath:
                report_filename = join(basepath, report_filename)

            tree = etree.parse(report_filename)
            browse_type = tree.xpath("rep:browseType/text()", namespaces=ns)[0]
            starts = tree.xpath("rep:browse/rep:startTime/text()", namespaces=ns)
            ends = tree.xpath("rep:browse/rep:endTime/text()", namespaces=ns)
            for start, end in izip(starts, ends):
                yield report_filename, browse_type, start, end


def execute(command, out_writer=None):
    """ Executes a command line command and returns the time in seconds.
    """
    with Timer() as timer:
        code = os.system(command)

    if out_writer:
        out_writer.writerow((command, "%.09f" % timer.interval, str(code)))

    return timer.interval, code


#definition for performance test methods
def ingest(iterator, out_writer, browse_dir):
    for report_filename, _, _, _ in iterator:
        command = "python ../../manage.py ngeo_ingest %s" % report_filename
        if browse_dir:
            command = "%s --leave-original --storage-dir %s" % (command, browse_dir)
        execute(command, out_writer)


def export(iterator, out_writer, export_path):
    for _, browse_type, start, end in iterator:
        out_filename = join(
            export_path, "%s_%s_%s.tar.gz" 
            % (browse_type, start.replace(":", ""), end.replace(":", ""))
        )
        command = (
            "python ../../manage.py ngeo_export --browse-type %s --start %s --end %s --output %s " 
            % (browse_type, start, end, out_filename)
        )
        execute(command, out_writer)


def delete(iterator, out_writer):
    for _, browse_type, start, end in iterator:
        command = (
            "python ../../manage.py ngeo_delete --browse-type %s --start %s --end %s" 
            % (browse_type, start, end)
        )
        execute(command, out_writer)


def import_(import_dir, out_writer):
    for path in glob(join(import_dir, "*.tar.gz")):
        command = "python ../../manage.py ngeo_import %s" % path
        execute(command, out_writer)
            

def get_writer(command, time, result_dir):
    filename = "%s_%s.csv" % (command, time.replace(":", ""))
    if result_dir:
        filename = join(result_dir, filename)
    return csv.writer(open(filename, "w"))


if __name__ == "__main__":
    #argument specification for script
    parser = argparse.ArgumentParser(description='Command line performance test tool')

    parser.add_argument(
        '--ingest', action="store_true",
        help='Ingestion of browse reports listed in csv file.'
    )
    parser.add_argument(
        '--export', action="store_true",
        help='Export all browses referenced by any browse report in the csv file.'
    )
    parser.add_argument(
        '--delete', action="store_true",
        help='Delete all browses reference by any browse report in the csv file.'
    )
    parser.add_argument(
        '--import', dest="import_", action="store_true",
        help='Import all archives in the "export-dir".'
    )
    parser.add_argument(
        '--all', action="store_true",
        help='Do complete performance test, composed of ingest, export, delete and import.'
    )
    parser.add_argument(
        '--export-dir', dest="export_dir",
        help="Optional. Specify location to store exported archives. Used for export and import."
    )
    parser.add_argument(
        '--report-dir', default=None,
        help="Optional. Specify the location of the browse reports. Used for ingest, export and delete."
    )
    parser.add_argument(
        '--browse-dir', default=None,
        help="Optional. Specify the location of the browse. Used for ingest."
    )
    parser.add_argument(
        '--result-dir', default=None,
        help="Optional. Specify the location to store the results."
    )
    parser.add_argument(
        'input_csv', nargs=1,
        help='The input csv file that references the browse reports to be tested.'
    )

    args = parser.parse_args()

    now = datetime.now().isoformat("T")
    csv_path = args.input_csv[0]
    report_dir = args.report_dir
    browse_dir = args.browse_dir
    export_dir = args.export_dir
    result_dir = args.result_dir

    if args.ingest or args.all:
        ingest(iterate_browses(csv_path, report_dir), get_writer("ingest", now, result_dir), browse_dir)

    if args.export or args.all:
        export(iterate_browses(csv_path, report_dir), get_writer("export", now, result_dir), export_dir)

    if args.delete or args.all:
        delete(iterate_browses(csv_path, report_dir), get_writer("delete", now, result_dir))

    if args.import_ or args.all:
        import_(export_dir, get_writer("import", now, result_dir))
