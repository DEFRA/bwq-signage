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
  const attribution = Leaflet.control.attribution({ prefix: false });
  attribution.setPosition('bottomright');
  attribution.addAttribution('Contains OS data © Crown copyright and database right (2018)');

  const mapConfig = {
    center: Leaflet.latLng(options.lat, options.long),
    zoom: options.zoom,
    crs,
    scrollWheelZoom: false,
    zoomControl: false,
    attributionControl: false,
  };

  const osMap = new Leaflet.Map(options.mapId, mapConfig);

  attribution.addTo(osMap);
  return osMap;
}

function drawMap(options) {
  const osMap = createMap(options);

  const layer = osLeisureLayer(options);
  osMap.addLayer(layer);

  Leaflet.marker([options.lat, options.long]).addTo(osMap);

  return osMap;
}

function constructMap(env) {
  const src = document.querySelector('#map-data').getAttribute('data-bw');
  const bwData = JSON.parse(src);

  bwData.zoom = 8;
  bwData.key = env.map_api;
  bwData.mapId = 'map';

  drawMap(bwData);
}

export default function initialiseMap() {
  if (document.querySelector('#map-data')) {
    Axios.get(
      'env',
      {
        headers: {
          Accept: 'application/json',
        },
      },
    ).then((response) => {
      constructMap(response.data);
    });
  }
}
