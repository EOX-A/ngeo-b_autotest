#!/bin/sh
#-------------------------------------------------------------------------------
#
# Project: ngEO Browse Server <http://ngeo.eox.at>
# Authors: Stephan Meissl <stephan.meissl@eox.at>
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

# About:
# =====
# This script sends some test request simulating the ngEO Controller.

# Running:
# =======
# ./test_controller.sh [URL]

################################################################################
# Usually there should be no need to change anything below.                    #
################################################################################

url=$1

[ "$1" ] || url="http://localhost:3080"

echo "Using Browse Server at $url"

echo "\nRetrieving and setting status in valid order:"
curl "$url"/browse/status; echo ""
curl -T status/status_restart.json "$url"/browse/status; echo ""
curl "$url"/browse/status; echo ""
curl -T status/status_pause.json "$url"/browse/status; echo ""
curl "$url"/browse/status; echo ""
curl -T status/status_resume.json "$url"/browse/status; echo ""
curl "$url"/browse/status; echo ""
curl -T status/status_shutdown.json "$url"/browse/status; echo ""
curl "$url"/browse/status; echo ""
curl -T status/status_start.json "$url"/browse/status; echo ""
curl "$url"/browse/status; echo ""

echo "\nRetrieving and setting status in (mostly) invalid order:"
curl "$url"/browse/status; echo ""
curl -T status/status_resume.json "$url"/browse/status; echo ""
curl "$url"/browse/status; echo ""
curl -T status/status_start.json "$url"/browse/status; echo ""
curl "$url"/browse/status; echo ""
curl -T status/status_pause.json "$url"/browse/status; echo ""
curl "$url"/browse/status; echo ""
curl -T status/status_restart.json "$url"/browse/status; echo ""
curl "$url"/browse/status; echo ""
curl -T status/status_start.json "$url"/browse/status; echo ""
curl "$url"/browse/status; echo ""
curl -T status/status_shutdown.json "$url"/browse/status; echo ""
curl "$url"/browse/status; echo ""
curl -T status/status_resume.json "$url"/browse/status; echo ""
curl "$url"/browse/status; echo ""
