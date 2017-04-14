#!/usr/bin/env python

import xml.etree.ElementTree as ET
from json import load


def json_to_kml(google, document):
    assert set(g['geometry']['type'] for g in google) == set(['Point'])

    def _name(place):
        return place['properties']['Title']

    def _location(place):
        return ','.join(map(str, place['geometry']['coordinates']))

    for place in google:
        placemark = ET.SubElement(document, 'Placemark')
        point = ET.SubElement(placemark, 'Point')
        ET.SubElement(point, 'coordinates').text = _location(place)
        ET.SubElement(placemark, 'name').text = _name(place)


def google_to_mapsme(filename):
    kml = ET.Element('kml', xmlns='http://earth.google.com/kml/2.2')
    document = ET.SubElement(kml, 'Document')
    ET.SubElement(document, 'name').text = 'Imported from Google'
    ET.SubElement(document, 'visibility').text = '1'

    with open(filename) as f:
        google = load(f)

    json_to_kml(google['features'], document)

    tree = ET.ElementTree(kml)
    tree.write('generated.kml')


if __name__ == '__main__':
    import sys  # noqa
    google_to_mapsme(sys.argv[1] if len(sys.argv) > 1 else 'google.json')
