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
import time
import os
from time import gmtime, strftime


#class to allow easier timing of method calls
class Timer:    
    def __enter__(self):
        self.start = time.time()
        return self

    def __exit__(self, *args):
        self.end = time.time()
        self.interval = self.end - self.start



#argument specification for script
parser = argparse.ArgumentParser(description='Command line performance test tool')

parser.add_argument('--ingest', nargs=3,
                   help='Ingestion of browse reports listed in csv file. Pass path to csv file ,path to browse reports, path to storage and and output csv file as arguments.')

parser.add_argument('--export', nargs=2,
                   help='Specify export csv with chunks definition file and export path')

parser.add_argument('--delete', nargs=1,
                   help='Specify csv file with chunks to be deleted')

parser.add_argument('--import', nargs=1, dest='import_dest',
                   help='Specify path to import csv script')

parser.add_argument('--test', nargs=5,
                   help='Do complete performance test, composed of ingest, export, delete and import. Specify path to csv file, path to folder with images and output csv file')

parser.add_argument('--output', nargs=1,
                   help='Ingestion of browse reports listed in csv file. Pass path to csv file ,path to browse reports, path to storage and and output csv file as arguments.')

parser.add_argument('--debug', action='store_true', help='print debug messages to stderr')


#definition for performance test methods
def ingest(csvfilePath, browsePath, storagePath, output, debug):
    f = open(output+'ingest_report'+strftime("%Y-%m-%d_%H:%M:%S", gmtime())+'.csv','w')
    f.write('cmd,execution_time,return_code\n')     
    with open(csvfilePath, 'rb') as csvfile:
        reader = csv.reader(csvfile)
        os.system("echo ======================================================================")
        os.system("echo ============= Performance test starting for ingest====================")
        os.system("echo ======================================================================")
        for row in reader:
            with Timer() as t:
                #execute ingest command
                if(not debug):
                    cmd = "python ../manage.py ngeo_ingest --storage-dir " + storagePath + " --leave-original " + browsePath + row[0]
                else:
                    cmd = "python ../manage.py ngeo_ingest --storage-dir " + storagePath + " --leave-original " + browsePath + row[0] + " -v3" + " --traceback"
                code = os.system(cmd)
            f.write(cmd +","+ '%.09f,%s'%(t.interval,code)+'\n') 
            


def export(csvfilePath, exportPath, output , debug):
    f = open(output+'export_report'+strftime("%Y-%m-%d_%H:%M:%S", gmtime())+'.csv','w')
    f.write('cmd,execution_time,return_code\n')     
    with open(csvfilePath, 'rb') as csvfile:
        reader = csv.reader(csvfile)
        os.system("echo ======================================================================")
        os.system("echo ============= Performance test starting for export====================")
        os.system("echo ======================================================================")
        for row in reader:
            with Timer() as t:
                if(not debug):
                    cmd = "python ../manage.py ngeo_export --layer %s --start %s --end %s --output %s "%(row[0],row[1],row[2],(exportPath+row[0]+row[1]+row[2]+".tar.gz"))
                else:
                    cmd = "python ../manage.py ngeo_export --layer %s --start %s --end %s --output %s -v3 --traceback"%(row[0],row[1],row[2],(exportPath+row[0]+row[1]+row[2]+".tar.gz"))
                code = os.system(cmd)
            f.write(cmd +","+ '%.09f,%s'%(t.interval,code)+'\n') 



def delete(csvfilePath, output , debug):
    f = open(output+'delete_report'+strftime("%Y-%m-%d_%H:%M:%S", gmtime())+'.csv','w')
    f.write('cmd,execution_time,return_code\n')     
    with open(csvfilePath, 'rb') as csvfile:
        reader = csv.reader(csvfile)
        os.system("echo ======================================================================")
        os.system("echo ============= Performance test starting for delete====================")
        os.system("echo ======================================================================")
        for row in reader:
            with Timer() as t:
                if(not debug):
                    cmd = "python ../manage.py ngeo_delete --layer %s --start %s --end %s "%(row[0],row[1],row[2])
                else:
                    cmd = "python ../manage.py ngeo_delete --layer %s --start %s --end %s -v3 --traceback"%(row[0],row[1],row[2])
                code = os.system(cmd)
            f.write(cmd +","+ '%.09f,%s'%(t.interval,code)+'\n') 



def import_file(importfolder, output, debug):
    f = open(output+'import_report'+strftime("%Y-%m-%d_%H:%M:%S", gmtime())+'.csv','w')
    f.write('cmd,execution_time,return_code\n') 
    os.system("echo ======================================================================")
    os.system("echo ============= Performance test starting for import====================")
    os.system("echo ======================================================================")
    for files in os.listdir(importfolder):  
        with Timer() as t:
            if(not debug):
                cmd = "python ../manage.py ngeo_import %s "%(importfolder+files)
            else:
                cmd = "python ../manage.py ngeo_import %s -v3 --traceback"%(importfolder+files)
            print(cmd)
            code = os.system(cmd)
        f.write(cmd +","+ '%.09f,%s'%(t.interval,code)+'\n') 
            


args = parser.parse_args()

if (args.output):

    if (args.ingest):
        ingest(args.ingest[0], args.ingest[1], args.ingest[2], args.output[0], args.debug)

    if(args.export):
        export(args.export[0], args.export[1], args.output[0], args.debug)

    if (args.delete):
        delete(args.delete[0], args.output[0],args.debug)

    if(args.import_dest):
        import_file(args.import_dest[0], args.output[0], args.debug)

    if (args.test):
        ingest(args.test[0], args.test[1], args.test[2], args.output[0], args.debug)
        export(args.test[3], args.test[4], args.output[0], args.debug)
        delete(args.test[3], args.output[0], args.debug)
        import_file(args.test[4], args.output[0], args.debug)
