#-------------------------------------------------------------------------------
#
# Project: ngEO Browse Server <http://ngeo.eox.at>
# Authors: Daniel Santillan <daniel.santillan@eox.at>
#          Stephan Meissl <stephan.meissl@eox.at>
#
#-------------------------------------------------------------------------------
# Copyright (C) 2013 European Space Agency
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
from time import gmtime, strptime, strftime
import itertools, collections
import uuid

from datetime import datetime, timedelta
from xml.dom.minidom import parse, parseString


def consume(iterator, n):
    collections.deque(itertools.islice(iterator, n))


#argument specification for script
parser = argparse.ArgumentParser(description='Script to update browse reports to contain individual time intervals and to create a CSV which separates browse reports in equally sized chunks of times.')

parser.add_argument('--create', nargs=2,
                   help='Pass arguments with path to browse reports and output CSV filepath')

parser.add_argument('--output', nargs=1, default='modifiedBrowses/',
                   help='Pass path to where output shall be saved, default is modifiedBrowses/')


def createChunks(browsePath, outputfile, output):
    f = open(outputfile,'w')
    #2013-08-03T10:07:24+00:00
    dateformat = "%Y-%m-%dT%H:%M:%S+00:00"
    os.system("echo ======================================================================")
    os.system("echo ========= Creating chunks containing equal number of browses =========")
    os.system("echo ======================================================================")
    browses = {}
    browsereports = []

    #collect all layerids and their start and endtimes
    for filename in os.listdir(browsePath):
        export = output + filename
        filename = browsePath + filename
        xmlfile = parse(filename)
        typeid = xmlfile.getElementsByTagName('rep:browseType')[0].firstChild.wholeText
        start = datetime.strptime(xmlfile.getElementsByTagName('rep:startTime')[0].firstChild.wholeText, dateformat)
        end = datetime.strptime(xmlfile.getElementsByTagName('rep:endTime')[0].firstChild.wholeText, dateformat)
        
        browses.setdefault(typeid, []).append([start, end, xmlfile])
        browsereports.append((xmlfile, export))

    #sort by times, modify browse report times so they dont overlap 
    #and write start and entime for each browsereport
    for layer in browses:
        browses[layer].sort()

        iterator = enumerate(browses[layer]).__iter__()

        for i, (start, end, xmlfile) in iterator:
            min_start = start
            max_end = end
            next_i = (i+1) if ((i+1)<len(browses[layer])) else -1
            amount_overlap = 0
            multiplier = 0
            
            if next_i > -1:
                #while end_time is bigger then start_time of the next browsereport
                while max_end >= browses[layer][next_i][0]:
                    #count how many overlap
                    amount_overlap += 1

                    #set max_end to maximum of current browse, previous browse, or to minimum time interval required
                    max_end = max(max_end, browses[layer][next_i][1], min_start+timedelta(seconds=2*(amount_overlap+1)))

                    #increment next_i to compare next browse report times in next loop
                    next_i += 1
                    #check if we reached last element in list
                    if(next_i >= len(browses[layer])):
                        break
                
                if (amount_overlap > 0):
                    # time_interval per browse minus 1sec in between
                    time_interval = (max_end - min_start - timedelta(seconds=(amount_overlap+1))) / (amount_overlap+1)
                    
                    for j in xrange(i, next_i):
                        browses[layer][j][0] = (min_start + time_interval*multiplier + timedelta(seconds=1)*multiplier)
                        browses[layer][j][1] = (min_start + time_interval*(multiplier+1) + timedelta(seconds=1)*multiplier)
                        multiplier = multiplier+1

                        out_start = browses[layer][j][0].strftime(dateformat)
                        out_end = browses[layer][j][1].strftime(dateformat)

                        #Modify browse reports with new start end times
                        browses[layer][j][2].getElementsByTagName('rep:startTime')[0].firstChild.replaceWholeText(out_start)
                        browses[layer][j][2].getElementsByTagName('rep:endTime')[0].firstChild.replaceWholeText(out_end)

                        #Modify id of layer to avoid overwriting browses
                        browses[layer][j][2].getElementsByTagName('rep:browseIdentifier')[0].firstChild.replaceWholeText("_"+str(uuid.uuid4()))

                        #write layerid start and end times of browse to the csv
                        f.write("%s,%s,%s\n"%(layer,out_start,out_end))

                    #browse reports already analyses (time overlapped) can be jumped over                   
                    consume(iterator,amount_overlap)

                else:
                    out_start = browses[layer][i][0].strftime(dateformat)
                    out_end = browses[layer][i][1].strftime(dateformat)

                    #Modify id of layer to avoid overwriting browses
                    browses[layer][i][2].getElementsByTagName('rep:browseIdentifier')[0].firstChild.replaceWholeText("_"+str(uuid.uuid4()))

                    #write layerid start and end times of browse to the csv
                    f.write("%s,%s,%s\n"%(layer,out_start,out_end))

    
    for dom, filename in browsereports:
        with open(filename, "w+") as xmlf:
            xmlf.write(dom.toxml("utf-8"))


    #Check there are actually no overlapping times
    for layer in browses:
        browses[layer].sort()

        for i, (start, end, xmlfile) in enumerate(browses[layer]):
            next_i = (i+1) if ((i+1)<len(browses[layer])) else -1
            if next_i > -1:
                if end >= browses[layer][next_i][0]: 
                    print ("ERROR: Overlap found.",start.strftime(dateformat),end.strftime(dateformat),browses[layer][next_i][0].strftime(dateformat),browses[layer][next_i][1].strftime(dateformat))
                if end <= start:
                    print ("ERROR: Empty or negative time interval found.",start.strftime(dateformat),end.strftime(dateformat),browses[layer][next_i][0].strftime(dateformat),browses[layer][next_i][1].strftime(dateformat))


args = parser.parse_args()

if (args.create):
    createChunks(args.create[0], args.create[1], args.output[0])

