<template lang='html'>
  <div id='map'></div>
</template>

<script>
import Leaflet from 'leaflet';
import 'proj4leaflet';
import Axios from 'axios';

/** Mapping service configuration */
const MAP_SERVICE = 'https://{s}.ordnancesurvey.co.uk/mapping_api/v1/service/zxy/{tilematrixSet}/{layer}/{z}/{x}/{y}.{imgFormat}?key={key}';

const epsg27700 = '+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.999601 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.060,0.1502,0.2470,0.8421,-20.4894 +datum=OSGB36 +units=m +no_defs';

const crs = new Leaflet.Proj.CRS(
  'EPSG:27700',
  epsg27700, {
    transformation: new Leaflet.Transformation(1, 238375, -1, 1376256),
    resolutions: [896.0, 448.0, 224.0, 112.0, 56.0, 28.0, 14.0, 7.0, 3.5, 1.75,
      0.875, 0.4375, 0.21875, 0.109375],
  },
);

  // proj4.defs('osgb', crs); // Define OSGB projection transform function
  // proj4.defs('epsg27700', epsg27700); // Define OSGB projection transform function

function osLeisureLayer(options) {
  return new Leaflet.TileLayer(MAP_SERVICE, {
    key: options.key,
    tilematrixSet: 'EPSG:27700',
    layer: 'Outdoor 27700',
    imgFormat: 'png',
    subdomains: ['api', 'api2'],
    continuousWorld: true,
    opacity: 1.0,
  });
}

function createMap(options) {
  const attribution = Leaflet.control.attribution();
  attribution.setPosition('bottomright');
  attribution.addAttribution('Crown Copyright, terms and conditions apply');

  const mapConfig = {
    center: Leaflet.latLng(options.lat, options.long),
    zoom: options.zoom,
    crs,
    scrollWheelZoom: false,
    zoomControl: false,
    attributionControl: false,
  };

  const osMap = new Leaflet.Map(options.mapId, mapConfig);

  // attribution.addTo(osMap);
  return osMap;
}

function initMap(options) {
  const osMap = createMap(options);

  const layer = osLeisureLayer(options);
  osMap.addLayer(layer);

  Leaflet.marker([options.lat, options.long]).addTo(osMap);

  return osMap;
}

export default {
  data: () => ({
    bwData: {},
    env: {},
  }),

  mounted() {
    console.log('sampling-point-map mounted');
    const vm = this;

    Axios.get(
      'env',
      {
        headers: {
          Accept: 'application/json',
        },
      },
    ).then((response) => {
      vm.env = response.data;
      vm.initialiseMap();
    });
  },

  methods: {
    initialiseMap() {
      const src = document.querySelector('#map-data').getAttribute('data-bw');
      this.bwData = JSON.parse(src);

      this.bwData.zoom = 8;
      this.bwData.key = this.env.map_api;
      this.bwData.mapId = 'map';

      initMap(this.bwData);
    },
  },
};
</script>

<style lang='scss'>
</style>
