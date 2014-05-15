


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

