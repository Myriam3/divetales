import { Controller } from "@hotwired/stimulus"
import mapboxgl from 'mapbox-gl';

export default class extends Controller {
  static targets = [
    "mapContainer",
    "coordinatesContainer",
    "mapInfoContainer",
    "mapCanvas",
    "memoryDiveContainer"
  ];

  static values = {
    apiUrl: String,
    latitude: String,
    longitude: String,
    tripId: String,
    dives: Array,
    diveUrl: String
  };

  connect() {
    this.init();
  }

  async init() {
    const settings = await this.getMapboxInfo();
    if (!settings?.token) return;

    // Trip map
    if (this.divesValue?.length) {
      this.initTripMap(settings);
      return;
    }

     // Dive map
    if (!(this.latitudeValue && this.longitudeValue)) return;
    this.initMapbox(this.latitudeValue, this.longitudeValue, settings);
  }

  // New dive form
  async initNew(e = {}) {
    if (this.isInit) return;

    const settings = await this.getMapboxInfo();
    if (!settings.token) return;
    this.initMapbox(e.detail.lat, e.detail.long, settings);
    // TODO update map & info when re-upload fit file or change coordinates
    this.isInit = true;
  }

  initMapbox(lat, long, settings) {
    if (!(lat && long)) return;
    this.displayMap(lat, long, settings);
    this.setGeoInfo(lat, long, settings.token);
  }

  // Trip Map
  initTripMap(settings) {
    //const bounds = new mapboxgl.LngLatBounds();
    //console.log(bounds);
    const startLat = this.divesValue[0].lat;
    const startLong = this.divesValue[0].long

    this.displayMap(startLat, startLong, settings);
  }

  async getMapboxInfo() {
    return fetch(this.apiUrlValue, {
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
      }
    })
    .then(res => res.json())
    .then(data => data)
    .catch(error => console.error("Mapbox:", error));
  }

  // Display map
  displayMap(lat, long, { token }) {
    mapboxgl.accessToken = token;
    const options = {
      container: this.mapCanvasTarget,
      style: "mapbox://styles/mapbox/streets-v12",
      center: [long, lat],
      zoom: 8,
    }

    if (!this.divesValue.length) options.minZoom = 4;

    this.map = new mapboxgl.Map(options);

    this.mapContainerTarget.style.visibility = 'visible';
    this.mapContainerTarget.style.height = 'auto';

    if (this.divesValue.length) {
      this.addTripMarkers();
    } else {
      window.setTimeout(() => {
        this.addDiveMarker(lat, long);
      }, 500);
    }
  }

  // Markers
  addDiveMarker(lat, long) {
    try {
      const marker = new mapboxgl.Marker()
        .setLngLat([long, lat])
        .addTo(this.map);
      return marker;
    } catch(error) {
      console.log(error);
    }
  }

  addTripMarkers() {
    // Group dives by coordinates
    const points = this.divesValue.reduce((acc, dive) => {
      const key = `${dive.lat},${dive.long}`;
      if (!acc[key]) acc[key] = [];
      acc[key].push(dive);
      return acc;
    }, {});

    const setMarker = (point) => {
      const marker = this.addDiveMarker(point[0].lat, point[0].long);

      if (!marker) {
        console.log('marker not added', point)
        return;
      }

      // Click on marker handler
      if (point.length < 2) {
        marker?.getElement().addEventListener('click', (e) => {
          this.displayDive(point[0].id);
        });
      } else {
          // TODO if multiple dives by point, popup
      }
    }

    for (const key in points) {
      setMarker(points[key]);
    }
  }

  // Display dive on marker click
  async displayDive(id) {
    const url = new URL(this.diveUrlValue, window.location.origin);
    url.searchParams.set("dive_id", id);
    console.log(url);

    try {
      const response = await fetch(url, {
        headers: { Accept: "text/vnd.turbo-stream.html" },
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      });
      const html = await response.text();
      Turbo.renderStreamMessage(html);
    } catch (error) {
      console.log(error);
    }
  }

  // Geocoding info
  async setGeoInfo(lat, long, token) {
    // Display coordinates
    if (this.coordinatesContainerTarget) {
      this.coordinatesContainerTarget.insertAdjacentHTML('beforeend', `${lat}, ${long}`);
      this.coordinatesContainerTarget.style.display = 'block';
    }

    // Display geo info
    const geoInfo = await this.fetchGeocodingPlace(lat, long, token);
    if (!geoInfo || !this.mapInfoContainerTarget) return;

    this.mapInfoContainerTarget.insertAdjacentHTML('beforeend', geoInfo.name);
    this.mapInfoContainerTarget.style.display = 'block';

    // Event for updating the form
    this.dispatch("geoinfo", {
      detail: geoInfo,
      bubbles: true
    });
  }

  async fetchGeocodingPlace(lat, long, token) {
    try {
      const endpoint = `https://api.mapbox.com/search/geocode/v6/reverse?longitude=${long}&latitude=${lat}&language=en&limit=1&access_token=${token}`
      const response = await fetch(endpoint);
      const data = await response.json();
      console.log('GEOINFO', data);
      if (!data.features.length) return;

      const result = data.features[0].properties;

      return {
        name: `${result.full_address?.replace(/<[^>]*>/g, '')}`,
        countryCode: result.context?.country?.country_code?.toLowerCase()
      };
    } catch (error) {
      console.error('Mapbox Geocoding', error);
    }
  }

  // Center map on itinerary click
  centerMap(location) {
    console.log(location, 'center map');
  }

  disconnect() {
    if (this.map) this.map.remove();
  }
}
