#!/bin/sh
#-------------------------------------------------------------------------------
#
# Project: ngEO Browse Server <http://ngeo.eox.at>
# Authors: Fabian Schindler <fabian.schindler@eox.at>
#          Marko Locher <marko.locher@eox.at>
#          Stephan Meissl <stephan.meissl@eox.at>
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
# This script resets the autotest instance used in testing via vagrant.
#
# Use with caution as data is deleted and may be lost.
# Particularly only use in testing and never in production environments.

# Running:
# =======
# sudo ./reset_db.sh
#
################################################################################

service httpd stop

# Reset DB with PostgreSQL:
su postgres -c "dropdb ngeo_browse_server_db"
rm -f /var/ngeob_autotest/data/mapcache.sqlite
su postgres -c "createdb -O ngeo_user -T template_postgis ngeo_browse_server_db"

python -c "
from lxml import etree
mapcache_xml_filename = '/var/www/cache/mapcache.xml'
root = etree.parse(mapcache_xml_filename).getroot()
for e in root.xpath('cache|source|tileset'):
    root.remove(e)
with open(mapcache_xml_filename, 'w') as f:
    f.write(etree.tostring(root, pretty_print=True))
"

cd /var/ngeob_autotest/
python manage.py syncdb --noinput
python manage.py syncdb --database=mapcache --noinput
python manage.py loaddata auth_data.json initial_rangetypes.json
#python manage.py loaddata --database=mapcache ngeo_mapcache.json

python manage.py ngeo_browse_layer --add data/layer_management/defaultLayers.xml

## Reset DB with Django:
## Note, schema changes are not applied.
#cd /var/ngeob_autotest/
#python manage.py flush
#python manage.py flush --database=mapcache
#python manage.py loaddata auth_data.json ngeo_browse_layer.json eoxs_dataset_series.json initial_rangetypes.json
#python manage.py loaddata --database=mapcache ngeo_mapcache.json

# Reset ngEO Browse Server
rm -rf /var/ngeob_autotest/data/optimized/ /var/ngeob_autotest/data/success/ /var/ngeob_autotest/data/failure/ /var/www/store/
mkdir /var/ngeob_autotest/data/optimized/ /var/ngeob_autotest/data/success/ /var/ngeob_autotest/data/failure/ /var/www/store/
rm -f /var/ngeob_autotest/logs/eoxserver.log /var/ngeob_autotest/logs/ngeo.log
touch /var/ngeob_autotest/logs/eoxserver.log /var/ngeob_autotest/logs/ngeo.log

# Reset MapCache
rm -f /var/www/cache/TEST_SAR.sqlite /var/www/cache/TEST_OPTICAL.sqlite /var/www/cache/TEST_ASA_WSM.sqlite /var/www/cache/TEST_MER_FRS.sqlite /var/www/cache/TEST_MER_FRS_FULL.sqlite /var/www/cache/TEST_MER_FRS_FULL_NO_BANDS.sqlite /var/www/cache/TEST_GOOGLE_MERCATOR.sqlite

# Upload test data
cp /var/ngeob_autotest/data/reference_test_data/*.jpg /var/www/store/
cp /var/ngeob_autotest/data/test_data/*.tif /var/www/store/
cp /var/ngeob_autotest/data/test_data/*.jpg /var/www/store/
cp /var/ngeob_autotest/data/feed_test_data/*.png /var/www/store/
cp /var/ngeob_autotest/data/aiv_test_data/*.jpg /var/www/store/

# Make the instance read- and editable by apache
chmod -R a+w /var/ngeob_autotest/
chmod -R a+w /var/www/

service httpd start
